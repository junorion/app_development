/* 템플릿 시작 화면 검증. 앱 내용을 바꾸면 이 파일도 앱에 맞게 고친다. */
const assert = require("assert");
const { loadApp } = require("./load-app.js");

let n = 0;
function test(name, fn) { fn(); n++; console.log("  ok  " + name); }

test("처음 실행하면 0 에서 시작하고 다크 테마", () => {
  const app = loadApp();
  assert.strictEqual(app.byId.count.textContent, "0");
  assert.strictEqual(app.doc.documentElement.dataset.theme, "dark");
});

test("누르면 숫자가 오르고 저장되며 진동한다", () => {
  const app = loadApp();
  app.byId.btnTap.click();
  app.byId.btnTap.click();
  assert.strictEqual(app.byId.count.textContent, "2");
  assert.strictEqual(app.storage.get("myapp.count"), "2");
  assert.deepStrictEqual(app.vibrations, [8, 8]);
});

test("저장된 값과 테마를 복원한다", () => {
  const app = loadApp({ storage: { "myapp.count": "5", "myapp.theme": '"light"' } });
  assert.strictEqual(app.byId.count.textContent, "5");
  assert.strictEqual(app.doc.documentElement.dataset.theme, "light");
});

test("테마 버튼이 다크/라이트를 오가며 저장한다", () => {
  const app = loadApp();
  app.byId.btnTheme.click();
  assert.strictEqual(app.doc.documentElement.dataset.theme, "light");
  assert.strictEqual(app.storage.get("myapp.theme"), '"light"');
  app.byId.btnTheme.click();
  assert.strictEqual(app.doc.documentElement.dataset.theme, "dark");
});

test("저장소가 망가져 있어도 기본값으로 뜬다", () => {
  const app = loadApp({ storage: { "myapp.count": "{깨짐" } });
  assert.strictEqual(app.run("count"), 0);
});

test("뒤로 가기 훅이 있다 (APK 가 부른다)", () => {
  const app = loadApp();
  assert.strictEqual(typeof app.window.onAndroidBack, "function");
  assert.strictEqual(app.window.onAndroidBack(), false);
});

console.log(`${n}건 통과`);

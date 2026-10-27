/* index.html 의 인라인 스크립트를 스텁 DOM 위에서 평가한다. 각 테스트 파일이 새로 부르면
   깨끗한 상태(빈 localStorage 포함)에서 시작한다. 반환값의 run(expr) 로 앱 안의
   let/const 변수와 함수를 읽고 부를 수 있다. */
const fs = require("fs");
const path = require("path");
const { makeDom } = require("./dom-stub.js");

function loadApp({ ids = [], storage = {} } = {}) {
  const html = fs.readFileSync(path.join(__dirname, "..", "index.html"), "utf8");
  const m = html.match(/<script>\n([\s\S]*?)\n<\/script>/);
  if (!m) throw new Error("index.html 에서 <script> 를 찾지 못했습니다");

  const { doc, byId } = makeDom(ids);
  const mem = new Map(Object.entries(storage));
  const vibrations = [];
  const g = {
    document: doc,
    localStorage: {
      getItem: k => (mem.has(k) ? mem.get(k) : null),
      setItem: (k, v) => mem.set(k, String(v)),
      removeItem: k => mem.delete(k),
    },
    window: { addEventListener() {}, matchMedia: () => ({ matches: false }) },
    navigator: { vibrate: p => { vibrations.push(p); return true; } },
    location: { protocol: "file:", hostname: "" },
  };
  // 인라인 스크립트의 최상위 let/const 는 함수 안에서만 보이므로, 같은 스코프에서
  // 식을 평가해 주는 run 을 함께 만들어 돌려준다.
  const factory = new Function(...Object.keys(g),
    m[1] + "\nreturn (expr) => eval(expr);");
  const run = factory(...Object.values(g));
  return { run, doc, byId, storage: mem, vibrations, window: g.window };
}

module.exports = { loadApp };

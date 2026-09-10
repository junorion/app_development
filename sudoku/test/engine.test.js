const fs = require("fs");
const { makeDom } = require("./dom-stub.js");

const html = fs.readFileSync(require("path").join(__dirname, "..", "index.html"), "utf8");
const m = html.match(/<script>\n([\s\S]*?)\n<\/script>/);
if (!m) { console.error("스크립트를 찾지 못했습니다"); process.exit(1); }

const IDS = ["board","pad","paper","timer","diffBadge","btnPause","btnStats","btnTheme",
  "btnUndo","btnRedo","btnErase","btnNotes","btnHint","btnNew","btnResume","btnNewCancel",
  "diffList","newTitle","newDesc","resTime","resSub","resRecord","btnResultClose","btnResultNew",
  "statStreak","statBody","btnStatsReset","btnStatsClose",
  "ovGen","ovPause","ovNew","ovResult","ovStats"];
const { doc } = makeDom(IDS);

// localStorage 스텁 — 실제 저장/복원 경로까지 함께 검증한다
const mem = new Map();
global.localStorage = {
  getItem: k => (mem.has(k) ? mem.get(k) : null),
  setItem: (k, v) => mem.set(k, String(v)),
  removeItem: k => mem.delete(k),
};
global.document = doc;
global.window = { addEventListener() {}, matchMedia: () => ({ matches: false }) };
global.navigator = { vibrate: () => true };
global.location = { protocol: "file:", hostname: "" };
global.setInterval = () => 0;

const EXPORTS = ["makeSolved","countSolutions","rate","logicSolve","generatePuzzle","conflicts",
  "commit","undo","redo","inputDigit","eraseCell","showHint","applyHint","findHint","select","updateView","newState",
  "saveGame","restoreGame","getStats","recordWin","startGame","fmt","DIFFS","diffName","applyLang","I18N","RATE_MIN","PEERS","ALL_UNITS"];
const src = m[1] + "\n;globalThis.__T = { " + EXPORTS.join(", ") + ", get S(){return S;}, set S(v){S=v;} };";
(0, eval)(src);
const T = globalThis.__T;

let pass = 0, fail = 0;
function ok(name, cond, extra) {
  if (cond) { pass++; }
  else { fail++; console.log("  실패: " + name + (extra ? "  → " + extra : "")); }
}
function valid(g) {
  for (const u of T.ALL_UNITS) {
    const s = new Set(u.map(i => g[i]));
    if (s.size !== 9 || s.has(0)) return false;
  }
  return true;
}

(async () => {
  console.log("== 1. 완성 보드 생성 ==");
  for (let k = 0; k < 30; k++) ok("makeSolved 규칙 준수", valid(T.makeSolved()));
  const a = T.makeSolved(), b = T.makeSolved();
  ok("매번 다른 보드", a.join("") !== b.join(""));

  console.log("== 2. 해 세기 ==");
  const solved = T.makeSolved();
  ok("완성 보드의 해는 1개", T.countSolutions(solved, 2) === 1);
  ok("빈 보드는 2개 이상에서 멈춤", T.countSolutions(new Array(81).fill(0), 2) === 2);
  const oneOff = solved.slice(); oneOff[0] = 0;
  ok("한 칸만 빈 보드도 유일해", T.countSolutions(oneOff, 2) === 1);
  // 해가 갈라지는 진짜 배치(unavoidable set)를 찾아서 검사한다.
  // 같은 밴드의 두 행 r1,r2 와 두 열 c1,c2 에서 값이 대각으로 같으면,
  // 네 칸을 비웠을 때 두 값을 맞바꾼 답도 규칙을 모두 만족한다.
  const findSwap = board => {
    for (let r1 = 0; r1 < 9; r1++)
      for (let r2 = r1 + 1; r2 < 9; r2++) {
        if (((r1 / 3) | 0) !== ((r2 / 3) | 0)) continue;     // 같은 밴드여야 박스가 유지된다
        for (let c1 = 0; c1 < 9; c1++)
          for (let c2 = c1 + 1; c2 < 9; c2++)
            if (board[r1 * 9 + c1] === board[r2 * 9 + c2] &&
                board[r1 * 9 + c2] === board[r2 * 9 + c1])
              return [r1 * 9 + c1, r1 * 9 + c2, r2 * 9 + c1, r2 * 9 + c2];
      }
    return null;
  };
  // 완성판은 무작위라 이런 배치가 없는 판도 나온다. 한 판만 보고 실패로 적으면
  // 테스트가 이따금 이유 없이 깨진다(실제로 그랬다). 여러 판을 훑는다.
  let found = null, base = solved;
  for (let k = 0; k < 20 && !found; k++) {
    base = k === 0 ? solved : T.makeSolved();
    found = findSwap(base);
  }
  ok("해가 갈라지는 배치를 찾았다", !!found);
  if (found) {
    const ambiguous = base.slice();
    for (const i of found) ambiguous[i] = 0;
    ok("그 네 칸을 비우면 해가 2개", T.countSolutions(ambiguous, 2) === 2);
  }

  console.log("== 3. 논리 솔버 ==");
  const easyPuz = solved.slice();
  for (let i = 0; i < 8; i++) easyPuz[i * 9] = 0;         // 각 행에서 한 칸씩만 제거
  ok("쉬운 문제는 단칸으로 풀린다", T.logicSolve(easyPuz, 1) !== null);
  ok("풀린 결과가 원래 해와 같다",
     JSON.stringify(T.logicSolve(easyPuz, 1)) === JSON.stringify(solved));
  ok("rate 는 1을 준다", T.rate(easyPuz) === 1);

  console.log("== 4. 난이도별 생성 ==");
  for (const d of T.DIFFS) {
    const t0 = Date.now();
    const made = await T.generatePuzzle(d.level);
    const ms = Date.now() - t0;
    ok(T.diffName(d.key) + " 생성됨", !!made);
    if (!made) continue;
    const givens = made.puzzle.filter(v => v).length;
    ok(T.diffName(d.key) + " 유일해", T.countSolutions(made.puzzle, 2) === 1);
    // 난이도는 "정확히 그 등급"이 아니라 상한(라벨보다 어렵지 않다)과
    // 하한(라벨보다 쉽지도 않다) 사이여야 한다.
    const r = T.rate(made.puzzle);
    ok(T.diffName(d.key) + " 난이도가 상한 이내", r <= d.level, "실제 " + r);
    ok(T.diffName(d.key) + " 난이도가 하한 이상", r >= T.RATE_MIN[d.level], "실제 " + r);
    ok(T.diffName(d.key) + " 해가 완성 보드", valid(made.solution));
    ok(T.diffName(d.key) + " 문제는 해의 부분집합",
       made.puzzle.every((v, i) => v === 0 || v === made.solution[i]));
    ok(T.diffName(d.key) + " given 개수 타당", givens >= 17 && givens <= 60, String(givens));
    console.log("   " + T.diffName(d.key) + ": given " + givens + "개, " + ms + "ms");
  }
  console.log("\n통과 " + pass + " / 실패 " + fail);
  process.exit(fail ? 1 : 0);
})();

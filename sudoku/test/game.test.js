const fs = require("fs");
const { makeDom } = require("./dom-stub.js");

const html = fs.readFileSync(require("path").join(__dirname, "..", "index.html"), "utf8");
const src0 = html.match(/<script>\n([\s\S]*?)\n<\/script>/)[1];

const IDS = ["board","pad","paper","timer","diffBadge","btnPause","btnStats","btnTheme",
  "btnUndo","btnRedo","btnErase","btnNotes","btnHint","btnNew","btnResume","btnNewCancel",
  "diffList","newTitle","newDesc","resTime","resSub","resRecord","btnResultClose","btnResultNew",
  "statStreak","statBody","btnStatsReset","btnStatsClose",
  "ovGen","ovPause","ovNew","ovResult","ovStats"];
const { doc } = makeDom(IDS);
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

const EX = ["makeSolved","countSolutions","rate","generatePuzzle","conflicts","commit","undo","redo",
  "inputDigit","eraseCell","showHint","applyHint","dismissHint","findHint","select","updateView","newState","saveGame","restoreGame",
  "getStats","recordWin","scoreFor","levelOf","computeAutoNotes","getCoins","setCoins","addCoins","spendCoins","INITIAL_COINS","HINT_COST","WIN_REWARD","KEY_COINS","KEY_STATS","drop","loadSettings","setSetting","SETTING_DEFAULTS","placeDigit","buzz","KEY_SETTINGS","SETTING_ROWS","SCORE_BASE","PAR_MS","DIFFS","diffName","applyLang","I18N","bit","fmt","elapsedMs","startTimer","stopTimer","PEERS","RATE_MIN","GIVEN_CEIL",
  "sfx","syncMusic","musicPlaying","closeOverlay","MISTAKE_MAX","countMistake","select","inputDigit","NOTE_FONTS","noteFont","applyNoteFont","ACCENTS","accentKey","applyAccent","KEY_ACCENT","KEY_NOTEFONT"];
(0, eval)(src0 + "\n;globalThis.__T={" + EX.join(",") + ",get S(){return S;},set S(v){S=v;},"
  + "get view(){return view;},set view(v){view=v;},"
  + "get overlayOpen(){return overlayOpen;},get hint(){return hint;},get settings(){return settings;},get padSel(){return padSel;},set padSel(v){padSel=v;}};");
const T = globalThis.__T;

let pass = 0, fail = 0;
const ok = (n, c, e) => { if (c) pass++; else { fail++; console.log("  실패: " + n + (e ? "  → " + e : "")); } };

(async () => {
  console.log("== 5. 생성 안정성 (난이도별 20회) ==");
  for (const d of T.DIFFS) {
    let worst = 0, mismatch = 0, tooEasy = 0, tooMany = 0, gmin = 81, gmax = 0;
    for (let k = 0; k < 20; k++) {
      const t0 = Date.now();
      const made = await T.generatePuzzle(d.level);
      worst = Math.max(worst, Date.now() - t0);
      if (!made) { mismatch++; continue; }
      const r = T.rate(made.puzzle);
      if (r > d.level) mismatch++;                 // 라벨보다 어려우면 안 된다
      if (r < T.RATE_MIN[d.level]) tooEasy++;      // 라벨보다 쉬워도 안 된다
      if (T.countSolutions(made.puzzle, 2) !== 1) { fail++; console.log("  실패: 유일해 아님"); }
      const g = made.puzzle.filter(v => v).length;
      if (g > T.GIVEN_CEIL[d.level]) tooMany++;
      gmin = Math.min(gmin, g); gmax = Math.max(gmax, g);
    }
    ok(T.diffName(d.key) + " 20회 모두 라벨 이하 난이도", mismatch === 0, mismatch + "회 초과");
    ok(T.diffName(d.key) + " 20회 모두 기법 하한 충족", tooEasy === 0, tooEasy + "회 미달");
    ok(T.diffName(d.key) + " 20회 모두 given 상한 이내", tooMany === 0, tooMany + "회 초과");
    ok(T.diffName(d.key) + " 최악 생성시간 3초 미만", worst < 3000, worst + "ms");
    console.log("   " + T.diffName(d.key) + ": given " + gmin + "~" + gmax + "개, 최악 " + worst + "ms");
  }

  console.log("== 6. 게임 조작 ==");
  // 아래에서 일부러 틀린 숫자를 놓는다. 실수 제한이 켜져 있으면 세 번째에 판이 끝나
  // 뒤따르는 검사가 모두 깨진다 — 제한 자체는 20번 항목에서 따로 본다.
  T.setSetting("mistakeLimit", false);
  const made = await T.generatePuzzle(2);
  T.S = T.newState("normal", made.puzzle, made.solution);
  const S = T.S;
  const empty = [];
  for (let i = 0; i < 81; i++) if (!S.puzzle[i]) empty.push(i);
  const i0 = empty[0], correct = S.solution[i0];
  const wrong = correct === 9 ? 1 : correct + 1;

  T.select(i0);
  ok("칸 선택됨", T.S.selected === i0);

  T.inputDigit(correct);
  ok("숫자가 입력된다", T.S.grid[i0] === correct);
  ok("되돌리기 기록이 쌓인다", T.S.history.length === 1);

  T.inputDigit(correct);
  ok("같은 숫자를 다시 누르면 지워진다", T.S.grid[i0] === 0);

  T.undo();
  ok("되돌리기로 숫자가 살아난다", T.S.grid[i0] === correct);
  T.redo();
  ok("다시하기로 again 지워진다", T.S.grid[i0] === 0);
  T.undo();

  // given 칸은 건드릴 수 없다
  const gi = S.puzzle.findIndex(v => v !== 0);
  T.select(gi);
  const before = T.S.grid[gi];
  T.inputDigit(wrong);
  ok("given 칸은 바뀌지 않는다", T.S.grid[gi] === before);
  T.eraseCell();
  ok("given 칸은 지워지지 않는다", T.S.grid[gi] === before);

  // 메모
  const i1 = empty[1];
  T.select(i1);
  T.S.notesMode = true;
  T.inputDigit(3); T.inputDigit(7);
  ok("메모가 두 개 켜진다", T.S.notes[i1] === (T.bit(3) | T.bit(7)));
  T.inputDigit(3);
  ok("같은 메모를 다시 누르면 꺼진다", T.S.notes[i1] === T.bit(7));
  T.S.notesMode = false;

  // 확정 숫자를 넣으면 같은 줄의 해당 메모가 지워진다
  const peerOf1 = (() => {
    for (let j = 0; j < 81; j++) {
      if (j === i1 || S.puzzle[j] || S.grid[j]) continue;
      const r1 = (i1 / 9) | 0, r2 = (j / 9) | 0;
      if (r1 === r2) return j;
    }
    return -1;
  })();
  if (peerOf1 >= 0) {
    T.select(peerOf1);
    T.inputDigit(7);
    ok("같은 행에 7을 넣으면 이웃의 7 메모가 지워진다", (T.S.notes[i1] & T.bit(7)) === 0);
    T.undo();
    ok("되돌리면 메모도 함께 돌아온다", (T.S.notes[i1] & T.bit(7)) !== 0);
  }

  // 충돌 표시
  const row0 = [];
  for (let c = 0; c < 9; c++) row0.push(c);
  const twoEmpty = row0.filter(i => !S.puzzle[i] && !T.S.grid[i]);
  if (twoEmpty.length >= 2) {
    T.select(twoEmpty[0]); T.inputDigit(5);
    T.select(twoEmpty[1]); T.inputDigit(5);
    const bad = T.conflicts(T.S.grid);
    ok("같은 행 중복이 충돌로 잡힌다", bad.has(twoEmpty[0]) && bad.has(twoEmpty[1]));
    T.undo(); T.undo();
  }

  // 힌트 — 설명을 띄우고, 적용해야 숫자가 들어간다
  const beforeHints = T.S.hints;
  T.select(-1);
  T.showHint();
  ok("힌트를 띄워도 아직 숫자는 들어가지 않는다", T.S.hints === beforeHints);
  T.applyHint();
  ok("적용하면 힌트 사용 횟수가 오른다", T.S.hints === beforeHints + 1);
  const hinted = T.S.selected;
  ok("힌트는 정답을 넣는다", T.S.grid[hinted] === T.S.solution[hinted]);

  console.log("== 7. 저장과 복원 ==");
  T.startTimer();
  T.saveGame();
  const snapshot = JSON.stringify(T.S.grid);
  const restored = T.restoreGame();
  ok("복원된다", !!restored);
  ok("보드가 같다", JSON.stringify(restored.grid) === snapshot);
  ok("난이도가 같다", restored.diff === "normal");
  ok("메모가 같다", JSON.stringify(restored.notes) === JSON.stringify(T.S.notes));
  ok("되돌리기 기록이 살아있다", restored.history.length === T.S.history.length);
  T.stopTimer();

  // 진행 중인 게임이 없을 때 저장을 호출해도 저장본이 사라지면 안 된다.
  // (Home 으로 나갈 때마다 호출되므로, 지우면 앱 시작 때 이어하기가 없어진다)
  {
    const keep = JSON.stringify(T.S.grid);
    T.saveGame();
    const before = T.restoreGame();
    T.S = null;
    T.saveGame();                    // S 가 없는 상태에서 저장 호출
    const after = T.restoreGame();
    ok("게임이 없을 때 저장해도 저장본이 남는다", !!after,
       before ? "복원 전에는 있었음" : "복원 전에도 없었음");
    if (after) ok("저장본이 그대로다", JSON.stringify(after.grid) === keep);
  }

  console.log("== 8. 완료 판정과 기록 ==");
  T.S = T.newState("hard", made.puzzle, made.solution);
  for (let i = 0; i < 81; i++) T.S.grid[i] = T.S.solution[i];
  ok("완성 보드에 충돌이 없다", T.conflicts(T.S.grid).size === 0);
  T.S.elapsed = 65000;
  const res = T.recordWin("hard", 65000, 0, false);
  ok("첫 완료는 최고 기록", res.isBest === true);
  ok("점수를 돌려준다", res.score > 0, String(res.score));
  const st = T.getStats();
  ok("완료 횟수 1", st.byDiff.hard.count === 1);
  ok("최고 기록 저장", st.byDiff.hard.bestMs === 65000);
  ok("스트릭 1", st.streak === 1);
  T.recordWin("hard", 90000, 0, false);
  ok("느린 기록은 최고가 아니다", T.getStats().byDiff.hard.bestMs === 65000);
  ok("평균이 갱신된다", T.getStats().byDiff.hard.totalMs === 155000);

  console.log("== 9. 시간 표기 ==");
  ok("0:05", T.fmt(5000) === "0:05");
  ok("1:05", T.fmt(65000) === "1:05");
  ok("12:30", T.fmt(750000) === "12:30");
  ok("1:02:03", T.fmt(3723000) === "1:02:03");

  console.log("== 12. 점수와 레벨 ==");
  {
    // 어려울수록, 빠를수록 높다
    const easyPar   = T.scoreFor("easy",   T.PAR_MS.easy,   0, false);
    const hardPar   = T.scoreFor("hard",   T.PAR_MS.hard,   0, false);
    const expertPar = T.scoreFor("expert", T.PAR_MS.expert, 0, false);
    ok("난이도가 높을수록 점수가 높다", easyPar < hardPar && hardPar < expertPar,
       `${easyPar}/${hardPar}/${expertPar}`);

    const fast = T.scoreFor("normal", T.PAR_MS.normal * 0.4, 0, false);
    const slow = T.scoreFor("normal", T.PAR_MS.normal * 2.5, 0, false);
    const par  = T.scoreFor("normal", T.PAR_MS.normal, 0, false);
    ok("빠르면 더 받는다", fast > par && par > slow, `${fast}/${par}/${slow}`);
    ok("아무리 느려도 0 이 되지는 않는다", slow >= 10, String(slow));

    const noHint = T.scoreFor("normal", T.PAR_MS.normal, 0, false);
    const oneHint = T.scoreFor("normal", T.PAR_MS.normal, 1, false);
    const manyHint = T.scoreFor("normal", T.PAR_MS.normal, 20, false);
    ok("힌트를 쓰면 깎인다", oneHint < noHint);
    ok("힌트로 깎이는 폭은 절반까지", manyHint >= Math.round(noHint * 0.5) - 1,
       `${manyHint} vs ${noHint}`);

    ok("데일리는 가산된다",
       T.scoreFor("normal", T.PAR_MS.normal, 0, true) > noHint);

    // 레벨
    ok("0점은 레벨 1", T.levelOf(0).level === 1);
    ok("첫 레벨업은 500점", T.levelOf(499).level === 1 && T.levelOf(500).level === 2);
    ok("레벨이 오를수록 더 든다",
       T.levelOf(500 + 750 - 1).level === 2 && T.levelOf(500 + 750).level === 3);
    const l = T.levelOf(700);
    ok("진행도가 범위 안", l.into >= 0 && l.into < l.need, `${l.into}/${l.need}`);
    let prev = 0, mono = true;
    for (let sc = 0; sc < 20000; sc += 137) {
      const lv = T.levelOf(sc).level;
      if (lv < prev) mono = false;
      prev = lv;
    }
    ok("점수가 늘면 레벨은 줄지 않는다", mono);
  }

  console.log("== 11. 설명형 힌트 ==");
  const puz2 = await T.generatePuzzle(2);

  // 틀린 숫자가 있으면 무엇보다 먼저 그것을 지적해야 한다
  {
    const st = T.newState("normal", puz2.puzzle, puz2.solution);
    const empty = st.puzzle.findIndex(v => !v);
    st.grid[empty] = (st.solution[empty] % 9) + 1;
    const h = T.findHint(st);
    ok("틀린 숫자를 가장 먼저 지적", h && h.kind === "wrong" && h.cell === empty);
  }

  // 숨은 홑수 설명이 실제로 맞는지 — 그 단위에서 정말 한 칸뿐인가
  {
    const st = T.newState("normal", puz2.puzzle, puz2.solution);
    const h = T.findHint(st);
    ok("첫 힌트는 논리적 한 수다", h && (h.kind === "hiddenSingle" || h.kind === "nakedSingle"), h && h.kind);
    if (h && h.kind === "hiddenSingle") {
      const fits = h.unit.filter(i => {
        if (st.grid[i]) return false;
        return !T.PEERS[i].some(j => st.grid[j] === h.digit);
      });
      ok("설명대로 그 단위에서 들어갈 칸은 한 곳뿐", fits.length === 1 && fits[0] === h.cell);
      ok("근거로 짚은 칸에는 그 숫자가 실제로 있다",
         h.marks.every(i => st.grid[i] === h.digit), JSON.stringify(h.marks.map(i => st.grid[i])));
    }
  }

  // 힌트만 반복해서 끝까지 풀리는가 (엔진이 항상 전진하고 틀리지 않는지)
  for (const dd of T.DIFFS) {
    const made3 = dd.key === "normal" ? puz2 : await T.generatePuzzle(dd.level);
    T.S = T.newState(dd.key, made3.puzzle, made3.solution);
    const kinds = {};
    let guard = 0, allRight = true, allEmpty = true;
    T.setCoins(999);   // 여기서 보는 것은 힌트 엔진이지 코인 잔고가 아니다
    while (T.S.grid.some(v => !v) && guard++ < 200) {
      const h = T.findHint(T.S);
      if (!h) break;
      kinds[h.kind] = (kinds[h.kind] || 0) + 1;
      if (h.digit !== T.S.solution[h.cell]) allRight = false;
      if (T.S.grid[h.cell] !== 0) allEmpty = false;
      T.showHint();
      T.applyHint();
    }
    ok(T.diffName(dd.key) + " 힌트만으로 끝까지 풀린다", T.S.grid.every(v => v),
       "남은 빈칸 " + T.S.grid.filter(v => !v).length);
    ok(T.diffName(dd.key) + " 힌트가 늘 정답을 가리킨다", allRight);
    ok(T.diffName(dd.key) + " 힌트는 늘 빈칸을 가리킨다", allEmpty);
    console.log("   " + T.diffName(dd.key) + " 근거 분포: " + JSON.stringify(kinds));
  }

  console.log("== 16. 설정 ==");
  {
    T.drop(T.KEY_SETTINGS);
    const d = T.loadSettings();
    ok("기본값을 읽는다", JSON.stringify(d) === JSON.stringify(T.SETTING_DEFAULTS),
       JSON.stringify(d));
    T.setSetting("feedback", false);
    ok("설정이 바뀐다", T.settings.feedback === false);
    T.loadSettings();
    ok("설정이 저장된다", T.settings.feedback === false);

    // 진동을 끄면 navigator.vibrate 를 부르지 않는다
    let called = 0;
    const orig = global.navigator.vibrate;
    global.navigator.vibrate = () => { called++; return true; };
    T.buzz(10);
    ok("소리·진동을 끄면 진동도 부르지 않는다", called === 0);
    T.setSetting("feedback", true);
    T.buzz(10);
    ok("켜면 부른다", called === 1);
    global.navigator.vibrate = orig;

    // 알 수 없는 값이 들어 있어도 기본값으로 되돌아온다
    T.drop(T.KEY_SETTINGS);
    global.localStorage.setItem(T.KEY_SETTINGS, JSON.stringify({ feedback: "yes", bogus: 1 }));
    T.loadSettings();
    ok("잘못된 값은 기본값으로", T.settings.feedback === T.SETTING_DEFAULTS.feedback);
    ok("모르는 항목은 무시한다", T.settings.bogus === undefined);

    // 켜고 끄는 행은 설정 기본값과 하나씩 맞물린다
    const toggles = T.SETTING_ROWS.filter(r => !r.pick && !r.swatch);
    ok("설정 목록이 모든 항목을 덮는다",
       toggles.length === Object.keys(T.SETTING_DEFAULTS).length,
       `${toggles.length} toggles vs ${Object.keys(T.SETTING_DEFAULTS).length} defaults`);
    ok("설정 행과 기본값의 이름이 같다",
       toggles.every(r => r.key in T.SETTING_DEFAULTS),
       toggles.filter(r => !(r.key in T.SETTING_DEFAULTS)).map(r => r.key).join(","));
    // 메모 자동 채우기는 난이도 시트의 시작 버튼으로 고르므로 설정에는 없다
    ok("자동 메모는 설정에 없다", !T.SETTING_ROWS.some(r => r.key === "autoNotes"));
    // 값을 고르는 행 — 언어·화면은 게임 헤더에서 옮겨 왔고, 글꼴은 나중에 붙었다
    ok("값을 고르는 행",
       T.SETTING_ROWS.filter(r => r.pick).map(r => r.key).join(",") === "lang,theme,noteFont",
       T.SETTING_ROWS.filter(r => r.pick).map(r => r.key).join(","));
    ok("색은 스와치로 고른다", T.SETTING_ROWS.filter(r => r.swatch).map(r => r.key).join(",") === "accent");
  }

  console.log("== 17. 숫자 우선 입력 ==");
  {
    const made6 = await T.generatePuzzle(1);
    T.S = T.newState("easy", made6.puzzle, made6.solution);
    const empties = [];
    for (let i = 0; i < 81; i++) if (!T.S.puzzle[i]) empties.push(i);
    const target = empties[3], d = T.S.solution[target];

    // 고른 칸과 상관없이 지정한 칸에 들어간다
    T.S.selected = empties[0];
    T.placeDigit(target, d);
    ok("지정한 칸에 들어간다", T.S.grid[target] === d);
    ok("고른 칸은 건드리지 않는다", T.S.grid[empties[0]] === 0);

    // given 칸에는 들어가지 않는다
    const gi = T.S.puzzle.findIndex(v => v !== 0);
    const before = T.S.grid[gi];
    T.placeDigit(gi, 5);
    ok("given 칸은 바뀌지 않는다", T.S.grid[gi] === before);
  }

  console.log("== 15. 코인 ==");
  {
    // 앞선 테스트가 코인을 쓰고 벌었으므로, 기본값을 보려면 저장본부터 비운다
    T.drop(T.KEY_COINS);
    ok("저장본이 없으면 초기값", T.getCoins() === T.INITIAL_COINS, String(T.getCoins()));
    ok("초기값은 출시용으로 낮춰져 있다", T.INITIAL_COINS > 0 && T.INITIAL_COINS <= 20,
       "INITIAL_COINS=" + T.INITIAL_COINS);
    T.setCoins(3);
    ok("설정한 값이 읽힌다", T.getCoins() === 3);
    ok("쓸 수 있으면 깎인다", T.spendCoins(1) === true && T.getCoins() === 2);
    ok("모자라면 안 깎인다", T.spendCoins(5) === false && T.getCoins() === 2);
    T.addCoins(4);
    ok("벌면 늘어난다", T.getCoins() === 6);
    T.setCoins(-10);
    ok("음수로 내려가지 않는다", T.getCoins() === 0);

    // 기록을 지워도 코인은 남아야 한다
    T.setCoins(7);
    T.drop(T.KEY_STATS);
    ok("기록을 지워도 코인은 남는다", T.getCoins() === 7, String(T.getCoins()));

    // 힌트를 보면 하나 쓰고, 모자라면 힌트가 뜨지 않는다
    const made5 = await T.generatePuzzle(1);
    T.S = T.newState("easy", made5.puzzle, made5.solution);
    T.setCoins(1);
    T.showHint();
    ok("힌트를 보면 코인이 하나 준다", T.getCoins() === 0, String(T.getCoins()));
    T.applyHint();
    T.showHint();
    ok("코인이 없으면 힌트가 뜨지 않는다", T.hint === null);
    ok("코인이 음수가 되지 않는다", T.getCoins() === 0);
  }

  console.log("== 13. 자동 노트 ==");
  {
    const made4 = await T.generatePuzzle(2);
    const st = T.newState("normal", made4.puzzle, made4.solution);
    st.grid[st.puzzle.findIndex(v => !v)] = 0;      // 빈칸은 그대로 둔다
    const notes = T.computeAutoNotes(st);
    ok("81칸을 모두 돌려준다", notes.length === 81);

    let givenClean = true, hasAnswer = true, noPeerDigit = true, notEmpty = 0;
    for (let i = 0; i < 81; i++) {
      if (st.puzzle[i]) { if (notes[i] !== 0) givenClean = false; continue; }
      if (st.grid[i])   { if (notes[i] !== 0) givenClean = false; continue; }
      notEmpty++;
      // 정답 숫자는 반드시 후보에 남아 있어야 한다
      if (!(notes[i] & T.bit(st.solution[i]))) hasAnswer = false;
      // 이웃에 이미 있는 숫자는 후보에서 빠져야 한다
      for (const j of T.PEERS[i]) {
        if (st.grid[j] && (notes[i] & T.bit(st.grid[j]))) noPeerDigit = false;
      }
    }
    ok("이미 채워진 칸에는 메모가 없다", givenClean);
    ok("빈칸이 실제로 있다", notEmpty > 0, String(notEmpty));
    ok("정답 숫자는 후보에 남는다", hasAnswer);
    ok("이웃에 있는 숫자는 후보에서 빠진다", noPeerDigit);
  }

  console.log("== 14. 도움말 문구 ==");
  {
    const kh = T.I18N.ko.helpItems, eh = T.I18N.en.helpItems;
    ok("두 언어의 항목 수가 같다", kh.length === eh.length, `${kh.length} vs ${eh.length}`);
    ok("항목이 비어있지 않다", kh.length >= 3);
    const shaped = arr => arr.every(x => Array.isArray(x) && x.length === 2 &&
                                    typeof x[0] === "string" && x[0].length > 0 &&
                                    typeof x[1] === "string" && x[1].length > 0);
    ok("한국어 항목 형태가 맞다", shaped(kh));
    ok("영어 항목 형태가 맞다", shaped(eh));
  }

  console.log("== 10. 다국어 문자열 ==");
  const ko = T.I18N.ko, en = T.I18N.en;
  const kk = Object.keys(ko).sort(), ek = Object.keys(en).sort();
  ok("두 언어의 키 집합이 같다", JSON.stringify(kk) === JSON.stringify(ek),
     "ko에만: " + kk.filter(k => !(k in en)) + " / en에만: " + ek.filter(k => !(k in ko)));
  for (const k of kk) {
    ok("키 " + k + " 의 형태가 같다", typeof ko[k] === typeof en[k],
       typeof ko[k] + " vs " + typeof en[k]);
    if (typeof ko[k] === "string") {
      ok("키 " + k + " 가 비어있지 않다(ko)", ko[k].length > 0);
      ok("키 " + k + " 가 비어있지 않다(en)", en[k].length > 0);
    }
  }
  for (const d of T.DIFFS) {
    ok("난이도 이름 있음 " + d.key + " (ko)", typeof ko.diffNames[d.key] === "string");
    ok("난이도 이름 있음 " + d.key + " (en)", typeof en.diffNames[d.key] === "string");
  }
  // 실제 전환이 동작하는지
  T.applyLang("en");
  ok("영어로 바뀐다", T.diffName("hard") === "Hard", T.diffName("hard"));
  ok("영어 함수 문자열", en.hintsUsed(1) === "1 hint" && en.hintsUsed(2) === "2 hints");
  T.applyLang("ko");
  ok("한국어로 돌아온다", T.diffName("hard") === "어려움", T.diffName("hard"));

  console.log("== 18. 소리 ==");
  {
    // 진짜 소리는 낼 수 없으니, 만들어진 오실레이터 수로 "울렸는지"를 본다
    let made = 0;
    const node = () => ({ connect() {}, start() {}, stop() {} });
    class FakeAC {
      constructor() { this.state = "running"; this.currentTime = 0; this.destination = {}; }
      resume() { this.state = "running"; }
      createGain() {
        return { gain: { value: 0, setValueAtTime() {}, exponentialRampToValueAtTime() {}, cancelScheduledValues() {} },
                 connect() {} };
      }
      createOscillator() { made++; return Object.assign(node(), { type: "", frequency: { value: 0 } }); }
    }
    global.window.AudioContext = FakeAC;

    T.setSetting("feedback", true);
    made = 0; T.sfx("place");
    ok("효과음을 켜면 울린다", made === 1, String(made));
    made = 0; T.sfx("win");
    ok("완료음은 네 음", made === 4, String(made));
    T.setSetting("feedback", false);
    made = 0; T.sfx("place");
    ok("끄면 울리지 않는다", made === 0, String(made));
    made = 0; T.sfx("없는이름");
    ok("모르는 이름은 조용히 무시", made === 0);

    // 배경음은 게임을 보고 있을 때만 흐른다 — 끝난 판이나 열린 시트 위에서는 멈춘다
    const made7 = await T.generatePuzzle(1);
    T.S = T.newState("easy", made7.puzzle, made7.solution);
    T.closeOverlay();
    T.setSetting("feedback", true);
    T.view = "home"; T.syncMusic();
    ok("홈에서는 흐르지 않는다", T.musicPlaying() === false);
    T.view = "game"; T.syncMusic();
    ok("게임 화면에서 흐른다", T.musicPlaying() === true);
    T.setSetting("feedback", false); T.syncMusic();
    ok("끄면 멈춘다", T.musicPlaying() === false);
  }

  console.log("== 20. 실수 제한 ==");
  {
    const made8 = await T.generatePuzzle(1);
    T.S = T.newState("easy", made8.puzzle, made8.solution);
    T.closeOverlay();
    T.setSetting("mistakeLimit", true);

    // 빈칸에 정답이 아닌 숫자를 넣는다
    const blanks = [];
    for (let i = 0; i < 81; i++) if (!T.S.puzzle[i]) blanks.push(i);
    const wrongFor = i => (T.S.solution[i] % 9) + 1;   // 정답이 아닌 값

    ok("처음에는 실수가 없다", T.S.mistakes === 0);
    T.select(blanks[0]); T.inputDigit(wrongFor(blanks[0]));
    ok("틀리면 하나 오른다", T.S.mistakes === 1, String(T.S.mistakes));
    ok("아직 끝나지 않았다", T.S.done === false);

    // 맞는 숫자는 세지 않는다
    T.select(blanks[1]); T.inputDigit(T.S.solution[blanks[1]]);
    ok("맞으면 오르지 않는다", T.S.mistakes === 1, String(T.S.mistakes));

    T.select(blanks[2]); T.inputDigit(wrongFor(blanks[2]));
    T.select(blanks[3]); T.inputDigit(wrongFor(blanks[3]));
    ok("세 번째에서 판이 끝난다", T.S.mistakes === T.MISTAKE_MAX && T.S.done === true,
       `${T.S.mistakes} / done=${T.S.done}`);
    ok("진 판으로 표시된다", T.S.lost === true);
    ok("연속 완료가 끊긴다", T.getStats().streak === 0);
    ok("저장본이 남지 않는다", T.restoreGame() === null);

    // 끄면 세 번을 넘겨도 계속할 수 있다
    T.setSetting("mistakeLimit", false);
    const made9 = await T.generatePuzzle(1);
    T.S = T.newState("easy", made9.puzzle, made9.solution);
    T.closeOverlay();
    const blanks2 = [];
    for (let i = 0; i < 81; i++) if (!T.S.puzzle[i]) blanks2.push(i);
    for (let k = 0; k < 4; k++) {
      T.select(blanks2[k]); T.inputDigit((T.S.solution[blanks2[k]] % 9) + 1);
    }
    ok("끄면 끝나지 않는다", T.S.done === false && T.S.mistakes === 4,
       `${T.S.mistakes} / done=${T.S.done}`);
  }

  console.log("== 21. 메모 자동 지우기 ==");
  {
    const made10 = await T.generatePuzzle(1);
    T.S = T.newState("easy", made10.puzzle, made10.solution);
    T.setSetting("mistakeLimit", false);
    // 빈칸 하나를 고르고, 그 칸의 이웃 빈칸에 같은 후보를 적어 둔다
    let target = -1;
    for (let i = 0; i < 81 && target < 0; i++) if (!T.S.puzzle[i]) target = i;
    const d = T.S.solution[target];
    const peers = T.PEERS[target].filter(j => !T.S.grid[j]);
    for (const j of peers) T.S.notes[j] = T.bit(d);

    T.setSetting("autoClearNotes", true);
    T.select(target); T.inputDigit(d);
    ok("켜면 이웃의 그 후보가 지워진다", peers.every(j => (T.S.notes[j] & T.bit(d)) === 0));

    // 되돌리고 끈 채로 다시
    T.undo();
    for (const j of peers) T.S.notes[j] = T.bit(d);
    T.setSetting("autoClearNotes", false);
    T.select(target); T.inputDigit(d);
    ok("끄면 후보가 그대로 남는다", peers.every(j => (T.S.notes[j] & T.bit(d)) !== 0));
    T.setSetting("autoClearNotes", true);
  }

  console.log("== 19. 메모 글꼴과 테마 색 ==");
  {
    T.applyNoteFont("serif");
    ok("고른 글꼴이 남는다", T.noteFont() === "serif");
    T.applyNoteFont("없는글꼴");
    ok("모르는 값은 기본으로", T.noteFont() === "andika", T.noteFont());
    ok("숫자 글꼴이 목록에 있다", "andika" in T.NOTE_FONTS);

    T.applyAccent("teal");
    ok("고른 색이 남는다", T.accentKey() === "teal");
    T.applyAccent("없는색");
    ok("모르는 값은 기본으로", T.accentKey() === "indigo");
    for (const [k, a] of Object.entries(T.ACCENTS)) {
      ok("색 " + k + " 은 밝게·어둡게 값을 모두 갖는다",
         /^#[0-9a-f]{6}$/i.test(a.light) && /^#[0-9a-f]{6}$/i.test(a.dark) &&
         /^#[0-9a-f]{6}$/i.test(a.ink) && /^#[0-9a-f]{6}$/i.test(a.inkDark));
    }
  }

  console.log("\n통과 " + pass + " / 실패 " + fail);
  process.exit(fail ? 1 : 0);
})();

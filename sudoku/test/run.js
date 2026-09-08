#!/usr/bin/env node
/* 스도쿠 테스트 전체 실행:  node sudoku/test/run.js
   저장소에 테스트 프레임워크가 없어 각 파일이 스스로 단언하고 종료 코드로 알린다. */
const { spawnSync } = require("child_process");
const path = require("path");

const files = ["engine.test.js", "game.test.js", "daily.test.js"];
let failed = 0;

for (const f of files) {
  console.log("\n──────── " + f + " ────────");
  const r = spawnSync(process.execPath, [path.join(__dirname, f)], { stdio: "inherit" });
  if (r.status !== 0) failed++;
}

console.log("\n════════════════════════════");
console.log(failed ? `${failed}개 파일 실패` : `${files.length}개 파일 모두 통과`);
process.exit(failed ? 1 : 0);

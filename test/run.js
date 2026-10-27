#!/usr/bin/env node
/* 테스트 전체 실행:  node test/run.js
   저장소에 테스트 프레임워크가 없어 각 *.test.js 가 스스로 단언하고 종료 코드로 알린다. */
const { spawnSync } = require("child_process");
const fs = require("fs");
const path = require("path");

const files = fs.readdirSync(__dirname).filter(f => f.endsWith(".test.js")).sort();
let failed = 0;

for (const f of files) {
  console.log("\n──────── " + f + " ────────");
  const r = spawnSync(process.execPath, [path.join(__dirname, f)], { stdio: "inherit" });
  if (r.status !== 0) failed++;
}

console.log("\n════════════════════════════");
console.log(failed ? `${failed}개 파일 실패` : `${files.length}개 파일 모두 통과`);
process.exit(failed ? 1 : 0);

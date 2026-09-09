const fs=require("fs");
const src=fs.readFileSync(require("path").join(__dirname, "..", "index.html"),"utf8")
  .match(/<script>\n([\s\S]*?)\n<\/script>/)[1];
const el=()=>({classList:{add(){},remove(){},toggle(){}},dataset:{},append(){},appendChild(){},
  setAttribute(){},addEventListener(){},querySelector:()=>({setAttribute(){}}),children:[],
  textContent:"",hidden:false,offsetWidth:1,style:{},disabled:false,
  querySelectorAll:()=>[]});
global.document={documentElement:{dataset:{}},createElement:el,createDocumentFragment:el,
  getElementById:el,querySelector:()=>null,addEventListener(){}};
global.window={addEventListener(){},matchMedia:()=>({matches:false})};
global.navigator={}; global.location={protocol:"file:",hostname:""}; global.setInterval=()=>0;
const mem=new Map();
global.localStorage={getItem:k=>mem.has(k)?mem.get(k):null,setItem:(k,v)=>mem.set(k,String(v)),
  removeItem:k=>mem.delete(k)};
(0,eval)(src+"\n;globalThis.__T={generateDaily,generatePuzzle,dailyDiff,dateKey,todayKey,parseKey,"
 +"seedFrom,mulberry32,countSolutions,rate,diffOf,DAILY_DIFF,markDaily,dailyRecords,RATE_MIN};");
const T=globalThis.__T;
let pass=0,fail=0;
const ok=(n,c,e)=>{ if(c) pass++; else {fail++; console.log("  실패: "+n+(e?"  → "+e:""));} };

(async()=>{
  console.log("== 데일리 결정론 ==");
  const key="2026-09-09";
  const a=await T.generateDaily(key), b=await T.generateDaily(key);
  ok("같은 날짜는 같은 문제", a.puzzle.join("")===b.puzzle.join(""));
  ok("같은 날짜는 같은 해",   a.solution.join("")===b.solution.join(""));
  const c=await T.generateDaily("2026-09-10");
  ok("다른 날짜는 다른 문제", a.puzzle.join("")!==c.puzzle.join(""));
  ok("데일리도 유일해", T.countSolutions(a.puzzle,2)===1);

  console.log("== 데일리 난이도 ==");
  ok("요일 표가 7개", T.DAILY_DIFF.length===7);
  // 2026-09-09 는 수요일 → 표의 3번째(hard)
  ok("수요일은 어려움", T.dailyDiff("2026-09-09")==="hard", T.dailyDiff("2026-09-09"));
  ok("일요일은 쉬움",   T.dailyDiff("2026-09-13")==="easy", T.dailyDiff("2026-09-13"));
  const lv=T.diffOf(T.dailyDiff(key)).level;
  const r=T.rate(a.puzzle);
  ok("데일리도 난이도 범위 안", r<=lv && r>=T.RATE_MIN[lv], `rate=${r} 목표=${lv}`);

  console.log("== 날짜 키 ==");
  ok("dateKey 형식", T.dateKey(new Date(2026,8,9))==="2026-09-09", T.dateKey(new Date(2026,8,9)));
  ok("한 자리 달·일 0채움", T.dateKey(new Date(2026,0,5))==="2026-01-05");
  ok("parseKey 왕복", T.dateKey(T.parseKey("2026-12-31"))==="2026-12-31");

  console.log("== 기록 저장 ==");
  T.markDaily(key, 300000, 1, 250);
  T.markDaily(key, 400000, 0, 300);   // 더 느린 기록은 덮지 않는다
  ok("더 좋은 기록만 남는다", T.dailyRecords()[key].ms===300000, JSON.stringify(T.dailyRecords()[key]));
  T.markDaily(key, 200000, 0, 400);
  ok("더 빠르면 갱신된다", T.dailyRecords()[key].ms===200000);

  console.log("== 씨앗 함수 ==");
  ok("같은 문자열 같은 씨앗", T.seedFrom("abc")===T.seedFrom("abc"));
  ok("다른 문자열 다른 씨앗", T.seedFrom("abc")!==T.seedFrom("abd"));
  const g=T.mulberry32(12345); const v1=[g(),g(),g()];
  const g2=T.mulberry32(12345); const v2=[g2(),g2(),g2()];
  ok("같은 씨앗 같은 수열", JSON.stringify(v1)===JSON.stringify(v2));
  ok("난수가 0~1 범위", v1.every(x=>x>=0&&x<1));

  console.log("\n통과 "+pass+" / 실패 "+fail);
  process.exit(fail?1:0);
})();

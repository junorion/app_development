// 앱이 https://junorion.github.io/<앱>/ 으로 옮겨갔다. 옛 경로에 설치된 서비스워커를
// 이 파일로 교체해 스스로 해제하고, 열려 있는 창을 다시 불러 리다이렉트 페이지를 타게 한다.
// 캐시는 지우지 않는다 — 캐시 저장소는 출처 단위라 새 경로의 앱 캐시까지 지울 수 있다.
self.addEventListener("install", () => self.skipWaiting());
self.addEventListener("activate", (event) => {
  event.waitUntil((async () => {
    await self.registration.unregister();
    const clients = await self.clients.matchAll({ type: "window" });
    clients.forEach((c) => c.navigate(c.url));
  })());
});

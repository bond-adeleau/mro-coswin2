const CACHE = "assistant-coswin-v3";
const APP_FILES = [
  "/Assistant%20creation.html",
  "/manifest.json",
  "/service-worker.js"
];

self.addEventListener("install", event => {
  event.waitUntil(caches.open(CACHE).then(cache => cache.addAll(APP_FILES)));
  self.skipWaiting();
});

self.addEventListener("activate", event => {
  event.waitUntil(
    caches.keys()
      .then(keys => Promise.all(keys.filter(key => key !== CACHE).map(key => caches.delete(key))))
      .then(() => self.clients.claim())
  );
});

self.addEventListener("fetch", event => {
  if (event.request.method !== "GET") return;
  if (event.request.url.endsWith("/Assistant%20creation.html")) {
    event.respondWith(
      fetch(event.request).then(response => {
        const copie = response.clone();
        caches.open(CACHE).then(cache => cache.put(event.request, copie));
        return response;
      }).catch(() => caches.match(event.request))
    );
    return;
  }
  event.respondWith(
    caches.match(event.request).then(cached => cached || fetch(event.request))
  );
});
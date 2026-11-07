// 같이 읽는 방 — service worker: the app shell loads instantly (and offline); live data always goes to the network.
const VERSION = '20261107211951';
const CACHE = 'rr-' + VERSION;
const SHELL = ['./', './index.html', './config.js', './manifest.webmanifest', './fonts/Ownglyph_PDH.ttf', './icons/icon-192.png', './icons/icon-512.png', './icons/apple-touch-icon.png'];
const LIVE = /supabase\.co|vercel\.app|kakaocdn\.net|daumcdn\.net|version\.txt/;

self.addEventListener('install', e => {
  e.waitUntil(caches.open(CACHE).then(c => c.addAll(SHELL)).then(() => self.skipWaiting()));
});
self.addEventListener('activate', e => {
  e.waitUntil(caches.keys().then(keys => Promise.all(keys.filter(k => k !== CACHE).map(k => caches.delete(k)))).then(() => self.clients.claim()));
});
self.addEventListener('fetch', e => {
  const req = e.request;
  if (req.method !== 'GET') return;
  const url = new URL(req.url);
  if (LIVE.test(url.href)) return;   // realtime data, book search, covers, version check: network only
  const isPage = url.origin === location.origin && (url.pathname.endsWith('/') || url.pathname.endsWith('/index.html'));
  if (isPage) {
    // network first so new versions arrive; the cached shell is the offline fallback
    e.respondWith(fetch(req).then(r => { if (r.ok) { const copy = r.clone(); caches.open(CACHE).then(c => c.put('./index.html', copy)); } return r; }).catch(() => caches.match('./index.html')));
    return;
  }
  if (url.origin === location.origin || url.hostname === 'cdn.jsdelivr.net' || url.hostname.endsWith('gstatic.com') || url.hostname.endsWith('googleapis.com')) {
    // fonts, icons, scripts: cache first
    e.respondWith(caches.match(req).then(hit => hit || fetch(req).then(r => { if (r.ok) { const copy = r.clone(); caches.open(CACHE).then(c => c.put(req, copy)); } return r; })));
  }
});

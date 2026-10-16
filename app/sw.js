// Bump on every change to any precached file, or installed copies keep running old code.
const CACHE = 'nk-v1';

const ASSETS = [
  './',
  'index.html',
  'help.html',
  'manifest.webmanifest',
  'favicon.ico',
  'css/font-awesome.css',
  'css/normalize.css',
  'css/main.css',
  'css/help.css',
  'fonts/fontawesome-webfont.woff2',
  'images/icon.svg',
  'images/icon-192.png',
  'images/icon-512.png',
  'images/apple-touch-icon.png',
  'js/lib/Tone.js',
  'js/config.js',
  'js/theme.js',
  'js/canvashelper.js',
  'js/musiclibrary.js',
  'js/parser.js',
  'js/settings.js',
  'js/soundengine.js',
  'js/noteengine.js',
  'js/chordengine.js',
  'js/scaleengine.js',
  'js/commandengine.js',
  'js/app.js',
  'js/pianoview.js',
  'js/main.js',
];

self.addEventListener('install', function(event) {
  event.waitUntil(
    caches.open(CACHE)
      .then(function(cache) {
        return cache.addAll(ASSETS.map(function(url) {
          return new Request(url, { cache: 'no-cache' });
        }));
      })
      .then(function() {
        return self.skipWaiting();
      })
  );
});

self.addEventListener('activate', function(event) {
  event.waitUntil(
    caches.keys()
      .then(function(keys) {
        return Promise.all(keys.filter(function(key) {
          return key !== CACHE;
        }).map(function(key) {
          return caches.delete(key);
        }));
      })
      .then(function() {
        return self.clients.claim();
      })
  );
});

self.addEventListener('fetch', function(event) {
  const request = event.request;
  if (request.method !== 'GET' || new URL(request.url).origin !== self.location.origin) {
    return;
  }

  // Pages: network first so updates show up, cache when offline. ignoreSearch serves ?q= links.
  if (request.mode === 'navigate') {
    event.respondWith(
      fetch(request, { cache: 'no-cache' }).catch(function() {
        return caches.match(request, { ignoreSearch: true })
          .then(function(response) {
            return response || caches.match('./');
          });
      })
    );
    return;
  }

  // Assets: cache first (fonts are requested with ?v= query strings).
  event.respondWith(
    caches.match(request, { ignoreSearch: true }).then(function(response) {
      return response || fetch(request, { cache: 'no-cache' });
    })
  );
});

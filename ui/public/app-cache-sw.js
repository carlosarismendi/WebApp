const CACHE_NAME = 'adi-social-v1'
const urlsToCache = [
  '/',
  '/js/app.js',
  '/js/chunk-vendors.js',
  '/main.js',
  '/utils.js',
  '/favicon.ico',
  '/index.html',
  '/home',
  '/users',
  '/users/sign-in',
  '/users/sign-up',
  '/account-settings',
  '/profile/',
  '/new-post',
  '/errors/404',
  '/errors/500',
]

self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME)
      .then((cache) => {
        return cache.addAll(urlsToCache)
      })
  )
})

self.addEventListener('fetch', (event) => {
  event.respondWith(
    caches.match(event.request)
      .then((response) => {
        if (response)
          return response
        else
          return fetch(event.request)
      })
  )
})
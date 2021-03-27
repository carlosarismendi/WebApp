if ('serviceWorker' in navigator) {
  window.addEventListener('load', function() {
    // Registers the firebase service worker for push notifications
    navigator.serviceWorker.register('/firebase-messaging-sw.js')
      .then(() => {
        console.log('Push notifications servicer worker registered')
      })
      .catch((err) => {
        console.log('Push notifications servicer worker not registered: ', err)
      })

    // Registers the service worker for app UI cache.
    navigator.serviceWorker.register('/app-cache-sw.js')
      .then(() => {
        console.log('App cache servicer worker registered')
      })
      .catch((err) => {
        console.log('App cache servicer worker not registered: ', err)
      })
  });
}
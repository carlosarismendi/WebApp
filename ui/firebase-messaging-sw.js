self.importScripts('https://www.gstatic.com/firebasejs/8.2.1/firebase-app.js')
self.importScripts('https://www.gstatic.com/firebasejs/8.2.1/firebase-messaging.js')

const firebaseConfig = {
  apiKey: "",
  authDomain: "",
  projectId: "",
  storageBucket: "",
  messagingSenderId: "",
  appId: "",
  measurementId: ""
};

self.firebase.initializeApp(firebaseConfig)

const messaging = self.firebase.messaging()

messaging.onBackgroundMessage(function(payload) {
  console.log('sw: ', payload)
  const title = payload.data.title
  const options = {
    body: payload.data.message,
    icon: payload.data.image
  }

  const event = new CustomEvent('notification', { detail: payload.data })
  self.dispatchEvent(event)

  self.registration.showNotification(title, options)
});
self.importScripts('https://www.gstatic.com/firebasejs/8.2.1/firebase-app.js')
self.importScripts('https://www.gstatic.com/firebasejs/8.2.1/firebase-messaging.js')

// Firebase configuration and authorization properties
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

// Messaging API
const messaging = self.firebase.messaging()

// Notification when the user is not "on focus" in our App.
// If the user has push notifications activated in his device, he will receive a push notification.
messaging.onBackgroundMessage(function(payload) {
  const title = payload.data.title

  const options = {
    body: payload.data.message,
    icon: payload.data.image
  }

  self.registration.showNotification(title, options)
});
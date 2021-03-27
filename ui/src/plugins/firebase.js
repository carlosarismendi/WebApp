import firebase from 'firebase/app'
import 'firebase/firebase-messaging'

import axios from './vue-axios'


// Firebase configuration and authorization properties
const firebaseConfig = {
  apiKey: "AIzaSyAwrp1CX13QHG6MwXuAR81Y0ruB4evLGzw",
  authDomain: "adi-practica4.firebaseapp.com",
  projectId: "adi-practica4",
  storageBucket: "adi-practica4.appspot.com",
  messagingSenderId: "43732702611",
  appId: "1:43732702611:web:af140f1cb7a869dd308466",
  measurementId: "G-SXBFZ951S2"
};

firebase.initializeApp(firebaseConfig)

// Messaging API
const messaging = firebase.messaging()

// Request the user permission to receive push notifications
Notification.requestPermission()
  .then(() => {
    // Token  that identifies the user device where push notifications must be sent
    return messaging.getToken()
  })
  .then((token) => {
    // Save the previous token in the database so it can be used whenever neccesary
    axios.put('users/firebase-token', { firebaseToken: token })
      .catch(err => {
        console.log(err)
        window.location.replace(`${process.env.VUE_APP_BASE_URL}errors/500`);
      })
  })
  .catch(err => {
    console.log(err)
  })

// Notification when the user is "on focus" in our App.
// This dispatches an event that is listened by the Vue component in charge of managing notifications.
// In this case, it is listened by the component NavBarPrivate.
messaging.onMessage((payload) => {
  const event = new CustomEvent('notification', { detail: payload.data })
  self.dispatchEvent(event)
})
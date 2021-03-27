const admin = require('firebase-admin')
const { execProcedure } = require('./dataBase');

function initFirebase() {
  const serviceAccount = require('./keys/keys.json')
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount)
  })
}

initFirebase()

function sendPushToOneUser(notification) {
  const promise = new Promise((resolve, reject) => {
    const callback = (returnObject) => {
      // Error creating notification into DB
      if (!returnObject || returnObject.status < 0) {
        reject('Notification could not be created into DB.')
      } else {
        // If the userToken is not null (the user has granted permission for push notifications)
        // then a notification is sent
        try {
          if (notification.userToken) {
            let message = {
              token: notification.userToken,
              data: {
                idUserCreator: `${notification.idUserCreator}`,
                idUserTarget: `${notification.idUserTarget}`,
                idNotification: `${returnObject.data.idNotification}`,
                idNotificationType: `${notification.idNotificationType}`,
                title: notification.title,
                message: notification.message
              }
            }

            if (notification.image)
              message.data.image = notification.image

            sendMessage(message)
          }
        } catch (err) {
          reject(err)
        }

        resolve()
      }
    }

    execProcedure('usp_notificationCreate', notification, notification.idUserCreator, callback)
  })

  return promise
}

function sendMessage(message) {
  admin.messaging().send(message)
    .then()
    .catch((err) => {
      console.log('Error sending message: ', err)
    })
}

function deleteNotification(idNotification, idUser) {
  const promise = new Promise((resolve, reject) => {
    const callback = (returnObject) => {
      if (!returnObject) {
        reject('Error in database')
      } else if(returnObject.status < 0) {
        reject(`Notification could not be deleted.\n${returnObject.error}`)
      } else {
        resolve()
      }
    }

    execProcedure('usp_notificationDelete', { idNotification: idNotification }, idUser, callback)
  })

  return promise
}

module.exports = {
  sendPushToOneUser,
  deleteNotification
}
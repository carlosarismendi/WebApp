import Vue from 'vue'

const user = {
  setLogin: (token, idUser) => {
    localStorage.setItem('jwt-token', token);
    Vue.axios.defaults.headers.common['Authorization'] = `Bearer ${token}`

    localStorage.setItem('idUser', idUser)
  },
  removeLogin: () => {
    localStorage.removeItem('idUser')
    localStorage.removeItem('jwt-token')
    localStorage.removeItem('name')
    localStorage.removeItem('nickname')
    localStorage.removeItem('profileImage')
    Vue.axios.defaults.headers.common['Authorization'] = null
  },
  isAuthenticated: () => {
    let jwtToken = localStorage.getItem('jwt-token');

    if (jwtToken) {
      Vue.axios.defaults.headers.common['Authorization'] = `Bearer ${jwtToken}`
      return true
    }

    return false
  },
  getIdUser: () => {
    return localStorage.getItem('idUser')
  },
  getProfileImage: () => {
    return localStorage.getItem('profileImage')
  },
  getNickname: () => {
    return localStorage.getItem('nickname')
  },
  getName: () => {
    return localStorage.getItem('name')
  },
  setProfileImage: (image) => {
    localStorage.setItem('profileImage', image)
  },
  setNickname: (nickname) => {
    localStorage.setItem('nickname', nickname)
  },
  setName: (name) => {
    localStorage.setItem('name', name)
  }
}

const notification = {
  setNotification(notification) {
    localStorage.setItem('notification', notification)
  },
  removeNotification() {
    localStorage.removeItem('notification')
  },
  getNotification() {
    return localStorage.getItem('notification')
  }
}

const UTILS = {
  user: user,
  notification: notification
}

export default UTILS

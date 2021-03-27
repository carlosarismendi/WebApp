import Vue from 'vue'
import axios from 'axios'
import VueAxios from 'vue-axios'
// import router from '../router'
import UTILS from '@/utils'

axios.defaults.baseURL = process.env.VUE_APP_API_URL
axios.defaults.headers.common['Access-Control-Allow-Origin'] = process.env.VUE_APP_API_URL

// Add a response interceptor
axios.interceptors.response.use(function (response) {
  return response
}, function (error) {
  if (error.response.status === 401) {
    UTILS.user.removeLogin()
    // router.push({ name: 'users.sign-in' })
  } else {
    return Promise.reject(error)
  }
}
)

Vue.use(VueAxios, axios)

export default axios

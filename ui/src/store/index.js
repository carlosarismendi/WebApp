import Vue from "vue";
import Vuex from "vuex";

Vue.use(Vuex);

export default new Vuex.Store({
  state: {
    profileImage: null,
    nickname: null,
    name: null,
    notification: null
  },
  mutations: {
    updateProfileImage (state, newValue) {
      state.profileImage = newValue
    },
    updateNickname (state, newValue) {
      state.nickname = newValue
    },
    updateName (state, newValue) {
      state.name = newValue
    },
    updateNotification (state, newValue) {
      state.notification = newValue
    }
  },
  actions: {},
  modules: {}
});

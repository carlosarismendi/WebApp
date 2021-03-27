<template>
  <div>
    <b-navbar toggleable="lg" type="light" variant="light" class="mx-0 py-0 shadow-sm" fixed>
      <b-navbar-brand>
        <router-link class="btn btn-light my-0 mx-1 py-4" to="/">AdiSocial</router-link>
      </b-navbar-brand>

      <b-navbar-toggle class="border-0" target="nav-collapse"></b-navbar-toggle>

      <b-collapse id="nav-collapse" is-nav class="text-center">
        <b-navbar-nav>
          <router-link class="btn btn-light my-0 mx-1 py-4" to="/">Posts</router-link>
          <router-link class="btn btn-light my-0 mx-1 py-4" to="/users">Users</router-link>
        </b-navbar-nav>

        <b-navbar-nav class="ml-auto">
          <router-link class="btn btn-light my-0 ml-1 mr-0 py-3 px-2" :to="{ name: 'app.profile', params: { id: idUser } }">
            <b-avatar
              :src="profileImage"
              variant="primary"
              :size="50"
            ></b-avatar>
          </router-link>
        </b-navbar-nav>

        <router-link class="btn btn-light my-0 ml-0 mr-1 py-4" :to="{ name: 'app.profile', params: { id: idUser } }">@{{ nickname }}</router-link>

        <b-navbar-nav>
          <b-nav-item-dropdown right no-caret class="m-0 p-0" menu-class="p-0 m-0" @hidden="updateNotifications">
            <template #button-content>
              <span :class="notificationCssClass">Notifications</span>
            </template>

            <div v-show="notifications.length > 0" :key="notifications.length">
              <b-dropdown-item v-for="(notification, index) in notifications" :key="index" link-class="p-0 m-0">
                <Notification :notification="notification" @updateFollow="updateFollow"></Notification>
              </b-dropdown-item>
            </div>
            <b-dropdown-item v-show="notifications.length < 1">
              No notifications.
            </b-dropdown-item>
          </b-nav-item-dropdown>
        </b-navbar-nav>

        <b-navbar-nav>
          <router-link class="btn btn-light my-0 mx-1 py-4" :to="{ name: 'app.account-settings' }">Settings</router-link>
          <button class="btn btn-light my-0 mx-1 py-4" @click="logOut">Log out</button>
        </b-navbar-nav>
      </b-collapse>
    </b-navbar>
  </div>
</template>
<script>
import UTILS from '@/utils'
import Notification from '../notification/Notification'

export default {
  name: 'NavBarPrivate',
  components: {
    Notification
  },
  data() {
    return {
      idUser: UTILS.user.getIdUser(),
      notifications: [],
      notificationCssClass: ''
    }
  },
  methods: {
    logOut () {
      UTILS.user.removeLogin()
      this.$router.push({ name: 'users.sign-in' })
    },
    toggleNotificationCssClass () {
      if (this.notifications.length > 0) {
        this.notificationCssClass = 'font-weight-bold text-primary'
      } else {
        this.notificationCssClass = 'font-weight-normal text-dark'
      }
    },
    getNotifications () {
      this.axios.get('notifications')
        .then(res => {
          if (res.data.data && res.data.data.notifications) {
            this.notifications = this.notifications.concat(res.data.data.notifications)
          }

          this.toggleNotificationCssClass()
        })
        .catch(e => {
          console.log(e)
          this.$router.push({ name: 'app.errors', params: { error: '500' } })
        })
    },
    // When a pending follow request notification is Accepted or Rejected, all the notifications of the same type
    // between that pair of users (UserFollower and UserFollowed) are deleted.
    updateFollow (follow) {
      this.axios.put('follows', follow)
        .then((res) => {
          if (res.data.status < 0) {
            return
          }

          this.notifications = this.notifications.filter(item => {
            item.idNotificationType != follow.idNotificationType
              && item.idUserCreator != follow.idUserFollower
          });

          this.toggleNotificationCssClass()
        })
        .catch((err) => {
          console.log(err)
          this.$router.push({ name: 'app.errors', params: { error: '500' } })
        });
    },
    // When the user clicks on the Notifications button, once the dropdown list is hidden,
    // all notifications that are not a pending follow request (those that must be Accepted or Rejected),
    // are removed.
    updateNotifications () {
      for (let i = 0; i < this.notifications.length; ++i) {
        const notification = this.notifications[i]

        if (notification.idNotificationType == 2) {
          continue
        }

        this.axios.delete(`notifications/${notification.idNotification}`)
          .then((res) => {
            if (res.data.status < 0) {
              return
            }

            this.notifications = this.notifications.filter(item => item.idNotification != notification.idNotification);
            i -= 1
            this.toggleNotificationCssClass()
          })
          .catch((err) => {
            console.log(err)
            this.$router.push({ name: 'app.errors', params: { error: '500' } })
          })
      }
    }
  },
  computed: {
    profileImage () {
      const storeImg = this.$store.state.profileImage
      const localStorageImg = UTILS.user.getProfileImage()

      return storeImg ? storeImg : localStorageImg
    },
    nickname () {
      const storeNick = this.$store.state.nickname
      const localStorageNick = UTILS.user.getNickname()

      return storeNick ? storeNick : localStorageNick
    }
  },
  created () {
    // When the app is created, the user notifications stored in the databased and
    // not read/accepted/rejected are fetched
    this.getNotifications()

    // Listens to the event dispatched by the firebase push notifications plugin.
    // This captures the notification data and stores it in the application so the user can see it
    // by clicking on the Notifications button in the NavBar.
    self.addEventListener('notification', (event) => {
      const notif = event.detail

      this.notifications = this.notifications.filter(item => {
        item.idNotificationType != notif.idNotificationType
          && item.idUserCreator != notif.idUserCreator
      });

      this.notifications.push(notif)
      this.toggleNotificationCssClass()
    })
  }
}
</script>

<style scoped>
.dropdown-item>a {
  padding: 0!important;
}
</style>
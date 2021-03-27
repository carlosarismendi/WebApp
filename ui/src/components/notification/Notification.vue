<template>
  <div class="w-100 rounded m-0 p-0">
    <b-card>
      <div class="d-flex">
        <div class="my-auto">
          <b-avatar variant="primary" :src="notification.image" size="50px"></b-avatar>
        </div>

        <div id="title-and-message" class="my-auto  ml-1 text-left">
          <div id="title" class="font-weight-bold">{{  notification.title }}</div>
          <div id="message">{{ notification.message }}</div>
        </div>
      </div>

      <div id="btns" class="text-center mt-2" v-if="notification.idNotificationType == 2">
        <button class="btn btn-primary mr-1" @click="manageNotification(2)">Accept</button>
        <button class="btn btn-light border border-primary ml-1" @click="manageNotification(1)">Reject</button>
      </div>
    </b-card>
  </div>
</template>

<script>
export default {
  name: 'Notification',
  props: {
    notification: { type: Object }
  },
  methods: {
    manageNotification (value) {
      if (this.notification.idNotificationType == 2) { // Follow type request pending
        const follow = {
          idNotification: this.notification.idNotification,
          idUserFollower: this.notification.idUserCreator,
          idRequestStatus: value
        }

        this.$emit('updateFollow', follow)
      }
    }
  }
}
</script>

<style scoped>
#title-and-message {
  width: 60% !important;
  font-size: 0.9em;
}

</style>
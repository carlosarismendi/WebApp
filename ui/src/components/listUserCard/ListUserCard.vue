<template>
  <div>
    <div v-for="(user, index) in users" :key='index'>
      <UserCard :user="user" :followed="followed" class="mt-4 rounded mx-auto"></UserCard>
    </div>
  </div>
</template>

<script>
import UserCard from '../usercard/UserCard'

export default {
  name: 'ListUserCard',
  components: {
    UserCard
  },
  props: {
    users: { type: Array, required: false }
  },
  computed: {
    followed () {
      return false
    }
  }
}
</script>
<template>
  <div class="container">
    <div class="row">
      <div v-for="(post, index) in posts" :key='index' class="col-4 px-1 py-0">
        <div class="mt-4 p-0" @click="openDetails(post)">
          <PostMini :post="post"></PostMini>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import PostMini from '../posts/postmini/PostMini'

export default {
  name: 'ListPostsMini',
  components: {
    PostMini
  },
  props: {
    posts: { type: Array, required: false }
  },
  methods: {
    openDetails(post) {
      this.$emit('openDetails', post)
    }
  }
}
</script>
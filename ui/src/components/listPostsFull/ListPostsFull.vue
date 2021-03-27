<template>
  <div class="container">
    <div class="row">
      <div class="col-sm-12 col-md-8 col-lg-6 m-auto">
        <div v-for="(post, index) in posts" :key='index'>
          <PostFull :post="post" class="mt-4 rounded mx-auto"></PostFull>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import PostFull from '../posts/postfull/PostFull'

export default {
  name: 'ListPostsFull',
  components: {
    PostFull
  },
  props: {
    posts: { type: Array, required: false }
  }
}
</script>
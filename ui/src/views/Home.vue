<template>
  <div class="container bg-white py-3">
    <b-overlay :show="showOverlay" rounded="sm" no-wrap opacity="0.6"></b-overlay>
    <b-alert
      variant="danger"
      dismissible
      :show="showError"
      @dismissed="resetError()"
    >
      {{errorMessage}}
    </b-alert>
    <ListPostsFull :posts="posts"></ListPostsFull>
    <div class="text-center">
      <button class="mt-4 btn btn-primary" @click="nextPage" v-show="pagination.nextPageBtn">View more</button>
    </div>
  </div>
</template>

<script>
import ListPostsFull from '../components/listPostsFull/ListPostsFull'

export default {
  name: 'Home',
  components: {
    ListPostsFull
  },
  data() {
    return {
      posts: [],
      pagination: {
        prev: null,
        next: null,
        limit: null,
        count: 0,
        totalRegs: 0,
        nextPageBtn: true
      },
      showOverlay: false,
      showError: false,
      errorMessage: ''
    }
  },
  methods: {
    resetError () {
      this.showError = false
      this.errorMessage = null
    },
    nextPage() {
      this.getAllPosts()
    },
    async getAllPosts() {
      this.showOverlay = true

      const params = {
        prev: this.pagination.prev,
        next: this.pagination.next,
        limit: this.pagination.limit
      }

      this.axios.get('posts/all', { params })
        .then(res => {
          if (res.data.status < 0) {
            this.showError = true
            this.errorMessage = res.data.error
          } else {
            this.posts = this.posts.concat(res.data.data.posts)
            this.pagination.prev = res.data.data.prev
            this.pagination.next = res.data.data.next
            this.pagination.count = res.data.data.count
            this.pagination.totalRegs = res.data.data.totalRegs

            if (this.pagination.count < this.pagination.limit) {
              this.pagination.nextPageBtn = false
            }
          }
        })
        .catch(e => {
          console.log(e)
          this.showError = true
          this.errorMessage = 'Internal error'
          this.$router.push({ name: 'app.errors', params: { error: '500' } })
        })
        .finally(() => {
          this.showOverlay = false
        })
    }
  },
  created() {
    this.getAllPosts()
  }
}
</script>

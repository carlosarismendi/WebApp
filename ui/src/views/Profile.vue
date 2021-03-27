<template>
  <div class="container p-0">
    <b-overlay :show="showOverlay" rounded="sm" no-wrap opacity="0.6"></b-overlay>
    <b-alert
      variant="danger"
      dismissible
      :show="showError"
      @dismissed="resetError()"
    >
      {{errorMessage}}
    </b-alert>

    <b-modal ref="follow-modal" :title="followModal.title" size="md" @hide="resetFollowModal" centered scrollable hide-footer>
      <div v-if="followModal.follows.length > 0">
        <ListUserCard :users="followModal.follows"></ListUserCard>
        <button class="mt-4 btn btn-primary" @click="followModal.nextPage" v-show="followModal.showNextPageBtn">View more</button>
      </div>

      <span v-else>{{ this.followModal.messageError }}</span>
    </b-modal>

    <b-modal ref="post-modal" size="xl" :hide-footer="idViewer != user.id" centered hide-header class="p-0">
      <PostDetails :post="postModal.post" :userNickname="user.nickname" class="m-auto" v-if="postModal.showPostDetailsComponent"></PostDetails>
      <PostFull :post="postModal.post" class="m-auto" v-else></PostFull>

      <template #modal-footer="{ ok }">
        <b-button size="md" variant="danger" @click="ok(deletePost(postModal.post))">
          Delete
        </b-button>
      </template>
    </b-modal>

    <div class="row bg-white">
      <div id="profile-description" class="col-12 mt-3 shadow-sm ">
        <div class="row pb-3 rounded text-center">
          <div class="profile-img col-md-3 col-sm-12">
            <b-avatar class="img-fluid" variant="primary" :src="user.profileImage" size="8rem"></b-avatar>
          </div>
          <div class="col-md-9 col-sm-12 my-auto">
            <div class="row">
              <h4 class="name col-12 text-left p-0 mt-2"><span>@{{ user.nickname }}</span></h4>
              <h6 class="name col-12 text-left p-0 mb-3"><span>{{ user.name }}</span></h6>
              <div class="numbers col-4 btn text-center">{{ postPagination.totalRegs }} posts</div>
              <div class="col-4  text-center">
                <button type="button" class="btn numbers" @click="showFollows">{{ followsPagination.totalRegs }} follows</button>
              </div>
              <div class="col-4  text-center">
                <button type="button" class="btn numbers" @click="showFollowers">{{ followersPagination.totalRegs }} followers</button>
              </div>

              <div class="col-12 mt-3" v-if="idViewer !== user.id">
                <button class="w-50 btn btn-primary text-light" v-if="follow.idRequestStatus < 1" @click="followUser">Follow</button>
                <button class="w-50 border-primary btn btn-light text-primary" v-if="follow.idRequestStatus === 1" @click="unfollowUser">Pending</button>
                <button class="w-50 border-primary btn btn-light text-primary" v-if="follow.idRequestStatus === 2" @click="unfollowUser">Unfollow</button>
              </div>
            </div>
          </div>
        </div>
      </div>

      <div class="col-12 shadow-sm pb-4" v-if="profileVisible">
        <div v-if="posts && posts.length > 0">
          <ListPostsMini :posts="posts" @openDetails="showPostDetails($event)"></ListPostsMini>
          <button class="mt-4 btn btn-primary" @click="nextPage" v-show="postPagination.showNextPageBtn">View more</button>
        </div>
        <div v-else class="mt-4 text-center">
          <h2 class="m-auto mt-5">NO POSTS YET</h2>
        </div>
      </div>

      <div class="col-12 mt-4 text-center" v-else>
        <h2 class="m-auto mt-5">PRIVATE PROFILE</h2>
      </div>
    </div>

    <b-navbar class="fixed-bottom shadow-lg text-secondary bg-white" v-if="idViewer == user.id">
      <div class="w-25 m-auto">
        <b-navbar-nav class="p-auto m-auto rounded p-2">
          <router-link class="m-auto btn px-2" :to="{ name: 'app.new-post' }">+ Add post</router-link>
        </b-navbar-nav>
      </div>
    </b-navbar>

  </div>
</template>

<script>
import UTILS from '@/utils'
import ListPostsMini from '../components/listPostsMini/ListPostsMini'
import PostDetails from  '../components/posts/postdetails/PostDetails'
import PostFull from  '../components/posts/postfull/PostFull'

export default {
  name: 'Profile',
  components: {
    ListPostsMini,
    PostDetails,
    PostFull
  },
  data () {
    return {
      idViewer: UTILS.user.getIdUser(),
      profileVisible: false,
      follow: {
        idFollow: -1,
        idRequestStatus: -1
      },
      posts: [],
      user: {
        id: -1,
        profileImage: '',
        nickname: '',
        name: ''
      },
      postPagination: {
        prev: null,
        next: null,
        limit: parseInt(process.env.VUE_APP_PAGESIZE),
        count: 0,
        totalRegs: 0,
        showNextPageBtn: true
      },
      followsPagination: {
        prev: null,
        next: null,
        limit: parseInt(process.env.VUE_APP_PAGESIZE),
        count: 0,
        totalRegs: 0,
        showNextPageBtn: true
      },
      followersPagination: {
        prev: null,
        next: null,
        limit: parseInt(process.env.VUE_APP_PAGESIZE),
        count: 0,
        totalRegs: 0,
        showNextPageBtn: true
      },
      follows: [],
      followers: [],
      followModal: {
        title: '',
        follows: [],
        messageError: '',
        nextPage: () => {},
        showNextPageBtn: true
      },
      postModal: {
        post: null,
        showPostDetailsComponent: false
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
    resetFollowModal() {
      this.follows = [];
      this.followers = [];
    },
    nextPage() {
      this.getUserPosts()
    },
    async getUserPosts() {
      this.showOverlay = true

      const params = {
        id: this.user.id,
        prev: this.postPagination.prev,
        next: this.postPagination.next,
        limit: this.postPagination.limit
      }

      this.axios.get('posts/user', { params })
        .then(res => {
          if (res.data.status < 0) {
            this.showError = true
            this.errorMessage = res.data.error
          } else {
            if (res.data.data.posts)
              this.posts = this.posts.concat(res.data.data.posts)

            this.postPagination.prev = res.data.data.prev
            this.postPagination.next = res.data.data.next
            this.postPagination.count = res.data.data.count
            this.postPagination.totalRegs = res.data.data.totalRegs

            if (this.postPagination.count < this.postPagination.limit) {
              this.postPagination.showNextPageBtn = false
            }
          }
        })
        .catch(e => {
          console.log(e)
          this.showError = true
          this.errorMessage = e.message
        })
        .finally(() => {
          this.showOverlay = false
        })
    },
    async getUser() {
      const id = this.$route.params.id
      this.user.id = id

      this.axios.get(`users/${id}`)
        .then(res => {
          if (res.data.status === -17) { // Private profile
            this.profileVisible = false
          } else if (res.data.status < 0) {
            this.showError = true
            this.errorMessage = res.data.error
          } else {
            this.profileVisible = true
            this.getUserPosts()
          }

          this.followsPagination.totalRegs = res.data.data.totalFollows
          this.followersPagination.totalRegs = res.data.data.totalFollowers
          this.follow.idFollow = res.data.data.idFollow
          this.follow.idRequestStatus = res.data.data.idRequestStatus
          this.user.profileImage = res.data.data.profileImage
          this.user.nickname = res.data.data.nickname
          this.user.name = res.data.data.name
        })
        .catch(e => {
          console.log(e)
          this.showError = true
          this.errorMessage = e.message
          this.$router.push({ name: 'app.errors', params: { error: '404' } })
          return
        })
        .finally(() => {
          this.showOverlay = false
        })
    },
    followUser() {
      const params = {
        idUserFollowed: this.user.id
      }

      this.axios.post('follows', params)
        .then(res => {
          if (res.data.status < 0) {
            this.showError = true
            this.errorMessage = res.data.error
          } else {
            this.follow.idFollow = res.data.data.idFollow
            this.follow.idRequestStatus = res.data.data.idRequestStatus
          }
        })
        .catch(e => {
          console.log(e)
          this.showError = true
          this.errorMessage = e.message
        })
        .finally(() => {
          this.showOverlay = false
        })
    },
    unfollowUser() {
      this.axios.delete(`follows/${this.follow.idFollow}`)
        .then(res => {
          if (res.data.status < 0) {
            this.showError = true
            this.errorMessage = res.data.error
          } else {
            this.follow.idFollow = -1
            this.follow.idRequestStatus = -1
            this.posts = []
          }
        })
        .catch(e => {
          console.log(e)
          this.showError = true
          this.errorMessage = e.message
        })
        .finally(() => {
          this.showOverlay = false
        })
    },
    showFollows() {
      this.followModal.title = 'Follows'
      this.followModal.messageError = 'No follows yet.'

      const params = {
        idUserFollower: this.user.id,
        prev: this.followsPagination.prev,
        next: this.followsPagination.next,
        limit: this.followsPagination.limit
      }

      this.axios.get('follows/follows', { params })
        .then(res => {
          if (res.data.status < 0) {
            this.showError = true
            this.errorMessage = res.data.error
          } else {
            if (res.data.data.follows)
              this.follows = this.follows.concat(res.data.data.follows)

            this.followsPagination.prev = res.data.data.prev
            this.followsPagination.next = res.data.data.next
            this.followsPagination.count = res.data.data.count
            this.followsPagination.totalRegs = res.data.data.totalRegs

            if (this.followsPagination.count < this.followsPagination.limit) {
              this.followsPagination.showNextPageBtn = false
            }
          }

          this.followModal.follows = this.follows
          this.followModal.nextPage = () => { this.showFollows() }
          this.followModal.showNextPageBtn = this.followsPagination.showNextPageBtn
        })
        .catch(e => {
          console.log(e)
          this.showError = true
          this.errorMessage = e.message
        })
        .finally(() => {
          this.showOverlay = false
        })

      this.$refs['follow-modal'].show()
    },
    showFollowers() {
      this.followModal.title = 'Followers'
      this.followModal.messageError = 'No followers yet.'

      const params = {
        idUserFollowed: this.user.id,
        prev: this.followersPagination.prev,
        next: this.followersPagination.next,
        limit: this.followersPagination.limit
      }

      this.axios.get('follows/followers', { params })
        .then(res => {
          if (res.data.status < 0) {
            this.showError = true
            this.errorMessage = res.data.error
          } else {
            if (res.data.data.followers)
              this.followers = this.followers.concat(res.data.data.followers)

            this.followersPagination.prev = res.data.data.prev
            this.followersPagination.next = res.data.data.next
            this.followersPagination.count = res.data.data.count
            this.followersPagination.totalRegs = res.data.data.totalRegs

            if (this.followersPagination.count < this.followersPagination.limit) {
              this.followersPagination.showNextPageBtn = false
            }
          }

          this.followModal.follows = this.followers
          this.followModal.nextPage = () => { this.showFollowers() }
          this.followModal.showNextPageBtn = this.followersPagination.showNextPageBtn
        })
        .catch(e => {
          console.log(e)
          this.showError = true
          this.errorMessage = e.message
        })
        .finally(() => {
          this.showOverlay = false
        })

      this.$refs['follow-modal'].show()
    },
    showPostDetails(post) {
      this.postModal.showPostDetailsComponent = window.screen.width > 784
      this.postModal.post = post
      this.postModal.post.nickname = this.user.nickname
      this.$refs['post-modal'].show()
    },
    deletePost(post) {
      this.axios.delete(`posts/${post.idPost}`)
        .then(res => {
          if (res.data.status < 0) {
            this.showError = true
            this.errorMessage = res.data.error
          } else {
            this.posts = this.posts.filter(item => item.idPost !== post.idPost);
            this.postPagination.totalRegs -= 1
          }
        })
        .catch(e => {
          this.showError = true
          this.errorMessage = e.message
        })
        .finally(() => {
          this.showOverlay = false
        })
    }
  },
  created () {
    this.getUser()
  }
}
</script>

<style scoped>
.numbers {
  font-size: 0.85em;
}

.profile-img {
  text-align: right!important;
}

.name {
  text-align: center!important;
}


@media (max-width: 768px) {
  .profile-img {
    text-align: center!important;
  }
}
</style>
<template>
  <div class="post-details">
    <div class="row">
      <div id="detail-img" class="col-7">
        <img alt="Vue logo" :src="post.image" class="img-fluid rounded" />
      </div>

      <div id="detail-info" class="col-5 text-left">
        <div id="user" class="ml-0 my-auto shadow-sm p-2">
          <router-link class="btn m-0 p-0" :to="{ name: 'app.profile', params: { id: post.idUser }}">
            <b-avatar variant="primary" :src="post.profileImage" size="2.em"></b-avatar>
            <span class="ml-1 pt-1" id="nickname">@{{ userNickname }}</span>
          </router-link>
        </div>
        <div id="description" class="mt-2">
          {{ post.description }}
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'PostDetails',
  props: {
    post: { type: Object, required: true },
    userNickname: { type: String }
  }
}
</script>

<style scoped>
.post-details {
  padding: 0!important;
  /* margin-left: -32px !important; */
}

.post-img {
  max-width: 610px !important;
  max-height: 610px !important;
}

img {
  width: 610px;
  height: 610px;
}

#nickname {
  font-size: 1.1em;
}

#description {
  font-size: 0.95em;
}

@media (max-width: 600px) {
  img {
    width: 280px;
    height: 280px;
  }
}

@media (min-width: 601px) and (max-width: 750px) {
  img {
    width: 285px;
    height: 285px;
  }
}

@media (min-width: 751px) and (max-width: 900px) {
  img {
    width: 295px;
    height: 295px;
  }
}

@media (min-width: 901px) and (max-width: 1000px) {
  img {
    width: 305px;
    height: 305px;
  }
}

@media (min-width: 1001px) and (max-width: 1200px) {
  img {
    width: 440px;
    height: 440px;
  }
}
</style>
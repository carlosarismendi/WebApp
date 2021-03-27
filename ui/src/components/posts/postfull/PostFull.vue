<template>
  <div class="text-center shadow-sm rounded" style="max-width: 350px">
    <b-card>
      <div id="post-image" class="shadow-sm post-img">
        <b-img alt="Vue logo" :src="post.image" fluid rounded></b-img>
      </div>

      <div class="text-left py-1 px-2">
        <div id="post-creator">
          <router-link class="btn m-0 p-0" :to="{ name: 'app.profile', params: { id: post.idUser }}">
            <b-avatar variant="primary" :src="post.profileImage" size="1.5rem"></b-avatar>
            <span class="ml-1">@{{ post.nickname }}</span>
          </router-link>
        </div>

        <div id="post-text" class="mt-1">
          {{ post.description }}
        </div>
      </div>
    </b-card>
  </div>
</template>

<script>
export default {
  name: 'PostFull',
  props: {
    post: { type: Object, required: true }
  }
}
</script>

<style scoped>
.card-body {
  padding: 0!important;
}

/* .post-img {
  max-width: 350px !important;
  max-height: 350px !important;
} */

img {
  width: 350px;
  height: 350px;
}

@media (max-width: 360px) {
  img {
    width: 290px;
    height: 290px;
  }
}

@media (min-width: 360px) and (max-width: 385px) {
  img {
    width: 315px;
    height: 315px;
  }
}

@media (min-width: 385px) and (max-width: 420px) {
  img {
    width: 345px;
    height: 345px;
  }
}


/* @media (min-width: 577px) and (max-width: 768px) {
  img {
    width: 150px;
    height: 150px;
  }
}

@media (min-width: 769px) and (max-width: 992px) {
  img {
    width: 200px;
    height: 200px;
  }
}

@media (min-width: 993px) and (max-width: 1200px) {
  img {
    width: 250px;
    height: 250px;
  }
} */

</style>
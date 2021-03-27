<template>
  <div class="rounded">
    <b-card class="post-img m-auto border-0">
      <div id="post-image" class="text-center">
        <b-img alt="Vue logo" :src="post.image" fluid rounded></b-img>
      </div>
    </b-card>
  </div>
</template>

<script>
export default {
  name: 'PostMini',
  props: {
    post: { type: Object }
  }
}
</script>

<style scoped>
.card-body {
  padding: 0!important;
}

/* .post-img {
  max-width: 293px !important;
  max-height: 293px !important;
} */

img {
  width: 293px;
  height: 293px;
}

@media (max-width: 487px) {
  img {
    width: 100px;
    height: 100px;
  }
}

@media (min-width: 488px) and (max-width: 576px) {
  img {
    width: 125px;
    height: 125px;
  }
}

@media (min-width: 577px) and (max-width: 768px) {
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
}
</style>
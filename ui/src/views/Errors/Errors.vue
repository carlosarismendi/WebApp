<template>
  <div class="container shadow-sm bg-white py-3">
    <div class="row">
      <h1 class="col-12 text-center font-weight-bold">ERROR {{ error}} </h1>
    </div>
  </div>
</template>

<script>
export default {
  name: 'Errors',
  data() {
    return {
      error: 0
    }
  },
  created() {
    this.error = this.$route.params.error
  }
}
</script>
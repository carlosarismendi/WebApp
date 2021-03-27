<template>
  <div>
    <NavBarPublic></NavBarPublic>
    <router-view style="min-height: 72vh"/>
    <Footer></Footer>
  </div>
</template>

<script>
import NavBarPublic from '../navbars/NavBarPublic'
import Footer from '../footer/Footer'

export default {
  name: 'AuthLayout',
  components: {
    NavBarPublic,
    Footer
  }
}
</script>

<style scoped>
</style>
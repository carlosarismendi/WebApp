<template>
  <div>
    <NavBarPublic></NavBarPublic>
    <router-view style="min-height: 72vh" :key="$route.fullPath"/>
    <Footer></Footer>
  </div>
</template>
<script>
import NavBarPublic from '../navbars/NavBarPublic'
import Footer from '../footer/Footer'

export default {
  name: 'PublicLayout',
  components: {
    NavBarPublic,
    Footer
  }
}
</script>
<template>
  <div>
    <NavBarPrivate></NavBarPrivate>
    <router-view style="min-height: 72vh" :key="$route.fullPath"/>
    <Footer></Footer>
  </div>
</template>
<script>
import NavBarPrivate from '../navbars/NavBarPrivate'
import Footer from '../footer/Footer'

export default {
  name: 'PrivateLayout',
  components: {
    NavBarPrivate,
    Footer
  }
}
</script>
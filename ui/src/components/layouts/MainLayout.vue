<template>
  <div>
    <component :is="layout">
      <router-view :layout.sync="layout" />
    </component>
  </div>
</template>

<script>
import UTILS from '../../utils'
import PublicLayout from '../layouts/PublicLayout'
import PrivateLayout from '../layouts/PrivateLayout'

export default {
  name: 'MainLayout',
  components: {
    PublicLayout,
    PrivateLayout
  },
  data() {
    return {
      layout: (UTILS.user.isAuthenticated()) ? PrivateLayout : PublicLayout
    }
  },
  methods: {
    isAuthenticated () {
      return false;
    }
  }
}
</script>

<style scoped>

</style>
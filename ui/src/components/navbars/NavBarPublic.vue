<template>
  <div>
    <b-navbar toggleable="lg" type="light" variant="light" class="mx-0 py-0 shadow-sm" fixed>
      <b-navbar-brand class="py-4" href="/">AdiSocial</b-navbar-brand>

      <b-navbar-toggle class="border-0" target="nav-collapse"></b-navbar-toggle>

      <b-collapse id="nav-collapse" is-nav class="text-center">
        <b-navbar-nav class="ml-auto">
          <router-link class="btn btn-light my-0 mx-1 py-4" :to="{ name: 'users.sign-in' }">Log in</router-link>
          <router-link class="btn btn-light my-0 mx-1 py-4" :to="{ name: 'users.sign-up' }">Sign up</router-link>
        </b-navbar-nav>
      </b-collapse>
    </b-navbar>
  </div>
</template>
<script>
export default {
  name: 'NavBarPublic'
}
</script>
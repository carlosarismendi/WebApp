<template>
  <div class="w-100 rounded m-auto mt-2">
    <b-card>
      <div class="user-card row">
        <div id="profile-img" class="my-auto col-3 p-0 text-center">
          <b-avatar class="img-fluid" variant="primary" :src="user.profileImage" size="3rem"></b-avatar>
        </div>

        <div id="name-and-nick" class="my-auto col-6 text-left mx-0 px-0 pl-2">
          <div id="nickname" class="font-weight-bold text-truncate">@{{ user.nickname }}</div>
          <div id="name" class="text-truncate">{{ user.name }}</div>
        </div>

        <div id="btns" class="my-auto col-3 text-center p-0 mx-0 pl-1">
          <!-- <button class="btn btn-primary">Follow</button> -->
          <router-link :to="{ name: 'app.profile', params: { id: user.idUser} }" class="btn btn-primary p-1 m-0"><span>Details</span></router-link>
        </div>
      </div>
    </b-card>
  </div>
</template>

<script>
export default {
  name: 'UserCard',
  props: {
    user: { type: Object },
    followed: { type: Boolean }
  }
}
</script>

<style scoped>
.user-card {
  height: 50px;
}

/* #profile-img {
  width: auto% !important;
}

#name-and-nick {
  width: 70% !important;
  font-size: 0.9em;
}

#btns {
  width: 30% !important;
  margin-right: 0!important;
} */

@media (max-width: 520px) {
  div, span {
    font-size: 0.97em!important;
  }
}

</style>
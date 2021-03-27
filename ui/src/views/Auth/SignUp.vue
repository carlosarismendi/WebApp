<template>
  <div class="container py-3 sign-up">
    <div class="text-center shadow-lg p-3 px-4 rounded">
      <b-overlay :show="showOverlay" rounded="sm" no-wrap opacity="0.6"></b-overlay>
          <b-alert
            variant="danger"
            dismissible
            :show="showError"
            @dismissed="resetError()"
          >
            {{errorMessage}}
          </b-alert>
      <h1>Sign up</h1>
      <ValidationObserver ref="observer" v-slot="{ invalid }" v-show="!indRegisterEnd">
        <form id="sign-up-Form" @submit.prevent="signUp" class="row">

          <ValidationProvider name="nickname" :rules="{ required: true, max: 20 }" v-slot="validationContext" class="col-12">
            <b-form-group id="nickname-group">
              <label for="nickname">Nickname</label>
              <b-form-input
                id="nickname"
                name="nickname"
                type="text"
                :autofocus="true"
                tabindex="1"
                v-model="user.nickname"
                :state="getValidationState(validationContext)"
                :maxlength="20"
              ></b-form-input>
            </b-form-group>
          </ValidationProvider>

          <ValidationProvider name="email" :rules="{ required: true, max: 250 }" v-slot="validationContext" class="col-12">
            <b-form-group id="email-group">
              <label for="email">Email</label>
              <b-form-input
                id="email"
                name="email"
                type="email"
                :autofocus="true"
                tabindex="2"
                v-model="user.email"
                :state="getValidationState(validationContext)"
                :maxlength="250"
              ></b-form-input>
            </b-form-group>
          </ValidationProvider>

          <ValidationProvider name="password" :rules="{ required: true, min: 8, max: 250 }" v-slot="validationContext" class="col-12">
            <b-form-group id="password-group">
              <label for="password">Password</label>
              <b-form-input
                id="password"
                name="password"
                :type="indPasswordType"
                :autofocus="true"
                tabindex="3"
                v-model="user.password"
                :state="getValidationState(validationContext)"
                :maxlength="250"
                style="background-image: none !important;"
              ></b-form-input>
              <div class="btn btn-eye" @click="togglePasswordVisibility">
                <i :class="indPasswordIcon"></i>
              </div>
            </b-form-group>
          </ValidationProvider>

          <ValidationProvider name="name" :rules="{ required: true, max: 100 }" v-slot="validationContext" class="col-12">
            <b-form-group id="name-group">
              <label for="name">Name</label>
              <b-form-input
                id="name"
                name="name"
                type="text"
                :autofocus="true"
                tabindex="4"
                v-model="user.name"
                :state="getValidationState(validationContext)"
                :maxlength="100"
              ></b-form-input>
            </b-form-group>
          </ValidationProvider>

          <ValidationProvider name="phone" :rules="{ required: false, max: 20 }" v-slot="validationContext" class="col-12">
            <b-form-group id="phone-group">
              <label for="phone">Phone (optional)</label>
              <b-form-input
                id="phone"
                name="phone"
                type="text"
                :autofocus="true"
                tabindex="5"
                v-model="user.phone"
                :state="getValidationState(validationContext)"
                :maxlength="20"
              ></b-form-input>
            </b-form-group>
          </ValidationProvider>

          <div class="col-12">
            <button :disabled="invalid" type="submit" class="btn btn-primary w-50 mt-2">Sign up</button>
          </div>
        </form>
      </ValidationObserver>

      <div v-show="indRegisterEnd" class="text-left">
        <p>You have been registered succesfully.</p>
        <p>Please check your email inbox and confirm your account by using the provided link.</p>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'SignUp',
  data () {
    return {
      indPasswordType: 'password',
      indPasswordIcon: 'far fa-eye-slash',
      indRegisterEnd: false,
      user: {
        email: '',
        nickname: '',
        password: '',
        name: '',
        phone: '' // optional
      },
      showOverlay: false,
      showError: false,
      errorMessage: ''
    }
  },
  methods: {
    getValidationState ({ dirty, validated, valid = null }) {
      return dirty || validated ? valid : null
    },
    togglePasswordVisibility () {
      if (this.indPasswordType === 'text') {
        this.indPasswordType = 'password'
        this.indPasswordIcon = 'far fa-eye-slash'
      } else {
        this.indPasswordType = 'text'
        this.indPasswordIcon = 'fal fa-eye'
      }
    },
    signUp () {
      this.showOverlay = true
      this.axios.post('registers', { ...this.user })
        .then(res => {
          if (res.data.status < 0) {
            this.showError = true
            this.errorMessage = res.data.error
          } else {
            this.$router.push({ name: 'users.sign-in' })
          }
        })
        .catch(e => {
          console.log(e)
          this.showError = true
          this.errorMessage = 'Internal error'
          this.$router.push({ name: 'app.errors', params: { error: '500' } })
        })
        .finally(() => {
          this.showOverlay = false
        })
    }
  }
}
</script>

<style scoped>
.btn-eye {
  position: relative!important;
  float: right;
  font-size: 1em;
  margin-top: -38px;
  /* margin-right: -89%; */
}

label {
  float: left;
}

@media (max-width: 600px) {
  .sign-up {
    margin-top: 20px;
    width: 90%;
  }
}

@media (min-width: 601px) and (max-width: 750px) {
  .sign-up {
    margin-top: 30px;
    width: 65%;
  }
}

@media (min-width: 751px) and (max-width: 900px) {
  .sign-up {
    margin-top: 40px;
    width: 50%;
  }
}

@media (min-width: 901px) and (max-width: 1200px) {
  .sign-up {
    margin-top: 50px;
    width: 40%;
  }
}

@media (min-width: 1201px) {
  .sign-up {
    margin-top: 60px;
    width: 25%;
  }
}
</style>
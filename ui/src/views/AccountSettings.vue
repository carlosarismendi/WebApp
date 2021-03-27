<template>
  <div class="container py-5 ">
    <b-overlay :show="showOverlay" rounded="sm" no-wrap opacity="0.6"></b-overlay>
    <b-alert
      :variant="errorVariant"
      dismissible
      :show="showError"
      @dismissed="resetError()"
    >
      {{errorMessage}}
    </b-alert>

    <div>
      <b-modal
        id="cropper-modal"
        centered
        :title="'Recortar imagen'"
        v-model="cropperModalShow"
        cancel-variant="light"
        ok-variant="primary"
        cancel-title="Cancel"
        ok-title="Save"
        @ok="getCropperImageResult()"
        @cancel="newProfileImage = null"
        :no-close-on-backdrop="true"
        :no-close-on-esc="true"
      >
      <cropper
        ref="cropper"
        class="w-100 h-100"
        :src="croppedImage"
        :stencil-component="stencilComponent"
      />
      </b-modal>

      <div class="row px-2">
        <div class="col-sm-12 col-md-10 mx-auto my-3">
          <b-form @submit.prevent="updateProfileImage" class="m-auto text-left shadow p-4 px-5">
            <div class="text-center mb-2">
              <h3>Profile image</h3>
              <b-avatar variant="primary" :src="user.profileImage" size="10rem"></b-avatar>
            </div>

            <div class="w-100 text-left">
              <b-form-group label-for="image" label="Image">
                <b-form-file
                  name="image"
                  @change="previewNewImage"
                  placeholder="Choose an image"
                  v-model="newProfileImage"
                  accept="image/png,image/jpeg,image/jpg"
                  class="form-control mt-2">
                </b-form-file>
              </b-form-group>
              <div class="text-center">
                <button type="submit" @click="newProfileImage = null" class="btn btn-secondary">Remove image</button>
              </div>
            </div>
          </b-form>
        </div>

        <div class="col-sm-12 col-md-10 mx-auto my-3">
          <ValidationObserver ref="observer" v-slot="{ invalid }">
            <b-form @submit.prevent="updateProfile" class="m-auto text-left shadow p-5">
              <div class="text-center mb-2">
                <h3>Basic information</h3>
              </div>

              <ValidationProvider name="name" :rules="{ required: true, max: 100 }" v-slot="validationContext">
                <b-form-group label-form="name" label="Name">
                  <b-form-input
                    id="name"
                    name="name"
                    type="text"
                    :autofocus="true"
                    tabindex="1"
                    v-model="user.name"
                    :state="getValidationState(validationContext)"
                    :maxlength="100"
                    class="form-control"
                  ></b-form-input>
                </b-form-group>
              </ValidationProvider>

              <ValidationProvider name="nickname" :rules="{ required: true, max: 20 }" v-slot="validationContext">
                <b-form-group label-form="nickname" label="Nickname">
                  <b-form-input
                    id="nickname"
                    name="nickname"
                    type="text"
                    :autofocus="true"
                    tabindex="2"
                    v-model="user.nickname"
                    :state="getValidationState(validationContext)"
                    :maxlength="20"
                    class="form-control"
                  ></b-form-input>
                </b-form-group>
              </ValidationProvider>

              <div class="text-center">
                <button type="submit" :disabled="invalid" class="btn btn-primary">Save</button>
              </div>
            </b-form>
          </ValidationObserver>
        </div>

        <div class="col-sm-12 col-md-10 mx-auto my-3">
          <b-form @submit.prevent="updateProfileImage" class="m-auto text-left shadow p-5">
            <div class="text-center mb-2">
              <h3>Privacy settings</h3>
            </div>

            <b-form-radio-group
              id="privacy-settings-radios"
              v-model="user.idVisibilityType"
              :options="visibilityTypes"
              value-field="id"
              text-field="description"
              class="text-center mt-3"
              @change="updatePrivacy"
            ></b-form-radio-group>
          </b-form>
        </div>

        <b-modal
          ref="delete-account-modal"
          title="Delete account"
          size="sm"
          @ok="deleteAccount"
          v-model="deleteAccountModal"
          cancel-variant="success"
          ok-variant="danger"
          centered>
          <div>
            Are you sure that you want to delete your account?
          </div>
        </b-modal>

        <div class="col-sm-12 col-md-10 mx-auto my-3">
          <div class="m-auto text-left shadow p-5">
            <div class="text-center mb-2">
              <h3>Delete account</h3>
            </div>

            <div class="text-center">
              <button type="button" @click="deleteAccountModal = true" class="btn btn-danger">Delete</button>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import UTILS from '@/utils'
import { Cropper, CircleStencil } from 'vue-advanced-cropper'

export default {
  name: 'AccountSettings',
  components: {
    Cropper,
    /* eslint-disable vue/no-unused-components */
    CircleStencil
  },
  data() {
    return {
      stencilComponent: this.$options.components.CircleStencil,
      cropperModalShow: false,
      croppedImage: null,
      newProfileImage: null,
      user: {
        name: UTILS.user.getName(),
        nickname: UTILS.user.getNickname(),
        profileImage: UTILS.user.getProfileImage(),
        idVisibilityType: 0,
      },
      visibilityTypes: [],
      disableForm: false,
      previewImage: null,
      showOverlay: false,
      showError: false,
      errorMessage: '',
      errorVariant: 'danger',
      deleteAccountModal: false
    }
  },
  methods: {
    getValidationState ({ dirty, validated, valid = null }) {
      return dirty || validated ? valid : null
    },
    resetError () {
      this.showError = false
      this.errorMessage = null
    },
    change ({ coordinates, canvas }) {
      this.coordinates = coordinates
      this.newProfileImage = canvas.toDataURL()
    },
    getCropperImageResult () {
      const { canvas } = this.$refs.cropper.getResult()
      if (canvas) {
        canvas.toBlob(async blob => {
          const extension = blob.type.substring(blob.type.indexOf('/') + 1, blob.type.length)
          this.newProfileImage = new File([blob], `${UTILS.user.getIdUser()}${Date.now()}.${extension}`, { type: blob.type })

          this.updateProfileImage()
        })
      }
    },
    validateFileExtension: function (file) {
      if (!file || file.type === 'image/jpeg' || file.type === 'image/jpg' || file.type === 'image/png') {
        return true
      } else {
        this.alertVariant = 'danger'
        this.errorMessage = 'Invalid image format. It must be .jgp, .jpeg or .png'
        this.showError = true
        return false
      }
    },
    previewNewImage: function (event) {
      const input = event.target

      if (input.files && input.files[0] && this.validateFileExtension(input.files[0])) {
        const reader = new FileReader()

        reader.onload = e => {
          this.croppedImage = e.target.result
        }

        reader.readAsDataURL(input.files[0])
        this.cropperModalShow = true
      }
    },
    async getVisibilityTypes() {
      this.axios.get('visibility-types')
        .then(res => {
          this.visibilityTypes = res.data.data
        })
        .catch(e => {
          console.log(e)
          this.$router.push({ name: 'app.errors', params: { error: '500' } })
        })
        .finally(() => {
          this.showOverlay = false
        })
    },
    async getUserPrivacy() {
      this.axios.get('privacy')
        .then(res => {
          if (res.data.status < 0) {
            this.$router.push({ name: 'app.errors', params: { error: '404' } })
          } else {
            this.user.idVisibilityType = res.data.data.idVisibilityTypeProfile
          }
        })
        .catch(e => {
          console.log(e)
          this.$router.push({ name: 'app.errors', params: { error: '500' } })
        })
        .finally(() => {
          this.showOverlay = false
        })
    },
    updateProfileImage() {
      let formData = new FormData()

      formData.append('profileImage', this.newProfileImage)

      this.axios.put('users/profile-image', formData)
        .then(res => {
          if (res.data.status < 0) {
            this.errorMessage = res.data.error
            this.errorVariant = 'danger'
          } else {
            this.errorMessage = 'Profile image updated correctly.'
            this.errorVariant = 'success'

            if (res.data.data.profileImage) {
              this.user.profileImage = res.data.data.profileImage
              UTILS.user.setProfileImage(res.data.data.profileImage)

              // Simple way of sending an event to all those components that are using the profileImage
              // (e.g. private navbar) so they can update its value
              this.$store.commit('updateProfileImage', res.data.data.profileImage)
            } else {
              this.user.profileImage = null
              UTILS.user.setProfileImage(null)

              // Simple way of sending an event to all those components that are using the profileImage
              // (e.g. private navbar) so they can update its value
              this.$store.commit('updateProfileImage', null)
            }
          }
        })
        .catch(e => {
          console.log(e)
          this.errorVariant = 'danger'
          this.errorMessage = e.message
        })
        .finally(() => {
          this.showError = true
          this.showOverlay = false
          scroll(0, 0)
        })
    },
    async updatePrivacy() {
      const params = {
        idVisibilityTypeProfile: this.user.idVisibilityType
      }

      this.axios.put('privacy', params)
        .then(res => {
          if (res.data.status < 0) {
            this.errorMessage = res.data.error
            this.errorVariant = 'danger'
          } else {
            this.errorMessage = 'Privacy updated correctly.'
            this.errorVariant = 'success'
          }
        })
        .catch(e => {
          console.log(e)
          this.errorVariant = 'danger'
          this.errorMessage = e.message
        })
        .finally(() => {
          this.showError = true
          this.showOverlay = false
          scroll(0, 0)
        })
    },
    async updateProfile() {
      const params = {
        nickname: this.user.nickname,
        name: this.user.name
      }

      this.axios.put('users', params)
        .then(res => {
          if (res.data.status < 0) {
            this.errorMessage = res.data.error
            this.errorVariant = 'danger'
          } else {
            this.errorMessage = 'Basic information updated correctly.'
            this.errorVariant = 'success'

            UTILS.user.setNickname(this.user.nickname)
            UTILS.user.setName(this.user.name)

            this.$store.commit('updateNickname', this.user.nickname)
            this.$store.commit('updateName', this.user.name)
          }
        })
        .catch(e => {
          console.log(e)
          this.errorVariant = 'danger'
          this.errorMessage = e.message
        })
        .finally(() => {
          this.showError = true
          this.showOverlay = false
          scroll(0, 0)
        })
    },
    deleteAccount() {
      this.axios.delete('users')
        .then(res => {
          if (res.data.status < 0) {
            this.$router.push({ name: 'app.errors', params: { error: '404' } })
          } else {
            UTILS.user.removeLogin()
            this.$router.push({ name: 'users.sign-in' })
          }
        })
        .catch(e => {
          console.log(e)
          this.$router.push({ name: 'app.errors', params: { error: '500' } })
        })
        .finally(() => {
          this.showOverlay = false
        })
    }
  },
  created() {
    this.getVisibilityTypes()
    this.getUserPrivacy()
  }
}
</script>

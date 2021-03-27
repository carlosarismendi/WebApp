<template>
  <div class="container bg-white py-5 ">
    <b-overlay :show="showOverlay" rounded="sm" no-wrap opacity="0.6"></b-overlay>
    <b-alert
      variant="danger"
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
        :no-close-on-backdrop="true"
        :no-close-on-esc="true"
      >
      <cropper
        ref="cropper"
        class="w-100 h-100"
        :src="croppedImage"
        :stencil-component="stencilComponent"
        :stencil-props="{ aspectRatio: 1, scalable: true }"
      />
      </b-modal>

      <div class="row px-2">
        <div class="col-sm-10 col-md-8 col-lg-6 col-xl-4 m-auto">
          <ValidationObserver ref="observer" v-slot="{ invalid }">
            <b-form @submit.prevent="createPost" class="m-auto text-left">
              <div class="text-center">
                <h3>Post preview</h3>
              </div>
              <PostFull :post="postPreview" class="mx-auto mb-5"></PostFull>

              <div class="text-center">
                <h3>Create post</h3>
              </div>
              <b-form-group label-for="image" label="Image">
                <b-form-file
                  name="image"
                  @change="previewNewImage"
                  placeholder="Choose an image"
                  v-model="post.image"
                  accept="image/png,image/jpeg,image/jpg"
                  class="form-control">
                </b-form-file>
              </b-form-group>

              <ValidationProvider name="description" :rules="{ required: false, max: 500 }" v-slot="validationContext">
                <b-form-group label-for="description" label="Description">
                  <b-form-textarea
                    id="description"
                    name="description"
                    v-model="post.description"
                    :state="getValidationState(validationContext)"
                    placeholder="Enter something..."
                    rows="3"
                    :maxlength="500"
                    class="form-control">
                  ></b-form-textarea>
                </b-form-group>
              </ValidationProvider>

              <div class="w-100 text-center">
                <button type="button" @click="post.image = null; post.description = null;" class="w-25 btn btn-secondary mr-1">Reset</button>
                <button type="submit" :disabled="invalid || !post.image || disableForm" class="w-25 btn btn-primary ml-1">Create</button>
              </div>
            </b-form>
          </ValidationObserver>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import UTILS from '@/utils'
import { Cropper, RectangleStencil } from 'vue-advanced-cropper'
import PostFull from '../components/posts/postfull/PostFull'

export default {
  name: 'NewPost',
  components: {
    Cropper,
    /* eslint-disable vue/no-unused-components */
    RectangleStencil,
    PostFull
  },
  data() {
    return {
      stencilComponent: this.$options.components.RectangleStencil,
      cropperModalShow: false,
      croppedImage: null,
      post: {
        idUser: UTILS.user.getIdUser(),
        nickname: UTILS.user.getNickname(),
        profileImage: UTILS.user.getProfileImage(),
        image: null,
        description: ''
      },
      disableForm: false,
      previewImage: null,
      showOverlay: false,
      showError: false,
      errorMessage: ''
    }
  },
  computed: {
    postPreview() {
      return {
        idUser: this.post.idUser,
        nickname: this.post.nickname,
        profileImage: this.post.profileImage,
        image: !this.post.image ? 'https://media.sproutsocial.com/uploads/2017/02/10x-featured-social-media-image-size.png' : this.previewImage,
        description: this.post.description
      }
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
      this.post.image = canvas.toDataURL()
    },
    getCropperImageResult () {
      const { canvas } = this.$refs.cropper.getResult()
      if (canvas) {
        canvas.toBlob(async blob => {
          const extension = blob.type.substring(blob.type.indexOf('/') + 1, blob.type.length)
          this.post.image = new File([blob], `${UTILS.user.getIdUser()}${Date.now()}.${extension}`, { type: blob.type })

          this.previewImage = URL.createObjectURL(blob);
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
    createPost() {
      this.disableForm = true
      let formData = new FormData()

      formData.append('image', this.post.image)
      formData.append('description', this.post.description)

      this.axios.post('posts', formData)
        .then(res => {
          if (res.data.status < 0) {
            this.showError = true
            this.errorMessage = res.data.error
          } else {
            this.$router.push({ name: 'app.profile', params: { id: UTILS.user.getIdUser() } })
          }
        })
        .catch(e => {
          console.log(e)
          this.showError = true
          this.errorMessage = e.message
          this.disableForm = false
        })
        .finally(() => {
          this.showOverlay = false
        })
    }
  }
}
</script>

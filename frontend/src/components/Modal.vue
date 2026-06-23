<template>
  <Teleport to="body">
    <Transition name="modal-fade">
      <div v-if="show" class="modal-backdrop" @click.self="onBackdropClick">
        <div class="modal-container" :style="{ width: '100%', maxWidth: width }">
          <!-- Header -->
          <div v-if="title || icon" class="modal-header">
            <i v-if="icon" class="material-icons">{{ icon }}</i>
            <h2>{{ title }}</h2>
          </div>

          <!-- Body -->
          <div class="modal-body">
            <slot></slot>
          </div>

          <!-- Footer / Actions -->
          <div v-if="$slots.actions" class="modal-actions">
            <slot name="actions"></slot>
          </div>
        </div>
      </div>
    </Transition>
  </Teleport>
</template>

<script setup lang="ts">
const props = defineProps({
  show: {
    type: Boolean,
    required: true
  },
  title: {
    type: String,
    default: ''
  },
  icon: {
    type: String,
    default: ''
  },
  width: {
    type: String,
    default: '600px'
  },
  closeOnBackdrop: {
    type: Boolean,
    default: true
  }
})

const emit = defineEmits(['close'])

const onBackdropClick = () => {
  if (props.closeOnBackdrop) {
    emit('close')
  }
}
</script>

<style scoped>
@import "./css/Modal.css";
</style>

<template>
  <Modal :show="show" :title="isEditMode ? 'Editar Usuário' : 'Novo Usuário'" icon="person" width="520px" @close="$emit('close')">
    <form @submit.prevent="onSubmit" class="form-container">
      <div class="form-group">
        <label class="form-label">Nome Completo</label>
        <input
          type="text"
          v-model="form.nome"
          class="form-control"
          placeholder="Ex: Roberto Carlos"
          required
        />
      </div>

      <div class="form-group">
        <label class="form-label">E-mail de Login</label>
        <input
          type="email"
          v-model="form.email"
          class="form-control"
          placeholder="contato@empresa.com"
          required
        />
      </div>

      <div class="form-group">
        <label class="form-label">Perfil de Acesso</label>
        <select v-model="form.perfil_id" class="form-control" required>
          <option value="" disabled>Selecione um perfil...</option>
          <option v-for="p in profiles" :key="p.id" :value="p.id">
            {{ p.nome }}
          </option>
        </select>
      </div>

      <div class="row">
        <div class="half-width form-group">
          <label class="form-label">{{ isEditMode ? 'Nova Senha (Opcional)' : 'Senha' }}</label>
          <div class="input-with-icon">
            <i class="material-icons icon-prefix">lock_outline</i>
            <input
              :type="showPassword ? 'text' : 'password'"
              v-model="form.senha"
              class="form-control"
              placeholder="Min. 6 caracteres"
              :required="!isEditMode"
              minlength="6"
            />
            <button type="button" class="suffix-btn" @click="showPassword = !showPassword">
              <i class="material-icons">{{ showPassword ? 'visibility_off' : 'visibility' }}</i>
            </button>
          </div>
        </div>
        <div class="half-width switch-wrapper">
          <label class="switch-container">
            <input type="checkbox" v-model="form.ativo" class="switch-input" />
            <span class="switch-slider"></span>
            <span>Usuário Ativo</span>
          </label>
        </div>
      </div>
    </form>

    <template #actions>
      <button type="button" class="btn btn-secondary" @click="$emit('close')">
        Cancelar
      </button>
      <button
        type="button"
        class="btn btn-primary"
        :disabled="!isFormValid"
        @click="onSubmit"
      >
        <span>{{ isEditMode ? 'Salvar' : 'Criar' }}</span>
      </button>
    </template>
  </Modal>
</template>

<script setup lang="ts">
import { ref, computed, watch } from 'vue'
import { Usuario, Perfil } from '@/types'
import Modal from './Modal.vue'

const props = defineProps({
  show: {
    type: Boolean,
    required: true
  },
  user: {
    type: Object as () => Usuario | null,
    default: null
  },
  profiles: {
    type: Array as () => Perfil[],
    required: true
  }
})

const emit = defineEmits(['close', 'save'])

const isEditMode = computed(() => !!props.user?.id)
const showPassword = ref(false)

const form = ref<any>({
  nome: '',
  email: '',
  perfil_id: '',
  senha: '',
  ativo: true
})

watch(
  () => props.show,
  (newShow) => {
    if (newShow) {
      showPassword.value = false
      if (props.user) {
        form.value = {
          nome: props.user.nome,
          email: props.user.email,
          perfil_id: props.user.perfil_id,
          senha: '',
          ativo: props.user.ativo !== false
        }
      } else {
        form.value = {
          nome: '',
          email: '',
          perfil_id: '',
          senha: '',
          ativo: true
        }
      }
    }
  },
  { immediate: true }
)

const isFormValid = computed(() => {
  const f = form.value
  const basic = f.nome && f.email && /\S+@\S+\.\S+/.test(f.email) && f.perfil_id
  if (!basic) return false
  
  if (isEditMode.value) {
    return !f.senha || f.senha.length >= 6
  } else {
    return f.senha && f.senha.length >= 6
  }
})

function onSubmit() {
  if (!isFormValid.value) return
  
  const payload: any = {
    nome: form.value.nome,
    email: form.value.email,
    perfil_id: form.value.perfil_id,
    ativo: form.value.ativo
  }
  
  if (props.user?.id) {
    payload.id = props.user.id
  }
  if (form.value.senha) {
    payload.senha = form.value.senha
  }
  
  emit('save', payload)
}
</script>

<style scoped>
@import "./css/UserFormModal.css";
</style>

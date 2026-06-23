<template>
  <Modal :show="show" :title="title || 'Ação Restrita'" icon="lock" width="550px" @close="$emit('close')">
    <p class="description">{{ description }}</p>
    <p class="info-note">
      Esta é uma ação restrita. Você pode concluí-la imediatamente inserindo a senha do supervisor,
      ou submeter um pedido de análise para aprovação posterior no painel.
    </p>

    <!-- Option 1 -->
    <div class="auth-section">
      <h3>Opção 1: Autorizar com Senha de Supervisor</h3>
      <form @submit.prevent="verifyAndPasswordApprove" class="pwd-form">
        <div class="form-group">
          <label class="form-label">Senha do Supervisor</label>
          <div class="input-with-icon">
            <i class="material-icons icon-prefix">lock_outline</i>
            <input
              type="password"
              v-model="password"
              class="form-control"
              placeholder="Digite a senha..."
              required
            />
          </div>
          <span v-if="errorMsg" class="error-text">{{ errorMsg }}</span>
        </div>
        <button
          type="submit"
          class="btn btn-primary"
          :disabled="!password || loading"
          style="margin-top: 4px;"
        >
          <span v-if="loading && isPasswordChecking" class="btn-spinner"></span>
          <span>Confirmar Senha</span>
        </button>
      </form>
    </div>

    <!-- Divider -->
    <div class="divider-container">
      <span class="divider-line"></span>
      <span class="divider-text">OU</span>
      <span class="divider-line"></span>
    </div>

    <!-- Option 2 -->
    <div class="analysis-section">
      <h3>Opção 2: Enviar para o Painel do Supervisor</h3>
      <p class="sub-text">
        O pedido de aprovação será listado na caixa de entrada do supervisor para que ele avalie a operação.
      </p>
      <button
        type="button"
        class="btn btn-accent"
        @click="submitForAnalysis"
        :disabled="loading"
        style="margin-top: 12px; width: 100%;"
      >
        <span v-if="loading && isSubmittingAnalysis" class="btn-spinner"></span>
        <span>Enviar Solicitação de Análise</span>
      </button>
    </div>

    <!-- Actions Footer -->
    <template #actions>
      <button type="button" class="btn btn-secondary" @click="$emit('close')" :disabled="loading">
        Cancelar
      </button>
    </template>
  </Modal>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import Modal from './Modal.vue'
import { api } from '@/services/api'
import { PedidoAnalise } from '@/types'

const props = defineProps({
  show: {
    type: Boolean,
    required: true
  },
  title: {
    type: String,
    default: ''
  },
  description: {
    type: String,
    required: true
  },
  pedido: {
    type: Object as () => PedidoAnalise,
    required: true
  }
})

const emit = defineEmits(['close', 'confirm', 'submit'])

const password = ref('')
const errorMsg = ref('')
const loading = ref(false)
const isPasswordChecking = ref(false)
const isSubmittingAnalysis = ref(false)

async function verifyAndPasswordApprove() {
  if (!password.value) return
  
  loading.value = true
  isPasswordChecking.value = true
  errorMsg.value = ''
  
  try {
    const res = await api.post<{ valid: boolean }>('/api/supervisor/verify-password', {
      password: password.value
    })
    
    if (res.valid) {
      emit('confirm', { confirmed: true, passwordUsed: true, password: password.value })
      password.value = ''
    } else {
      errorMsg.value = 'Senha do supervisor inválida!'
    }
  } catch (err: any) {
    errorMsg.value = err.error || 'Erro ao verificar senha.'
  } finally {
    loading.value = false
    isPasswordChecking.value = false
  }
}

async function submitForAnalysis() {
  loading.value = true
  isSubmittingAnalysis.value = true
  errorMsg.value = ''
  
  try {
    await api.post<PedidoAnalise>('/api/supervisor/requests', props.pedido)
    emit('submit', { submitted: true })
  } catch (err: any) {
    errorMsg.value = err.error || 'Erro ao criar solicitação de análise.'
  } finally {
    loading.value = false
    isSubmittingAnalysis.value = false
  }
}
</script>

<style scoped>
@import "./css/SupervisorDialog.css";
</style>

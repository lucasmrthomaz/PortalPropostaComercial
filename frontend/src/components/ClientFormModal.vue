<template>
  <Modal :show="show" :title="isEditMode ? 'Editar Cliente' : 'Novo Cliente'" icon="people" @close="$emit('close')">
    <form @submit.prevent="onSubmit" class="form-container">
      <div class="form-group">
        <label class="form-label">Nome Completo / Razão Social</label>
        <input
          type="text"
          v-model="form.nome"
          class="form-control"
          placeholder="Ex: João da Silva"
          required
          minlength="3"
        />
      </div>

      <div class="form-group">
        <label class="form-label">CPF / CNPJ</label>
        <input
          type="text"
          :value="form.cpf_cnpj"
          @input="onCpfCnpjInput"
          class="form-control"
          placeholder="Ex: 000.000.000-00 ou 00.000.000/0000-00"
          required
        />
      </div>

      <div class="form-group">
        <label class="form-label">E-mail</label>
        <input
          type="email"
          v-model="form.email"
          class="form-control"
          placeholder="Ex: joao@email.com"
          required
        />
      </div>

      <div class="row">
        <div class="half-width form-group">
          <label class="form-label">Telefone</label>
          <input
            type="text"
            :value="form.telefone"
            @input="onTelefoneInput"
            class="form-control"
            placeholder="Ex: (11) 99999-9999"
          />
        </div>
        <div class="half-width form-group">
          <label class="form-label">Endereço</label>
          <input
            type="text"
            v-model="form.endereco"
            class="form-control"
            placeholder="Ex: Av. Paulista, 1000"
          />
        </div>
      </div>
    </form>

    <template #actions>
      <button type="button" class="btn btn-secondary" @click="$emit('close')" :disabled="loading">
        Cancelar
      </button>
      <button
        type="button"
        class="btn btn-primary"
        :disabled="loading || !isFormValid"
        @click="onSubmit"
      >
        <span v-if="loading" class="btn-spinner"></span>
        <span>{{ isEditMode ? 'Salvar' : 'Cadastrar' }}</span>
      </button>
    </template>
  </Modal>
</template>

<script setup lang="ts">
import { ref, computed, watch } from 'vue'
import { Cliente } from '@/types'
import { api } from '@/services/api'
import Modal from './Modal.vue'
import { formatarCpfCnpj, formatarTelefone } from '@/utils/formatters'

const props = defineProps({
  show: {
    type: Boolean,
    required: true
  },
  client: {
    type: Object as () => Cliente | null,
    default: null
  }
})

const emit = defineEmits(['close', 'save'])

const loading = ref(false)
const isEditMode = computed(() => !!props.client?.id)

const form = ref<Cliente>({
  nome: '',
  cpf_cnpj: '',
  email: '',
  telefone: '',
  endereco: ''
})

watch(
  () => props.show,
  (newShow) => {
    if (newShow) {
      if (props.client) {
        form.value = {
          ...props.client,
          cpf_cnpj: formatarCpfCnpj(props.client.cpf_cnpj),
          telefone: formatarTelefone(props.client.telefone || '')
        }
      } else {
        form.value = {
          nome: '',
          cpf_cnpj: '',
          email: '',
          telefone: '',
          endereco: ''
        }
      }
    }
  },
  { immediate: true }
)

function onCpfCnpjInput(e: Event) {
  const input = e.target as HTMLInputElement
  const formatted = formatarCpfCnpj(input.value)
  form.value.cpf_cnpj = formatted
  input.value = formatted
}

function onTelefoneInput(e: Event) {
  const input = e.target as HTMLInputElement
  const formatted = formatarTelefone(input.value)
  form.value.telefone = formatted
  input.value = formatted
}

const isFormValid = computed(() => {
  const cleanCpfCnpj = form.value.cpf_cnpj.replace(/\D/g, '')
  return (
    form.value.nome &&
    form.value.nome.length >= 3 &&
    (cleanCpfCnpj.length === 11 || cleanCpfCnpj.length === 14) &&
    form.value.email &&
    /\S+@\S+\.\S+/.test(form.value.email)
  )
})

async function onSubmit() {
  if (!isFormValid.value) return
  
  loading.value = true
  try {
    if (isEditMode.value && props.client?.id) {
      await api.put<Cliente>(`/api/clients/${props.client.id}`, form.value)
    } else {
      await api.post<Cliente>('/api/clients', form.value)
    }
    emit('save')
  } catch (err) {
    console.error('Erro ao salvar cliente:', err)
  } finally {
    loading.value = false
  }
}
</script>

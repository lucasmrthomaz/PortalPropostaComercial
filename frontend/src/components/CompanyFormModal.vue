<template>
  <Modal :show="show" :title="isEditMode ? 'Editar Empresa Parceira' : 'Nova Empresa Parceira'" icon="business" width="650px" @close="$emit('close')">
    <form @submit.prevent="onSubmit" class="form-container">
      
      <!-- Section 1 -->
      <div class="form-section">
        <h3>Dados Corporativos</h3>
        <div class="form-group">
          <label class="form-label">Razão Social / Nome Fantasia</label>
          <input
            type="text"
            v-model="form.nome"
            class="form-control"
            placeholder="Ex: Alfa Seguros S/A"
            required
          />
        </div>

        <div class="row">
          <div class="half-width form-group">
            <label class="form-label">CNPJ</label>
            <input
              type="text"
              :value="form.cnpj"
              @input="onCnpjInput"
              class="form-control"
              placeholder="Ex: 00.000.000/0000-00"
              required
            />
          </div>
          <div class="half-width form-group">
            <label class="form-label">E-mail Corporativo</label>
            <input
              type="email"
              v-model="form.email"
              class="form-control"
              placeholder="contato@empresa.com"
              required
            />
          </div>
        </div>

        <div class="row">
          <div class="half-width form-group">
            <label class="form-label">Telefone Comercial</label>
            <input
              type="text"
              :value="form.telefone"
              @input="onTelefoneInput"
              class="form-control"
              placeholder="Ex: (11) 4004-0000"
            />
          </div>
          <div class="half-width switch-wrapper">
            <label class="switch-container">
              <input type="checkbox" v-model="form.ativo" class="switch-input" />
              <span class="switch-slider"></span>
              <span>Empresa Ativa</span>
            </label>
          </div>
        </div>
      </div>

      <!-- Section 2 -->
      <div class="form-section sec-representative">
        <h3>Representante / Responsável Operacional</h3>
        <div class="form-group">
          <label class="form-label">Nome do Responsável</label>
          <input
            type="text"
            v-model="form.responsavel_nome"
            class="form-control"
            placeholder="Ex: Roberto Carlos"
            required
          />
        </div>

        <div class="row">
          <div class="half-width form-group">
            <label class="form-label">E-mail do Responsável</label>
            <input
              type="email"
              v-model="form.responsavel_email"
              class="form-control"
              placeholder="roberto@empresa.com"
            />
          </div>
          <div class="half-width form-group">
            <label class="form-label">Telefone do Responsável</label>
            <input
              type="text"
              :value="form.responsavel_telefone"
              @input="onResponsavelTelefoneInput"
              class="form-control"
              placeholder="Ex: (11) 99999-9999"
            />
          </div>
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
import { Empresa } from '@/types'
import { api } from '@/services/api'
import Modal from './Modal.vue'
import { formatarCNPJ, formatarTelefone } from '@/utils/formatters'

const props = defineProps({
  show: {
    type: Boolean,
    required: true
  },
  company: {
    type: Object as () => Empresa | null,
    default: null
  }
})

const emit = defineEmits(['close', 'save'])

const loading = ref(false)
const isEditMode = computed(() => !!props.company?.id)

const form = ref<Empresa>({
  nome: '',
  cnpj: '',
  email: '',
  telefone: '',
  responsavel_nome: '',
  responsavel_email: '',
  responsavel_telefone: '',
  ativo: true
})

watch(
  () => props.show,
  (newShow) => {
    if (newShow) {
      if (props.company) {
        form.value = {
          ...props.company,
          cnpj: formatarCNPJ(props.company.cnpj),
          telefone: formatarTelefone(props.company.telefone || ''),
          responsavel_telefone: formatarTelefone(props.company.responsavel_telefone || ''),
          ativo: props.company.ativo !== false
        }
      } else {
        form.value = {
          nome: '',
          cnpj: '',
          email: '',
          telefone: '',
          responsavel_nome: '',
          responsavel_email: '',
          responsavel_telefone: '',
          ativo: true
        }
      }
    }
  },
  { immediate: true }
)

function onCnpjInput(e: Event) {
  const input = e.target as HTMLInputElement
  const formatted = formatarCNPJ(input.value)
  form.value.cnpj = formatted
  input.value = formatted
}

function onTelefoneInput(e: Event) {
  const input = e.target as HTMLInputElement
  const formatted = formatarTelefone(input.value)
  form.value.telefone = formatted
  input.value = formatted
}

function onResponsavelTelefoneInput(e: Event) {
  const input = e.target as HTMLInputElement
  const formatted = formatarTelefone(input.value)
  form.value.responsavel_telefone = formatted
  input.value = formatted
}

const isFormValid = computed(() => {
  const f = form.value
  const cleanCnpj = f.cnpj.replace(/\D/g, '')
  return (
    f.nome &&
    cleanCnpj.length === 14 &&
    f.email &&
    /\S+@\S+\.\S+/.test(f.email) &&
    f.responsavel_nome &&
    (!f.responsavel_email || /\S+@\S+\.\S+/.test(f.responsavel_email))
  )
})

async function onSubmit() {
  if (!isFormValid.value) return
  
  loading.value = true
  try {
    if (isEditMode.value && props.company?.id) {
      await api.put<Empresa>(`/api/companies/${props.company.id}`, form.value)
    } else {
      await api.post<Empresa>('/api/companies', form.value)
    }
    emit('save')
  } catch (err) {
    console.error('Erro ao salvar empresa:', err)
  } finally {
    loading.value = false
  }
}
</script>

<style scoped>
@import "./css/CompanyFormModal.css";
</style>

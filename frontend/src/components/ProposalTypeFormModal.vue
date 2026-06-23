<template>
  <Modal :show="show" :title="isEditMode ? 'Editar Tipo de Proposta' : 'Novo Tipo de Proposta'" icon="description" width="800px" @close="$emit('close')">
    <form @submit.prevent="onSubmit" class="form-container">
      <div class="row">
        <div class="half-width form-group">
          <label class="form-label">Nome do Tipo</label>
          <input
            type="text"
            v-model="form.nome"
            class="form-control"
            placeholder="Ex: Financiamento de Máquinas"
            :disabled="isLegacy"
            required
            @input="onNameInput"
          />
        </div>
        <div class="half-width form-group">
          <label class="form-label">Chave (Identificador Único)</label>
          <input
            type="text"
            v-model="form.chave"
            class="form-control"
            placeholder="Ex: FinanciamentoMaquinas"
            :disabled="isEditMode || isLegacy"
            required
          />
        </div>
      </div>

      <div class="divider"></div>

      <!-- Fields list -->
      <div class="fields-section">
        <div class="section-header-action">
          <h3>Campos Customizados</h3>
          <button
            type="button"
            class="btn btn-secondary btn-sm"
            @click="addField"
            :disabled="isLegacy"
            style="display: flex; align-items: center; gap: 4px;"
          >
            <i class="material-icons">add</i> Adicionar Campo
          </button>
        </div>

        <p v-if="isLegacy" class="legacy-note">
          Tipos nativos do sistema não permitem alteração de estrutura de campos.
        </p>

        <div v-if="form.campos.length === 0" class="no-fields-msg">
          Este tipo de proposta não possui campos customizados. Clique em adicionar para criar um.
        </div>

        <div v-else class="fields-list">
          <div v-for="(campo, idx) in form.campos" :key="idx" class="field-item-row">
            <!-- Field name -->
            <div class="field-col form-group" style="flex: 2;">
              <label class="form-label">Nome do Campo</label>
              <input
                type="text"
                v-model="campo.nome"
                class="form-control"
                placeholder="Ex: Cor do Veículo"
                :disabled="isLegacy"
                required
                @input="onFieldNameInput(idx)"
              />
            </div>

            <!-- Field key -->
            <div class="field-col form-group" style="flex: 2;">
              <label class="form-label">Chave (Slug)</label>
              <input
                type="text"
                v-model="campo.chave"
                class="form-control"
                placeholder="Ex: cor_veiculo"
                disabled
                required
              />
            </div>

            <!-- Field type -->
            <div class="field-col form-group" style="flex: 1.5;">
              <label class="form-label">Tipo de Dado</label>
              <select
                v-model="campo.tipo"
                class="form-control"
                :disabled="isLegacy"
                required
              >
                <option value="text">Texto</option>
                <option value="number">Número</option>
                <option value="boolean">Sim/Não</option>
              </select>
            </div>

            <!-- Mandatory switch -->
            <div class="field-col form-group checkbox-col" style="flex: 1; align-items: center;">
              <label class="form-label">Obrigatório</label>
              <label class="switch-container">
                <input type="checkbox" v-model="campo.obrigatorio" class="switch-input" :disabled="isLegacy" />
                <span class="switch-slider"></span>
              </label>
            </div>

            <!-- Action -->
            <div class="field-col action-col" v-if="!isLegacy" style="margin-bottom: 8px;">
              <button type="button" class="btn-icon btn-icon-danger" @click="removeField(idx)">
                <i class="material-icons">delete</i>
              </button>
            </div>
          </div>
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
import { TipoProposta, CampoTipoProposta } from '@/types'
import Modal from './Modal.vue'

const props = defineProps({
  show: {
    type: Boolean,
    required: true
  },
  proposalType: {
    type: Object as () => TipoProposta | null,
    default: null
  }
})

const emit = defineEmits(['close', 'save'])

const isEditMode = computed(() => !!props.proposalType?.id)
const isLegacy = computed(() => {
  return (
    isEditMode.value &&
    (props.proposalType?.chave === 'Imobiliaria' ||
      props.proposalType?.chave === 'Auto' ||
      props.proposalType?.chave === 'Comissionados')
  )
})

const form = ref<{
  nome: string
  chave: string
  campos: CampoTipoProposta[]
}>({
  nome: '',
  chave: '',
  campos: []
})

watch(
  () => props.show,
  (newShow) => {
    if (newShow) {
      if (props.proposalType) {
        let fieldsList: CampoTipoProposta[] = []
        const rawFields = props.proposalType.campos
        if (rawFields) {
          if (typeof rawFields === 'string') {
            try {
              fieldsList = JSON.parse(rawFields)
            } catch {
              fieldsList = []
            }
          } else {
            fieldsList = rawFields as CampoTipoProposta[]
          }
        }
        form.value = {
          nome: props.proposalType.nome,
          chave: props.proposalType.chave,
          campos: fieldsList.map(c => ({ ...c, obrigatorio: c.obrigatorio !== false }))
        }
      } else {
        form.value = {
          nome: '',
          chave: '',
          campos: []
        }
      }
    }
  },
  { immediate: true }
)

function addField() {
  if (isLegacy.value) return
  form.value.campos.push({
    nome: '',
    chave: '',
    tipo: 'text',
    obrigatorio: true
  })
}

function removeField(index: number) {
  if (isLegacy.value) return
  form.value.campos.splice(index, 1)
}

function onNameInput() {
  if (isEditMode.value || isLegacy.value) return
  form.value.chave = slugify(form.value.nome)
}

function onFieldNameInput(idx: number) {
  if (isLegacy.value) return
  const f = form.value.campos[idx]
  f.chave = slugifyField(f.nome)
}

function slugify(text: string): string {
  return text
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '') // remove acentos
    .replace(/[^a-zA-Z0-9]/g, '') // remove tudo exceto letras e numeros
}

function slugifyField(text: string): string {
  return text
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '') // remove acentos
    .toLowerCase()
    .replace(/[^a-z0-9]/g, '_') // substitui nao-alfanumericos por _
    .replace(/_+/g, '_') // substitui multiplos _ por um unico
    .replace(/^_+|_+$/g, '') // remove _ no inicio e fim
}

const isFormValid = computed(() => {
  const f = form.value
  if (!f.nome || !f.chave) return false
  
  // Verify all fields are valid
  for (const c of f.campos) {
    if (!c.nome || !c.chave || !c.tipo) return false
  }
  return true
})

function onSubmit() {
  if (!isFormValid.value) return
  
  const payload: TipoProposta = {
    nome: form.value.nome,
    chave: form.value.chave,
    campos: form.value.campos
  }
  
  if (props.proposalType?.id) {
    payload.id = props.proposalType.id
  }
  
  emit('save', payload)
}
</script>

<style scoped>
@import "./css/ProposalTypeFormModal.css";
</style>

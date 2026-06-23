<template>
  <Modal :show="show" title="Encaminhar Proposta" icon="business" width="450px" @close="$emit('close')">
    <p class="description">Selecione a empresa parceira para a qual deseja encaminhar esta proposta:</p>
    
    <div class="form-group" style="margin-top: 16px;">
      <label class="form-label">Empresa Parceira</label>
      <select v-model="selectedCompanyId" class="form-control" required>
        <option value="" disabled>Selecione a empresa...</option>
        <option v-for="c in companies" :key="c.id" :value="c.id">
          {{ c.nome }} (Resp: {{ c.responsavel_nome }})
        </option>
      </select>
    </div>

    <template #actions>
      <button type="button" class="btn btn-secondary" @click="$emit('close')">
        Cancelar
      </button>
      <button type="button" class="btn btn-primary" :disabled="!selectedCompanyId" @click="onSubmit">
        Avançar
      </button>
    </template>
  </Modal>
</template>

<script setup lang="ts">
import { ref, watch } from 'vue'
import { Empresa } from '@/types'
import { api } from '@/services/api'
import Modal from './Modal.vue'

const props = defineProps({
  show: {
    type: Boolean,
    required: true
  }
})

const emit = defineEmits(['close', 'forward'])

const companies = ref<Empresa[]>([])
const selectedCompanyId = ref('')

watch(
  () => props.show,
  async (newShow) => {
    if (newShow) {
      selectedCompanyId.value = ''
      try {
        const res = await api.get<Empresa[]>('/api/companies')
        companies.value = res.filter(c => c.ativo !== false)
      } catch (err) {
        console.error('Erro ao carregar empresas parceiras:', err)
      }
    }
  }
)

function onSubmit() {
  if (!selectedCompanyId.value) return
  emit('forward', selectedCompanyId.value)
}
</script>

<style scoped>
@import "./css/ForwardProposalModal.css";
</style>

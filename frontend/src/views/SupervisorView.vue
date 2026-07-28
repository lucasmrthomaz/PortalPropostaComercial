<template>
  <div>
    <div class="list-header">
      <div>
        <h1>Painel do Supervisor</h1>
        <p>Inbox de solicitações de aprovação de segurança e análises de comissão.</p>
      </div>
    </div>

    <!-- DataTable -->
    <DataTable
      :columns="supervisorColumns"
      :rows="filteredRequests"
      :loading="loading"
      empty-icon="security"
      empty-text="Nenhuma solicitação de análise registrada no momento."
      paginate
      :per-page="perPage"
    >
      <!-- Filter slot -->
      <template #filter>
        <FilterField
          v-model="searchQuery"
          type="search"
          placeholder="Buscar por ação ou detalhes..."
        />
      </template>
      <!-- Custom cell: Ação -->
      <template #cell-acao="{ row: req }">
        <strong>{{ getActionLabel(req.tipo_acao) }}</strong>
      </template>

      <!-- Custom cell: Status -->
      <template #cell-status="{ row: req }">
        <span class="status-tag" :class="req.status ? req.status.toLowerCase() : 'pendente'">
          {{ getStatusLabel(req.status) }}
        </span>
      </template>

      <!-- Actions slot: decision buttons -->
      <template #actions="{ row: req }">
        <template v-if="req.status === 'Pendente'">
          <button class="btn btn-success btn-sm decision-btn" @click="approveRequest(req)">
            <i class="material-icons">check</i> Aprovar
          </button>
          <button class="btn btn-danger btn-sm decision-btn" @click="rejectRequest(req)">
            <i class="material-icons">close</i> Recusar
          </button>
        </template>
        <span v-else class="processed-text">Já processado</span>
      </template>
    </DataTable>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { PedidoAnalise } from '@/types'
import { api } from '@/services/api'
import DataTable from '@/components/DataTable.vue'
import FilterField from '@/components/FilterField.vue'
import { getActionLabel, formatDateTime } from '@/composables/useFormatting'

const requests = ref<PedidoAnalise[]>([])
const loading = ref(true)
const perPage = ref(10)
const searchQuery = ref('')

const supervisorColumns = [
  { key: 'acao', label: 'Ação Requisitada' },
  { key: 'descricao', label: 'Detalhes da Operação' },
  { key: 'status', label: 'Status' },
  { key: 'created_at', label: 'Data / Hora', responsive: 'created_at', formatter: (v: string) => formatDateTime(v) },
  { key: 'actions', label: 'Ações de Decisão' }
]

const filteredRequests = computed(() => {
  if (!searchQuery.value.trim()) return requests.value
  const query = searchQuery.value.toLowerCase().trim()
  return requests.value.filter(r =>
    getActionLabel(r.tipo_acao).toLowerCase().includes(query) ||
    (r.descricao || '').toLowerCase().includes(query)
  )
})

onMounted(loadRequests)

async function loadRequests() {
  loading.value = true
  try {
    requests.value = await api.get<PedidoAnalise[]>('/api/supervisor/requests')
  } catch (err) {
    console.error('Erro ao carregar solicitações:', err)
  } finally {
    loading.value = false
  }
}

async function approveRequest(req: PedidoAnalise) {
  if (!req.id) return
  loading.value = true
  try {
    await api.post(`/api/supervisor/requests/${req.id}/approve`, {})
    alert('Solicitação aprovada e executada com sucesso!')
    loadRequests()
  } catch (err: any) {
    alert(err.error || 'Erro ao aprovar solicitação.')
    loading.value = false
  }
}

async function rejectRequest(req: PedidoAnalise) {
  if (!req.id) return
  if (confirm('Deseja realmente recusar esta solicitação de análise?')) {
    loading.value = true
    try {
      await api.post(`/api/supervisor/requests/${req.id}/reject`, {})
      alert('Solicitação recusada com sucesso.')
      loadRequests()
    } catch (err: any) {
      alert(err.error || 'Erro ao recusar solicitação.')
      loading.value = false
    }
  }
}

function getStatusLabel(status?: string): string {
  switch (status) {
    case 'Pendente': return 'Pendente'
    case 'Aprovado': return 'Aprovado'
    case 'Recusado': return 'Recusado'
    default: return status || 'Pendente'
  }
}
</script>

<style scoped>
@import "./css/SupervisorView.css";
</style>

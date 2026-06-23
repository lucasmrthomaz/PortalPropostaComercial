<template>
  <div>
    <div class="list-header">
      <div>
        <h1>Painel do Supervisor</h1>
        <p>Inbox de solicitações de aprovação de segurança e análises de comissão.</p>
      </div>
    </div>

    <!-- Table Card -->
    <div class="card table-card mat-elevation-z4">
      <div v-if="loading" class="spinner-container">
        <div class="spinner"></div>
      </div>

      <div v-else class="table-container">
        <table class="data-table">
          <thead>
            <tr>
              <th>Ação Requisitada</th>
              <th>Detalhes da Operação</th>
              <th>Status</th>
              <th class="col-created_at">Data / Hora</th>
              <th class="actions-header" style="text-align: right; min-width: 220px;">Ações de Decisão</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="req in requests" :key="req.id">
              <td>
                <strong>{{ getActionLabel(req.tipo_acao) }}</strong>
              </td>
              <td>{{ req.descricao }}</td>
              <td>
                <span class="status-tag" :class="req.status ? req.status.toLowerCase() : 'pendente'">
                  {{ getStatusLabel(req.status) }}
                </span>
              </td>
              <td class="col-created_at">{{ formatDate(req.created_at) }}</td>
              <td class="actions-cell">
                <div class="actions-wrapper stack-mobile" style="justify-content: flex-end;">
                  <template v-if="req.status === 'Pendente'">
                    <button class="btn btn-primary btn-sm decision-btn approve" @click="approveRequest(req)">
                      <i class="material-icons">check</i> Aprovar
                    </button>
                    <button class="btn btn-danger btn-sm decision-btn reject" @click="rejectRequest(req)">
                      <i class="material-icons">close</i> Recusar
                    </button>
                  </template>
                  <span v-else class="processed-text">Já processado</span>
                </div>
              </td>
            </tr>
            <tr v-if="requests.length === 0">
              <td colspan="5" class="no-data-placeholder">
                <i class="material-icons">security</i>
                <span>Nenhuma solicitação de análise registrada no momento.</span>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { PedidoAnalise } from '@/types'
import { api } from '@/services/api'

const requests = ref<PedidoAnalise[]>([])
const loading = ref(true)

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

function getActionLabel(action: string): string {
  switch (action) {
    case 'DeletarCliente': return 'Excluir Cliente'
    case 'DeletarProposta': return 'Excluir Proposta'
    case 'AprovarProposta': return 'Aprovar Proposta'
    case 'EncaminharEmpresa': return 'Encaminhar para Empresa'
    default: return action
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

function formatDate(dateStr?: string): string {
  if (!dateStr) return ''
  const date = new Date(dateStr)
  return new Intl.DateTimeFormat('pt-BR', { day: '2-digit', month: '2-digit', year: 'numeric', hour: '2-digit', minute: '2-digit' }).format(date)
}
</script>

<style scoped>
@import "./css/SupervisorView.css";
</style>

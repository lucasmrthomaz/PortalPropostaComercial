<template>
  <div>
    <div class="list-header">
      <div>
        <h1>Propostas Comerciais</h1>
        <p>Gerencie e acompanhe o andamento de todas as propostas comerciais e comissões.</p>
      </div>
      <button class="btn btn-primary" @click="openFormModal(null)">
        <i class="material-icons">add</i> Nova Proposta
      </button>
    </div>

    <!-- Filters Header -->
    <div class="card table-card mat-elevation-z4">
      <div class="filter-header">
        <!-- Client Filter -->
        <div class="form-group filter-field">
          <label class="form-label">Filtrar por Cliente</label>
          <select v-model="selectedClientFilter" class="form-control" @change="applyFilters">
            <option value="all">Todos os clientes</option>
            <option v-for="client in clients" :key="client.id" :value="client.id">
              {{ client.nome }}
            </option>
          </select>
        </div>

        <!-- Type Filter -->
        <div class="form-group filter-field">
          <label class="form-label">Filtrar por Tipo</label>
          <select v-model="selectedTypeFilter" class="form-control" @change="applyFilters">
            <option value="all">Todos os tipos</option>
            <option v-for="t in proposalTypes" :key="t.id" :value="t.chave">
              {{ t.nome }}
            </option>
          </select>
        </div>

        <!-- Status Filter -->
        <div class="form-group filter-field">
          <label class="form-label">Filtrar por Status</label>
          <select v-model="selectedStatusFilter" class="form-control" @change="applyFilters">
            <option value="all">Todos os status</option>
            <option value="Pendente">Pendente</option>
            <option value="Em Analise">Em Análise</option>
            <option value="Aprovada">Aprovada</option>
            <option value="Recusada">Recusada</option>
          </select>
        </div>
      </div>

      <div v-if="loading" class="spinner-container">
        <div class="spinner"></div>
      </div>

      <div v-else class="table-container">
        <table class="data-table">
          <thead>
            <tr>
              <th>Cliente</th>
              <th>Tipo</th>
              <th>Valor</th>
              <th class="col-empresa">Empresa Parceira</th>
              <th class="col-comissao">Comissão</th>
              <th>Status</th>
              <th class="col-created_at">Cadastro</th>
              <th class="actions-header" style="text-align: right;">Ações</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="p in filteredProposals" :key="p.id">
              <td>
                <strong>{{ getClientName(p.cliente_id) }}</strong>
              </td>
              <td>{{ getTypeLabel(p.tipo) }}</td>
              <td>
                <strong>{{ formatCurrency(p.valor) }}</strong>
              </td>
              <td class="col-empresa">{{ getCompanyName(p.empresa_id) }}</td>
              <td class="col-comissao">
                <span v-if="p.valor_comissao !== undefined">{{ formatCurrency(p.valor_comissao) }}</span>
                <span v-else-if="p.empresa_id">{{ formatCurrency(p.valor * (globalTaxRate / 100)) }}</span>
                <span v-else>—</span>
              </td>
              <td>
                <span class="status-tag" :class="p.status.toLowerCase().replace(' ', '-')">
                  {{ getStatusLabel(p.status) }}
                </span>
              </td>
              <td class="col-created_at">{{ formatDate(p.created_at) }}</td>
              <td class="actions-cell">
                <div class="actions-wrapper">
                  <button class="btn-icon" @click="viewDetails(p)" title="Ver Detalhes">
                    <i class="material-icons">visibility</i>
                  </button>
                  <button class="btn-icon" @click="openFormModal(p)" title="Editar Proposta">
                    <i class="material-icons">edit</i>
                  </button>
                  <button class="btn-icon btn-icon-danger" @click="confirmDelete(p)" title="Excluir Proposta">
                    <i class="material-icons">delete</i>
                  </button>
                  
                  <button v-if="p.status !== 'Aprovada' && p.status !== 'Recusada'" class="btn-icon" @click="confirmApprove(p)" title="Aprovar Proposta" style="color: var(--success);">
                    <i class="material-icons">check_circle_outline</i>
                  </button>
                  <button v-if="!p.empresa_id" class="btn-icon" @click="openForwardModal(p)" title="Encaminhar para Empresa" style="color: var(--warning);">
                    <i class="material-icons">send</i>
                  </button>
                </div>
              </td>
            </tr>
            <tr v-if="filteredProposals.length === 0">
              <td colspan="8" class="no-data-placeholder">
                <i class="material-icons">assignment_late</i>
                <span>Nenhuma proposta encontrada.</span>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>

    <!-- Modals -->
    <ProposalFormModal
      :show="showFormModal"
      :proposal="selectedProposal"
      @close="showFormModal = false"
      @save="onProposalSaved"
    />

    <ProposalDetailsModal
      :show="showDetailsModal"
      :proposal="selectedProposal"
      :clientName="getClientName(selectedProposal?.cliente_id || '')"
      @close="showDetailsModal = false"
    />

    <ForwardProposalModal
      :show="showForwardSelectModal"
      @close="showForwardSelectModal = false"
      @forward="onCompanySelected"
    />

    <SupervisorDialog
      :show="showSupervisorModal"
      :title="supervisorTitle"
      :description="supervisorDesc"
      :pedido="supervisorPedido"
      @close="showSupervisorModal = false"
      @confirm="onSupervisorConfirmed"
      @submit="onSupervisorSubmitted"
    />
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, watch } from 'vue'
import { useRoute } from 'vue-router'
import { Proposta, Cliente, Empresa, TipoProposta } from '@/types'
import { api } from '@/services/api'
import ProposalFormModal from '@/components/ProposalFormModal.vue'
import ProposalDetailsModal from '@/components/ProposalDetailsModal.vue'
import ForwardProposalModal from '@/components/ForwardProposalModal.vue'
import SupervisorDialog from '@/components/SupervisorDialog.vue'

const route = useRoute()

const proposals = ref<Proposta[]>([])
const clients = ref<Cliente[]>([])
const companies = ref<Empresa[]>([])
const proposalTypes = ref<TipoProposta[]>([])
const loading = ref(true)
const globalTaxRate = ref(5.0)

// Filters
const selectedClientFilter = ref('all')
const selectedTypeFilter = ref('all')
const selectedStatusFilter = ref('all')

// Modals
const showFormModal = ref(false)
const selectedProposal = ref<any>(null)

const showDetailsModal = ref(false)

const showForwardSelectModal = ref(false)
const proposalToForward = ref<Proposta | null>(null)

// Supervisor Dialog
const showSupervisorModal = ref(false)
const supervisorTitle = ref('')
const supervisorDesc = ref('')
const supervisorPedido = ref<any>({})
const supervisorAction = ref<'delete' | 'approve' | 'forward'>('delete')
const selectedForwardCompanyId = ref('')

onMounted(async () => {
  loading.value = true
  await Promise.all([
    loadClients(),
    loadCompanies(),
    loadProposalTypes(),
    loadTaxRate()
  ])
  await loadProposals()
  
  if (route.query.clienteId) {
    selectedClientFilter.value = String(route.query.clienteId)
  }
  loading.value = false
})

watch(
  () => route.query.clienteId,
  (newVal) => {
    if (newVal) {
      selectedClientFilter.value = String(newVal)
    } else {
      selectedClientFilter.value = 'all'
    }
  }
)

async function loadClients() {
  try {
    clients.value = await api.get<Cliente[]>('/api/clients')
  } catch (err) {
    console.error(err)
  }
}

async function loadCompanies() {
  try {
    companies.value = await api.get<Empresa[]>('/api/companies')
  } catch (err) {
    console.error(err)
  }
}

async function loadProposalTypes() {
  try {
    proposalTypes.value = await api.get<TipoProposta[]>('/api/proposal-types')
  } catch (err) {
    console.error(err)
  }
}

async function loadTaxRate() {
  try {
    const res = await api.get<any>('/api/settings')
    globalTaxRate.value = res.taxa_corretagem || 5.0
  } catch (err) {
    console.error(err)
  }
}

async function loadProposals() {
  try {
    proposals.value = await api.get<Proposta[]>('/api/proposals')
  } catch (err) {
    console.error(err)
  }
}

function applyFilters() {
  // handled reactively by computed
}

const filteredProposals = computed(() => {
  let list = proposals.value
  
  if (selectedClientFilter.value !== 'all') {
    list = list.filter(p => p.cliente_id === selectedClientFilter.value)
  }
  if (selectedTypeFilter.value !== 'all') {
    list = list.filter(p => p.tipo === selectedTypeFilter.value)
  }
  if (selectedStatusFilter.value !== 'all') {
    list = list.filter(p => p.status === selectedStatusFilter.value)
  }
  
  return list
})

function getClientName(id: string): string {
  const found = clients.value.find(c => c.id === id)
  return found ? found.nome : '—'
}

function getCompanyName(id?: string): string {
  if (!id) return '—'
  const found = companies.value.find(c => c.id === id)
  return found ? found.nome : '—'
}

function getTypeLabel(tipo: string): string {
  const found = proposalTypes.value.find(t => t.chave === tipo)
  return found ? found.nome : tipo
}

function getStatusLabel(status: string): string {
  switch (status) {
    case 'Pendente': return 'Pendente'
    case 'Aprovada': return 'Aprovada'
    case 'Recusada': return 'Recusada'
    case 'Em Analise': return 'Em Análise'
    default: return status
  }
}

function formatCurrency(val: number): string {
  if (val === undefined || val === null) return 'R$ 0,00'
  return new Intl.NumberFormat('pt-BR', { style: 'currency', currency: 'BRL' }).format(val)
}

function formatDate(dateStr?: string): string {
  if (!dateStr) return '—'
  const date = new Date(dateStr)
  return new Intl.DateTimeFormat('pt-BR', { day: '2-digit', month: '2-digit', year: 'numeric' }).format(date)
}

function openFormModal(proposal: any) {
  selectedProposal.value = proposal
  showFormModal.value = true
}

function onProposalSaved() {
  showFormModal.value = false
  loadProposals()
}

function viewDetails(proposal: Proposta) {
  selectedProposal.value = proposal
  showDetailsModal.value = true
}

function confirmDelete(proposal: Proposta) {
  if (!proposal.id) return
  selectedProposal.value = proposal
  supervisorAction.value = 'delete'
  supervisorTitle.value = 'Excluir Proposta Comercial'
  
  const clientName = getClientName(proposal.cliente_id)
  supervisorDesc.value = `Você está tentando excluir permanentemente a proposta de ${formatCurrency(proposal.valor)} do cliente ${clientName}.`
  
  supervisorPedido.value = {
    tipo_acao: 'DeletarProposta',
    entidade_id: proposal.id,
    entidade_tipo: 'Proposta',
    descricao: `Excluir proposta comercial de R$ ${proposal.valor} (Cliente: ${clientName}).`,
    dados_acao: JSON.stringify({ proposta_id: proposal.id })
  }
  
  showSupervisorModal.value = true
}

function confirmApprove(proposal: Proposta) {
  if (!proposal.id) return
  selectedProposal.value = proposal
  supervisorAction.value = 'approve'
  supervisorTitle.value = 'Aprovar Proposta Comercial'
  
  const clientName = getClientName(proposal.cliente_id)
  supervisorDesc.value = `Você está tentando aprovar a proposta de ${formatCurrency(proposal.valor)} do cliente ${clientName}. Isso ativará a cobrança de corretagem caso haja empresa parceira vinculada.`
  
  supervisorPedido.value = {
    tipo_acao: 'AprovarProposta',
    entidade_id: proposal.id,
    entidade_tipo: 'Proposta',
    descricao: `Aprovar proposta comercial de R$ ${proposal.valor} para o cliente ${clientName}.`,
    dados_acao: JSON.stringify({ proposta_id: proposal.id })
  }
  
  showSupervisorModal.value = true
}

function openForwardModal(proposal: Proposta) {
  proposalToForward.value = proposal
  showForwardSelectModal.value = true
}

function onCompanySelected(companyId: string) {
  showForwardSelectModal.value = false
  const p = proposalToForward.value
  if (!p || !p.id) return
  
  selectedForwardCompanyId.value = companyId
  supervisorAction.value = 'forward'
  supervisorTitle.value = 'Encaminhar Proposta'
  
  const company = companies.value.find(c => c.id === companyId)
  const companyName = company ? company.nome : '—'
  const clientName = getClientName(p.cliente_id)
  
  supervisorDesc.value = `Você está tentando encaminhar os dados da proposta de ${formatCurrency(p.valor)} do cliente "${clientName}" para a empresa parceira "${companyName}".`
  
  supervisorPedido.value = {
    tipo_acao: 'EncaminharEmpresa',
    entidade_id: p.id,
    entidade_tipo: 'Proposta',
    descricao: `Encaminhar proposta comercial de R$ ${p.valor} (Cliente: ${clientName}) para a empresa parceira ${companyName}. Representante: ${company?.responsavel_nome}.`,
    dados_acao: JSON.stringify({ proposta_id: p.id, empresa_id: companyId })
  }
  
  showSupervisorModal.value = true
}

async function onSupervisorConfirmed() {
  showSupervisorModal.value = false
  const p = selectedProposal.value || proposalToForward.value
  if (!p || !p.id) return
  
  try {
    if (supervisorAction.value === 'delete') {
      await api.delete(`/api/proposals/${p.id}`)
      alert('Proposta excluída com sucesso!')
    } else if (supervisorAction.value === 'approve') {
      const updated = { ...p, status: 'Aprovada' }
      await api.put(`/api/proposals/${p.id}`, updated)
      alert('Proposta aprovada com sucesso!')
    } else if (supervisorAction.value === 'forward') {
      const updated = {
        ...p,
        empresa_id: selectedForwardCompanyId.value,
        status_corretagem: 'Encaminhada'
      }
      await api.put(`/api/proposals/${p.id}`, updated)
      alert('Proposta encaminhada com sucesso!')
    }
    loadProposals()
  } catch (err: any) {
    alert(err.error || 'Erro ao executar ação.')
  }
}

function onSupervisorSubmitted() {
  showSupervisorModal.value = false
  loadProposals()
}
</script>

<style scoped>
@import "./css/ProposalsView.css";
</style>

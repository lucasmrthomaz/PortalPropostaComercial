<template>
  <div>
    <div class="list-header">
      <div>
        <h1>Clientes</h1>
        <p>Gerencie os clientes cadastrados e suas propostas comerciais.</p>
      </div>
      <button class="btn btn-primary" @click="openFormModal(null)">
        <i class="material-icons">add</i> Novo Cliente
      </button>
    </div>

    <!-- Filter Header -->
    <div class="card table-card mat-elevation-z4">
      <div class="filter-header">
        <div class="input-with-icon filter-field">
          <i class="material-icons icon-prefix">search</i>
          <input
            type="text"
            v-model="searchQuery"
            class="form-control"
            placeholder="Buscar Cliente (Nome, CPF/CNPJ...)"
          />
        </div>
      </div>

      <div v-if="loading" class="spinner-container">
        <div class="spinner"></div>
      </div>

      <div v-else class="table-container">
        <table class="data-table">
          <thead>
            <tr>
              <th>Nome Completo</th>
              <th class="col-cpf_cnpj">CPF / CNPJ</th>
              <th class="col-email">E-mail</th>
              <th class="col-telefone">Telefone</th>
              <th class="actions-header" style="text-align: right;">Ações</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="client in filteredClients" :key="client.id">
              <td>
                <strong>{{ client.nome }}</strong>
              </td>
              <td class="col-cpf_cnpj">{{ formatarCpfCnpj(client.cpf_cnpj) }}</td>
              <td class="col-email">{{ client.email }}</td>
              <td class="col-telefone">{{ formatarTelefone(client.telefone) || '—' }}</td>
              <td class="actions-cell">
                <div class="actions-wrapper">
                  <button class="btn-icon" @click="openFormModal(client)" title="Editar Cliente">
                    <i class="material-icons">edit</i>
                  </button>
                  <button class="btn-icon btn-icon-danger" @click="confirmDeleteClient(client)" title="Excluir Cliente">
                    <i class="material-icons">delete</i>
                  </button>
                  <button class="btn-icon" @click="openNewProposal(client)" title="Nova Proposta" style="color: var(--primary);">
                    <i class="material-icons">add_box</i>
                  </button>
                  <button class="btn-icon" @click="viewProposals(client)" title="Ver Propostas" style="color: var(--secondary);">
                    <i class="material-icons">assignment</i>
                  </button>
                </div>
              </td>
            </tr>
            <tr v-if="filteredClients.length === 0">
              <td colspan="5" class="no-data-placeholder">
                <i class="material-icons">people_outline</i>
                <span>Nenhum cliente cadastrado ou encontrado.</span>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>

    <!-- Modals -->
    <ClientFormModal
      :show="showFormModal"
      :client="selectedClient"
      @close="showFormModal = false"
      @save="onClientSaved"
    />

    <ProposalFormModal
      :show="showProposalModal"
      :proposal="proposalPreset"
      @close="showProposalModal = false"
      @save="onProposalSaved"
    />

    <SupervisorDialog
      :show="showDeleteModal"
      title="Excluir Cliente"
      :description="deleteDescription"
      :pedido="deletePedido"
      @close="showDeleteModal = false"
      @confirm="onDeleteConfirmed"
      @submit="onDeleteSubmitted"
    />
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { Cliente } from '@/types'
import { api } from '@/services/api'
import ClientFormModal from '@/components/ClientFormModal.vue'
import ProposalFormModal from '@/components/ProposalFormModal.vue'
import SupervisorDialog from '@/components/SupervisorDialog.vue'
import { formatarCpfCnpj, formatarTelefone } from '@/utils/formatters'

const router = useRouter()

const clients = ref<Cliente[]>([])
const loading = ref(true)
const searchQuery = ref('')

// Modal States
const showFormModal = ref(false)
const selectedClient = ref<Cliente | null>(null)

const showProposalModal = ref(false)
const proposalPreset = ref<any>(null)

const showDeleteModal = ref(false)
const clientToDelete = ref<Cliente | null>(null)
const deleteDescription = ref('')
const deletePedido = ref<any>({})

onMounted(loadClients)

async function loadClients() {
  loading.value = true
  try {
    clients.value = await api.get<Cliente[]>('/api/clients')
  } catch (err) {
    console.error('Erro ao carregar clientes:', err)
  } finally {
    loading.value = false
  }
}

const filteredClients = computed(() => {
  if (!searchQuery.value.trim()) return clients.value
  const query = searchQuery.value.toLowerCase().trim()
  return clients.value.filter(c =>
    c.nome.toLowerCase().includes(query) ||
    c.cpf_cnpj.toLowerCase().includes(query) ||
    c.email.toLowerCase().includes(query)
  )
})

function openFormModal(client: Cliente | null) {
  selectedClient.value = client
  showFormModal.value = true
}

function onClientSaved() {
  showFormModal.value = false
  loadClients()
}

function openNewProposal(client: Cliente) {
  proposalPreset.value = {
    cliente_id: client.id,
    cliente_nome: client.nome
  }
  showProposalModal.value = true
}

function onProposalSaved() {
  showProposalModal.value = false
  router.push({ name: 'proposals' })
}

function viewProposals(client: Cliente) {
  router.push({ name: 'proposals', query: { clienteId: client.id } })
}

function confirmDeleteClient(client: Cliente) {
  if (!client.id) return
  clientToDelete.value = client
  deleteDescription.value = `Você está tentando excluir o cliente "${client.nome}". Esta ação removerá todas as propostas associadas permanentemente.`
  
  deletePedido.value = {
    tipo_acao: 'DeletarCliente',
    entidade_id: client.id,
    entidade_tipo: 'Cliente',
    descricao: `Excluir o cliente "${client.nome}" (CPF/CNPJ: ${client.cpf_cnpj}) e todas as suas propostas associadas.`,
    dados_acao: JSON.stringify({ cliente_id: client.id })
  }
  
  showDeleteModal.value = true
}

async function onDeleteConfirmed() {
  showDeleteModal.value = false
  const client = clientToDelete.value
  if (!client || !client.id) return
  
  try {
    await api.delete(`/api/clients/${client.id}`)
    alert('Cliente removido com sucesso!')
    loadClients()
  } catch (err: any) {
    alert(err.error || 'Erro ao remover cliente.')
  }
}

function onDeleteSubmitted() {
  showDeleteModal.value = false
  loadClients()
}
</script>

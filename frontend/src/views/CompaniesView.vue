<template>
  <div>
    <div class="list-header">
      <div>
        <h1>Empresas Parceiras</h1>
        <p>Empresas para as quais você pode encaminhar propostas de corretagem.</p>
      </div>
      <button class="btn btn-primary" @click="openFormModal(null)">
        <i class="material-icons">add</i> Nova Empresa
      </button>
    </div>

    <!-- DataTable with filter -->
    <DataTable
      :columns="companyColumns"
      :rows="filteredCompanies"
      :loading="loading"
      empty-icon="business"
      empty-text="Nenhuma empresa encontrada."
      paginate
      :per-page="perPage"
    >
      <!-- Filter slot -->
      <template #filter>
        <FilterField
          v-model="searchQuery"
          type="search"
          placeholder="Buscar Empresa (Nome, CNPJ...)"
        />
      </template>

      <!-- Custom cell: Responsável -->
      <template #cell-responsavel="{ row: c }">
        <div v-if="c.responsavel_nome" style="display: flex; flex-direction: column; gap: 2px;">
          <strong>{{ c.responsavel_nome }}</strong>
          <span class="text-muted-small">{{ c.responsavel_email }}</span>
          <span class="text-muted-small">{{ formatarTelefone(c.responsavel_telefone) || '—' }}</span>
        </div>
        <span v-else>—</span>
      </template>

      <!-- Custom cell: Status -->
      <template #cell-status="{ row: c }">
        <span class="status-badge" :class="c.ativo ? 'active' : 'inactive'">
          <i class="material-icons" style="font-size: 16px;">{{ c.ativo ? 'check_circle' : 'cancel' }}</i>
          <span>{{ c.ativo ? 'Ativa' : 'Inativa' }}</span>
        </span>
      </template>

      <!-- Actions slot -->
      <template #actions="{ row: c }">
        <button class="btn-icon" @click="openFormModal(c)" title="Editar Empresa">
          <i class="material-icons">edit</i>
        </button>
        <button class="btn-icon btn-icon-danger" @click="deleteCompany(c)" title="Excluir Empresa">
          <i class="material-icons">delete</i>
        </button>
      </template>
    </DataTable>

    <!-- Modal Form -->
    <CompanyFormModal
      :show="showFormModal"
      :company="selectedCompany"
      @close="showFormModal = false"
      @save="onCompanySaved"
    />
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { Empresa } from '@/types'
import { api } from '@/services/api'
import DataTable from '@/components/DataTable.vue'
import FilterField from '@/components/FilterField.vue'
import CompanyFormModal from '@/components/CompanyFormModal.vue'
import { formatarCNPJ, formatarTelefone } from '@/utils/formatters'

const companies = ref<Empresa[]>([])
const loading = ref(true)
const searchQuery = ref('')
const perPage = ref(10)
const showFormModal = ref(false)
const selectedCompany = ref<Empresa | null>(null)

const companyColumns = [
  { key: 'nome', label: 'Razão Social / Fantasia', bold: true },
  { key: 'cnpj', label: 'CNPJ', responsive: 'cnpj', formatter: (v: string) => formatarCNPJ(v) },
  { key: 'email', label: 'E-mail Comercial', responsive: 'email' },
  { key: 'responsavel', label: 'Responsável / Contato' },
  { key: 'status', label: 'Status', responsive: 'status-desc' },
  { key: 'actions', label: 'Ações' }
]

onMounted(loadCompanies)

async function loadCompanies() {
  loading.value = true
  try {
    companies.value = await api.get<Empresa[]>('/api/companies')
  } catch (err) {
    console.error('Erro ao carregar empresas parceiras:', err)
  } finally {
    loading.value = false
  }
}

const filteredCompanies = computed(() => {
  if (!searchQuery.value.trim()) return companies.value
  const query = searchQuery.value.toLowerCase().trim()
  return companies.value.filter(c =>
    c.nome.toLowerCase().includes(query) ||
    c.cnpj.toLowerCase().includes(query) ||
    c.email.toLowerCase().includes(query)
  )
})

function openFormModal(company: Empresa | null) {
  selectedCompany.value = company
  showFormModal.value = true
}

function onCompanySaved() {
  showFormModal.value = false
  loadCompanies()
}

async function deleteCompany(company: Empresa) {
  if (!company.id) return
  if (confirm(`Deseja realmente excluir a empresa parceira "${company.nome}"?`)) {
    try {
      await api.delete(`/api/companies/${company.id}`)
      alert('Empresa parceira excluída com sucesso!')
      loadCompanies()
    } catch (err: any) {
      alert(err.error || 'Erro ao excluir empresa.')
    }
  }
}
</script>



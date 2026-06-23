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

    <!-- Table Card -->
    <div class="card table-card mat-elevation-z4">
      <div class="filter-header">
        <div class="input-with-icon filter-field">
          <i class="material-icons icon-prefix">search</i>
          <input
            type="text"
            v-model="searchQuery"
            class="form-control"
            placeholder="Buscar Empresa (Nome, CNPJ...)"
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
              <th>Razão Social / Fantasia</th>
              <th class="col-cnpj">CNPJ</th>
              <th class="col-email">E-mail Comercial</th>
              <th>Responsável / Contato</th>
              <th class="col-status-desc">Status</th>
              <th class="actions-header" style="text-align: right;">Ações</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="c in filteredCompanies" :key="c.id">
              <td>
                <strong>{{ c.nome }}</strong>
              </td>
              <td class="col-cnpj"><code>{{ formatarCNPJ(c.cnpj) }}</code></td>
              <td class="col-email">{{ c.email }}</td>
              <td>
                <div v-if="c.responsavel_nome" style="display: flex; flex-direction: column; gap: 2px;">
                  <strong>{{ c.responsavel_nome }}</strong>
                  <span style="font-size: 0.8rem; color: var(--text-muted);">{{ c.responsavel_email }}</span>
                  <span style="font-size: 0.8rem; color: var(--text-muted);">{{ formatarTelefone(c.responsavel_telefone) || '—' }}</span>
                </div>
                <span v-else>—</span>
              </td>
              <td class="col-status-desc">
                <span class="status-badge" :class="c.ativo ? 'active' : 'inactive'">
                  <i class="material-icons" style="font-size: 16px;">{{ c.ativo ? 'check_circle' : 'cancel' }}</i>
                  <span>{{ c.ativo ? 'Ativa' : 'Inativa' }}</span>
                </span>
              </td>
              <td class="actions-cell">
                <div class="actions-wrapper">
                  <button class="btn-icon" @click="openFormModal(c)" title="Editar Empresa">
                    <i class="material-icons">edit</i>
                  </button>
                  <button class="btn-icon btn-icon-danger" @click="deleteCompany(c)" title="Excluir Empresa">
                    <i class="material-icons">delete</i>
                  </button>
                </div>
              </td>
            </tr>
            <tr v-if="filteredCompanies.length === 0">
              <td colspan="6" class="no-data-placeholder">
                <i class="material-icons">business</i>
                <span>Nenhuma empresa encontrada.</span>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>

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
import CompanyFormModal from '@/components/CompanyFormModal.vue'
import { formatarCNPJ, formatarTelefone } from '@/utils/formatters'

const companies = ref<Empresa[]>([])
const loading = ref(true)
const searchQuery = ref('')
const showFormModal = ref(false)
const selectedCompany = ref<Empresa | null>(null)

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

<style scoped>
@import "./css/CompaniesView.css";
</style>

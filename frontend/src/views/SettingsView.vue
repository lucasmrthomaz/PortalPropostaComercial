<template>
  <div class="settings-page">
    <div class="settings-header">
      <h1>Configurações do Portal</h1>
      <p>Gerencie todos os módulos do sistema: parâmetros operacionais, usuários, perfis de acesso, tipos de proposta e empresas parceiras.</p>
    </div>

    <div v-if="loading" class="spinner-container">
      <div class="spinner"></div>
    </div>

    <div v-else class="settings-content">
      
      <!-- ======================== -->
      <!-- PARÂMETROS OPERACIONAIS  -->
      <!-- ======================== -->
      <div class="section-label">
        <i class="material-icons">tune</i>
        <span>Parâmetros Operacionais</span>
      </div>

      <div class="card settings-card">
        <form @submit.prevent="saveGeneralSettings" class="form-container">
          <div class="setting-item">
            <div class="setting-desc">
              <h3>Taxa de Corretagem Global (%)</h3>
              <p>Porcentagem padrão de comissão sobre propostas fechadas com sucesso por empresas parceiras.</p>
            </div>
            <div class="form-group setting-input">
              <label class="form-label">Taxa (%)</label>
              <input
                type="number"
                v-model.number="generalSettings.taxa_corretagem"
                class="form-control"
                placeholder="5.0"
                step="0.1"
                min="0"
                max="100"
                required
              />
            </div>
          </div>

          <div class="divider"></div>

          <div class="setting-item">
            <div class="setting-desc">
              <h3>Senha do Supervisor</h3>
              <p>Senha para aprovação de ações críticas, como exclusão de clientes e aprovação direta de propostas.</p>
            </div>
            <div class="form-group setting-input">
              <label class="form-label">Nova Senha</label>
              <div class="input-with-icon">
                <i class="material-icons icon-prefix">lock</i>
                <input
                  type="password"
                  v-model="generalSettings.senha_supervisor"
                  class="form-control"
                  placeholder="Deixe em branco para não alterar"
                  minlength="4"
                />
              </div>
            </div>
          </div>

          <div class="form-actions">
            <button type="submit" class="btn btn-primary" :disabled="submitting">
              <span v-if="submitting" class="btn-spinner"></span>
              <i v-else class="material-icons">save</i>
              <span>Salvar Configurações</span>
            </button>
          </div>
        </form>
      </div>

      <!-- ======================== -->
      <!-- TIPOS DE PROPOSTA        -->
      <!-- ======================== -->
      <div class="section-label">
        <i class="material-icons">description</i>
        <span>Tipos de Proposta</span>
      </div>

      <div class="card settings-card">
        <div class="card-header-with-action">
          <div>
            <h2>Tipos de Proposta</h2>
            <p>Configure e crie tipos de proposta comercial e gerencie seus campos dinâmicos.</p>
          </div>
          <div style="display: flex; gap: 12px; align-items: center;">
            <FilterField
              v-model="typeSearch"
              type="search"
              placeholder="Buscar tipo..."
              style="width: 200px;"
            />
            <button class="btn btn-primary" @click="openTypeForm(null)">
              <i class="material-icons">add</i> Criar Novo Tipo
            </button>
          </div>
        </div>

        <div class="table-responsive">
          <table class="data-table crud-table">
            <thead>
              <tr>
                <th>Nome</th>
                <th>Chave (ID)</th>
                <th>Campos Customizados</th>
                <th class="actions-header" style="text-align: right;">Ações</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="t in filteredTypes" :key="t.id">
                <td>
                  <strong>{{ t.nome }}</strong>
                  <span class="system-badge" v-if="isSystemType(t.chave)">Sistema</span>
                </td>
                <td><code>{{ t.chave }}</code></td>
                <td>{{ getFieldNamesList(t) }}</td>
                <td class="actions-cell">
                  <div class="actions-wrapper">
                    <button class="btn-icon" @click="openTypeForm(t)" title="Editar">
                      <i class="material-icons">edit</i>
                    </button>
                    <button
                      class="btn-icon btn-icon-danger"
                      @click="deleteProposalType(t)"
                      :disabled="isSystemType(t.chave)"
                      title="Excluir"
                    >
                      <i class="material-icons">delete</i>
                    </button>
                  </div>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>

      <!-- ======================== -->
      <!-- EMPRESAS PARCEIRAS       -->
      <!-- ======================== -->
      <div class="section-label">
        <i class="material-icons">business</i>
        <span>Empresas Parceiras</span>
      </div>

      <div class="card settings-card">
        <div class="card-header-with-action">
          <div>
            <h2>Empresas Parceiras</h2>
            <p>Cadastre e gerencie as empresas parceiras que recebem o encaminhamento de propostas.</p>
          </div>
          <div style="display: flex; gap: 12px; align-items: center;">
            <FilterField
              v-model="companySearch"
              type="search"
              placeholder="Buscar empresa..."
              style="width: 200px;"
            />
            <button class="btn btn-primary" @click="openCompanyForm(null)">
              <i class="material-icons">add</i> Nova Empresa
            </button>
          </div>
        </div>

        <div class="table-responsive">
          <table class="data-table crud-table">
            <thead>
              <tr>
                <th>Nome</th>
                <th class="col-cnpj">CNPJ</th>
                <th class="col-email">E-mail</th>
                <th>Responsável</th>
                <th>Status</th>
                <th class="actions-header" style="text-align: right;">Ações</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="c in filteredCompanies" :key="c.id">
                <td><strong>{{ c.nome }}</strong></td>
                <td class="col-cnpj"><code>{{ formatarCNPJ(c.cnpj) }}</code></td>
                <td class="col-email">{{ c.email }}</td>
                <td>
                  <span v-if="c.responsavel_nome">
                    {{ c.responsavel_nome }}
                    <span v-if="c.responsavel_email" style="font-size: 0.8rem; color: var(--text-muted); display: block;">
                      {{ c.responsavel_email }}
                    </span>
                  </span>
                  <span v-else>—</span>
                </td>
                <td>
                  <span class="status-badge" :class="c.ativo ? 'active' : 'inactive'">
                    {{ c.ativo ? 'Ativa' : 'Inativa' }}
                  </span>
                </td>
                <td class="actions-cell">
                  <div class="actions-wrapper">
                    <button class="btn-icon" @click="openCompanyForm(c)" title="Editar">
                      <i class="material-icons">edit</i>
                    </button>
                    <button class="btn-icon btn-icon-danger" @click="deleteCompany(c)" title="Excluir">
                      <i class="material-icons">delete</i>
                    </button>
                  </div>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>

      <!-- ======================== -->
      <!-- PERFIS DE ACESSO         -->
      <!-- ======================== -->
      <div class="section-label">
        <i class="material-icons">security</i>
        <span>Perfis de Acesso</span>
      </div>

      <div class="card settings-card">
        <div class="card-header-with-action">
          <div>
            <h2>Perfis de Acesso</h2>
            <p>Crie e configure perfis de acesso com permissões granulares para cada módulo do sistema.</p>
          </div>
          <div style="display: flex; gap: 12px; align-items: center;">
            <FilterField
              v-model="profileSearch"
              type="search"
              placeholder="Buscar perfil..."
              style="width: 200px;"
            />
            <button class="btn btn-primary" @click="openProfileForm(null)">
              <i class="material-icons">add</i> Criar Novo Perfil
            </button>
          </div>
        </div>

        <div class="table-responsive">
          <table class="data-table crud-table">
            <thead>
              <tr>
                <th>Nome</th>
                <th>Descrição</th>
                <th>Permissões</th>
                <th class="actions-header" style="text-align: right;">Ações</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="p in filteredProfiles" :key="p.id">
                <td>
                  <strong>{{ p.nome }}</strong>
                  <span class="system-badge" v-if="p.is_sistema">Sistema</span>
                </td>
                <td>{{ p.descricao || '—' }}</td>
                <td>
                  <span class="perm-summary" :class="{ 'full-access': getPermissoesList(p).includes('Total') }">
                    {{ getPermissoesList(p) }}
                  </span>
                </td>
                <td class="actions-cell">
                  <div class="actions-wrapper">
                    <button class="btn-icon" @click="openProfileForm(p)" title="Editar">
                      <i class="material-icons">edit</i>
                    </button>
                    <button
                      class="btn-icon btn-icon-danger"
                      @click="deleteProfile(p)"
                      :disabled="p.is_sistema"
                      title="Excluir"
                    >
                      <i class="material-icons">delete</i>
                    </button>
                  </div>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>

      <!-- ======================== -->
      <!-- USUÁRIOS                 -->
      <!-- ======================== -->
      <div class="section-label">
        <i class="material-icons">group</i>
        <span>Usuários</span>
      </div>

      <div class="card settings-card">
        <div class="card-header-with-action">
          <div>
            <h2>Usuários</h2>
            <p>Gerencie os usuários do sistema e seus perfis de acesso.</p>
          </div>
          <div style="display: flex; gap: 12px; align-items: center;">
            <FilterField
              v-model="userSearch"
              type="search"
              placeholder="Buscar usuário..."
              style="width: 200px;"
            />
            <button class="btn btn-primary" @click="openUserForm(null)">
              <i class="material-icons">person_add</i> Novo Usuário
            </button>
          </div>
        </div>

        <div class="table-responsive">
          <table class="data-table crud-table">
            <thead>
              <tr>
                <th>Nome</th>
                <th class="col-email">E-mail</th>
                <th>Perfil</th>
                <th>Status</th>
                <th class="actions-header" style="text-align: right;">Ações</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="u in filteredUsers" :key="u.id">
                <td>
                  <div style="display: flex; align-items: center; gap: 10px;">
                    <div class="user-avatar-sm">{{ u.nome.charAt(0).toUpperCase() }}</div>
                    <strong>{{ u.nome }}</strong>
                  </div>
                </td>
                <td class="col-email">{{ u.email }}</td>
                <td>
                  <span class="perfil-chip" :class="{ 'super-admin': u.perfil?.nome === 'Super Admin' }">
                    {{ u.perfil?.nome || u.perfil_id }}
                  </span>
                </td>
                <td>
                  <span class="status-badge" :class="u.ativo ? 'active' : 'inactive'">
                    {{ u.ativo ? 'Ativo' : 'Inativo' }}
                  </span>
                </td>
                <td class="actions-cell">
                  <div class="actions-wrapper">
                    <button class="btn-icon" @click="openUserForm(u)" title="Editar">
                      <i class="material-icons">edit</i>
                    </button>
                    <button class="btn-icon btn-icon-danger" @click="deleteUser(u)" title="Excluir">
                      <i class="material-icons">delete</i>
                    </button>
                  </div>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>

    </div>

    <!-- Modals -->
    <ProposalTypeFormModal
      :show="showTypeModal"
      :proposalType="selectedProposalType"
      @close="showTypeModal = false"
      @save="onTypeSaved"
    />

    <CompanyFormModal
      :show="showCompanyModal"
      :company="selectedCompany"
      @close="showCompanyModal = false"
      @save="onCompanySaved"
    />

    <ProfileFormModal
      :show="showProfileModal"
      :profile="selectedProfile"
      @close="showProfileModal = false"
      @save="onProfileSaved"
    />

    <UserFormModal
      :show="showUserModal"
      :user="selectedUser"
      :profiles="profiles"
      @close="showUserModal = false"
      @save="onUserSaved"
    />
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { TipoProposta, Empresa, Perfil, Usuario, Settings, CampoTipoProposta } from '@/types'
import { api } from '@/services/api'
import FilterField from '@/components/FilterField.vue'
import ProposalTypeFormModal from '@/components/ProposalTypeFormModal.vue'
import CompanyFormModal from '@/components/CompanyFormModal.vue'
import ProfileFormModal from '@/components/ProfileFormModal.vue'
import UserFormModal from '@/components/UserFormModal.vue'
import { formatarCNPJ } from '@/utils/formatters'

const loading = ref(true)
const submitting = ref(false)

// Config objects
const generalSettings = ref<Settings>({
  taxa_corretagem: 5.0,
  senha_supervisor: ''
})

// Lists
const proposalTypes = ref<TipoProposta[]>([])
const companies = ref<Empresa[]>([])
const profiles = ref<Perfil[]>([])
const users = ref<Usuario[]>([])

// Search state for each table
const typeSearch = ref('')
const companySearch = ref('')
const profileSearch = ref('')
const userSearch = ref('')

// Filtered computed lists
const filteredTypes = computed(() => {
  const q = typeSearch.value.toLowerCase().trim()
  if (!q) return proposalTypes.value
  return proposalTypes.value.filter(t =>
    t.nome.toLowerCase().includes(q) ||
    t.chave.toLowerCase().includes(q)
  )
})

const filteredCompanies = computed(() => {
  const q = companySearch.value.toLowerCase().trim()
  if (!q) return companies.value
  return companies.value.filter(c =>
    c.nome.toLowerCase().includes(q) ||
    c.cnpj.toLowerCase().includes(q) ||
    c.email.toLowerCase().includes(q)
  )
})

const filteredProfiles = computed(() => {
  const q = profileSearch.value.toLowerCase().trim()
  if (!q) return profiles.value
  return profiles.value.filter(p =>
    p.nome.toLowerCase().includes(q) ||
    (p.descricao || '').toLowerCase().includes(q)
  )
})

const filteredUsers = computed(() => {
  const q = userSearch.value.toLowerCase().trim()
  if (!q) return users.value
  return users.value.filter(u =>
    u.nome.toLowerCase().includes(q) ||
    u.email.toLowerCase().includes(q)
  )
})

// Modal states
const showTypeModal = ref(false)
const selectedProposalType = ref<TipoProposta | null>(null)

const showCompanyModal = ref(false)
const selectedCompany = ref<Empresa | null>(null)

const showProfileModal = ref(false)
const selectedProfile = ref<Perfil | null>(null)

const showUserModal = ref(false)
const selectedUser = ref<Usuario | null>(null)

onMounted(async () => {
  loading.value = true
  await Promise.all([
    loadSettings(),
    loadProposalTypes(),
    loadCompanies(),
    loadProfiles(),
    loadUsers()
  ])
  loading.value = false
})

async function loadSettings() {
  try {
    const res = await api.get<Settings>('/api/settings')
    generalSettings.value = {
      taxa_corretagem: res.taxa_corretagem,
      senha_supervisor: ''
    }
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

async function loadCompanies() {
  try {
    companies.value = await api.get<Empresa[]>('/api/companies')
  } catch (err) {
    console.error(err)
  }
}

async function loadProfiles() {
  try {
    profiles.value = await api.get<Perfil[]>('/api/profiles')
  } catch (err) {
    console.error(err)
  }
}

async function loadUsers() {
  try {
    users.value = await api.get<Usuario[]>('/api/users')
  } catch (err) {
    console.error(err)
  }
}

// GENERAL SETTINGS SAVE
async function saveGeneralSettings() {
  submitting.value = true
  try {
    const payload: Settings = {
      taxa_corretagem: Number(generalSettings.value.taxa_corretagem)
    }
    if (generalSettings.value.senha_supervisor?.trim()) {
      payload.senha_supervisor = generalSettings.value.senha_supervisor
    }
    await api.put('/api/settings', payload)
    alert('Configurações salvas!')
    generalSettings.value.senha_supervisor = ''
  } catch (err) {
    alert('Erro ao salvar configurações.')
  } finally {
    submitting.value = false
  }
}

// PROPOSAL TYPE CRUD
function isSystemType(key: string): boolean {
  return key === 'Imobiliaria' || key === 'Auto' || key === 'Comissionados'
}

function openTypeForm(tipo: TipoProposta | null) {
  selectedProposalType.value = tipo
  showTypeModal.value = true
}

async function onTypeSaved(payload: TipoProposta) {
  showTypeModal.value = false
  try {
    if (payload.id) {
      await api.put(`/api/proposal-types/${payload.id}`, payload)
    } else {
      await api.post('/api/proposal-types', payload)
    }
    loadProposalTypes()
  } catch (err: any) {
    alert(err.error || 'Erro ao salvar tipo de proposta.')
  }
}

async function deleteProposalType(tipo: TipoProposta) {
  if (isSystemType(tipo.chave)) return
  if (confirm(`Deseja realmente excluir o tipo de proposta "${tipo.nome}"?`)) {
    try {
      await api.delete(`/api/proposal-types/${tipo.id}`)
      loadProposalTypes()
    } catch (err: any) {
      alert(err.error || 'Erro ao excluir tipo de proposta.')
    }
  }
}

function getFieldNamesList(tipo: TipoProposta): string {
  if (!tipo.campos) return 'Nenhum campo'
  let fieldsList: CampoTipoProposta[] = []
  if (typeof tipo.campos === 'string') {
    try {
      fieldsList = JSON.parse(tipo.campos)
    } catch {
      return 'Erro ao ler campos'
    }
  } else {
    fieldsList = tipo.campos as CampoTipoProposta[]
  }
  if (fieldsList.length === 0) return 'Nenhum campo'
  return fieldsList.map(c => `${c.nome}${c.obrigatorio ? '*' : ''}`).join(', ')
}

// COMPANY CRUD
function openCompanyForm(company: Empresa | null) {
  selectedCompany.value = company
  showCompanyModal.value = true
}

function onCompanySaved() {
  showCompanyModal.value = false
  loadCompanies()
}

async function deleteCompany(company: Empresa) {
  if (!company.id) return
  if (confirm(`Deseja realmente excluir a empresa parceira "${company.nome}"?`)) {
    try {
      await api.delete(`/api/companies/${company.id}`)
      loadCompanies()
    } catch (err: any) {
      alert(err.error || 'Erro ao excluir empresa.')
    }
  }
}

// PROFILE CRUD
function openProfileForm(profile: Perfil | null) {
  selectedProfile.value = profile
  showProfileModal.value = true
}

async function onProfileSaved(payload: Perfil) {
  showProfileModal.value = false
  try {
    if (payload.id) {
      await api.put(`/api/profiles/${payload.id}`, payload)
    } else {
      await api.post('/api/profiles', payload)
    }
    loadProfiles()
  } catch (err: any) {
    alert(err.error || 'Erro ao salvar perfil.')
  }
}

async function deleteProfile(profile: Perfil) {
  if (profile.is_sistema) return
  if (confirm(`Deseja realmente excluir o perfil "${profile.nome}"?`)) {
    try {
      await api.delete(`/api/profiles/${profile.id}`)
      loadProfiles()
    } catch (err: any) {
      alert(err.error || 'Erro ao excluir perfil.')
    }
  }
}

function getPermissoesList(perfil: Perfil): string {
  let perms: string[] = []
  const rawPerms = perfil.permissoes
  if (rawPerms) {
    if (typeof rawPerms === 'string') {
      try {
        perms = JSON.parse(rawPerms)
      } catch {
        return '—'
      }
    } else {
      perms = rawPerms as string[]
    }
  }
  if (perms.includes('*')) return 'Acesso Total (★)'
  if (perms.length === 0) return 'Nenhuma permissão'
  return `${perms.length} permissão(ões)`
}

// USER CRUD
function openUserForm(user: Usuario | null) {
  selectedUser.value = user
  showUserModal.value = true
}

async function onUserSaved(payload: any) {
  showUserModal.value = false
  try {
    if (payload.id) {
      await api.put(`/api/users/${payload.id}`, payload)
    } else {
      await api.post('/api/users', payload)
    }
    loadUsers()
  } catch (err: any) {
    alert(err.error || 'Erro ao salvar usuário.')
  }
}

async function deleteUser(user: Usuario) {
  if (!user.id) return
  if (confirm(`Deseja realmente excluir o usuário "${user.nome}"?`)) {
    try {
      await api.delete(`/api/users/${user.id}`)
      loadUsers()
    } catch (err: any) {
      alert(err.error || 'Erro ao excluir usuário.')
    }
  }
}
</script>

<style scoped>
@import "./css/SettingsView.css";
</style>

<template>
  <!-- Renders Login directly when logged out -->
  <template v-if="!auth.isLoggedIn.value">
    <RouterView />
  </template>

  <!-- Full App Shell Layout when logged in -->
  <template v-else>
    <div class="layout-container">
      <!-- Sidebar Backdrop for mobile -->
      <div
        v-if="isHandset && isSidebarOpen"
        class="sidebar-backdrop"
        @click="isSidebarOpen = false"
      ></div>

      <!-- Sidenav -->
      <aside class="sidebar" :class="{ open: isSidebarOpen }">
        <div class="sidebar-header">
          <i class="material-icons">business_center</i>
          <span class="sidebar-title">Portal Propostas</span>
        </div>

        <div class="sidebar-user-card">
          <div class="user-avatar">{{ auth.userInitials.value }}</div>
          <div class="user-info">
            <span class="user-name">{{ auth.currentUser.value?.nome }}</span>
            <span class="user-role">{{ auth.currentUser.value?.perfil?.nome }}</span>
          </div>
        </div>

        <hr class="sidebar-divider" />

        <ul class="sidebar-menu">
          <li class="sidebar-item">
            <RouterLink to="/dashboard" class="sidebar-link" @click="closeSidebarOnMobile">
              <i class="material-icons">dashboard</i>
              <span>Dashboard</span>
            </RouterLink>
          </li>
          <li class="sidebar-item">
            <RouterLink to="/clientes" class="sidebar-link" @click="closeSidebarOnMobile">
              <i class="material-icons">people</i>
              <span>Clientes</span>
            </RouterLink>
          </li>
          <li class="sidebar-item">
            <RouterLink to="/propostas" class="sidebar-link" @click="closeSidebarOnMobile">
              <i class="material-icons">assignment</i>
              <span>Propostas</span>
            </RouterLink>
          </li>
          <li class="sidebar-item">
            <RouterLink to="/empresas" class="sidebar-link" @click="closeSidebarOnMobile">
              <i class="material-icons">business</i>
              <span>Empresas Parceiras</span>
            </RouterLink>
          </li>
          <li v-if="auth.canSeeSupervisor.value" class="sidebar-item">
            <RouterLink to="/supervisor" class="sidebar-link" @click="closeSidebarOnMobile">
              <i class="material-icons">security</i>
              <span>Painel Supervisor</span>
            </RouterLink>
          </li>

          <template v-if="auth.canSeeSettings.value">
            <hr class="sidebar-divider" style="margin: 8px 12px;" />
            <li class="sidebar-item">
              <RouterLink to="/configuracoes" class="sidebar-link" @click="closeSidebarOnMobile">
                <i class="material-icons">settings</i>
                <span>Configurações</span>
              </RouterLink>
            </li>
          </template>
        </ul>

        <div class="sidebar-footer">
          <button class="logout-btn" @click="logout">
            <i class="material-icons">logout</i>
            <span>Sair do Sistema</span>
          </button>
        </div>
      </aside>

      <!-- Main Viewport -->
      <main class="main-viewport">
        <!-- Toolbar Header -->
        <header class="toolbar">
          <button class="menu-toggle" @click="isSidebarOpen = !isSidebarOpen">
            <i class="material-icons">menu</i>
          </button>

          <span class="toolbar-title">
            {{ isHandset ? 'Portal Propostas' : 'Sistema de Cadastro & Propostas Comerciais' }}
          </span>

          <span class="toolbar-spacer"></span>

          <!-- Quick Actions Menu -->
          <div class="quick-add-container" ref="quickAddRef">
            <button class="quick-add-btn" @click.stop="quickAddOpen = !quickAddOpen">
              <i class="material-icons">add</i>
              <span v-if="!isHandset">Novo</span>
            </button>
            <div v-if="quickAddOpen" class="quick-add-menu">
              <button class="quick-add-item" @click="triggerNewClient">
                <i class="material-icons" style="color: var(--primary);">person_add</i>
                <span>Novo Cliente</span>
              </button>
              <button class="quick-add-item" @click="triggerNewProposal">
                <i class="material-icons" style="color: var(--warning);">assignment</i>
                <span>Nova Proposta</span>
              </button>
              <button v-if="auth.canSeeSettings.value" class="quick-add-item" @click="triggerNewCompany">
                <i class="material-icons" style="color: #9c27b0;">business</i>
                <span>Nova Empresa Parceira</span>
              </button>
            </div>
          </div>

          <!-- User Menu Dropdown -->
          <div class="user-menu-container" ref="userMenuRef">
            <button class="toolbar-user-menu" @click.stop="userMenuOpen = !userMenuOpen" id="user-menu-trigger">
              <div class="toolbar-avatar">{{ auth.userInitials.value }}</div>
              <span class="toolbar-username" v-if="!isHandset">{{ auth.currentUser.value?.nome }}</span>
              <i class="material-icons">arrow_drop_down</i>
            </button>
            <div v-if="userMenuOpen" class="user-dropdown-menu">
              <div class="dropdown-user-header">
                <strong>{{ auth.currentUser.value?.nome }}</strong>
                <span>{{ auth.currentUser.value?.email }}</span>
                <span class="dropdown-role-tag">{{ auth.currentUser.value?.perfil?.nome }}</span>
              </div>
              <button v-if="auth.canSeeSettings.value" class="dropdown-item" @click="goToSettings">
                <i class="material-icons">settings</i>
                <span>Configurações</span>
              </button>
              <div class="dropdown-divider"></div>
              <button class="dropdown-item" @click="logout" id="logout-btn">
                <i class="material-icons" style="color: var(--danger);">logout</i>
                <span style="color: var(--danger);">Sair do Sistema</span>
              </button>
            </div>
          </div>
        </header>

        <!-- Page Viewport Content -->
        <div class="content-wrapper">
          <RouterView />
        </div>

        <!-- PWA Bottom Navigation Bar for Mobile -->
        <nav class="bottom-nav">
          <RouterLink to="/dashboard" class="bottom-nav-link">
            <i class="material-icons">dashboard</i>
            <span>Dashboard</span>
          </RouterLink>
          <RouterLink to="/clientes" class="bottom-nav-link">
            <i class="material-icons">people</i>
            <span>Clientes</span>
          </RouterLink>
          <RouterLink to="/propostas" class="bottom-nav-link">
            <i class="material-icons">assignment</i>
            <span>Propostas</span>
          </RouterLink>
          <RouterLink to="/empresas" class="bottom-nav-link">
            <i class="material-icons">business</i>
            <span>Empresas</span>
          </RouterLink>
          <RouterLink v-if="auth.canSeeSettings.value" to="/configuracoes" class="bottom-nav-link">
            <i class="material-icons">settings</i>
            <span>Config.</span>
          </RouterLink>
        </nav>
      </main>
    </div>

    <!-- Global Modals for Quick Actions -->
    <ClientFormModal
      :show="showClientModal"
      @close="showClientModal = false"
      @save="onClientSaved"
    />

    <ProposalFormModal
      :show="showProposalModal"
      @close="showProposalModal = false"
      @save="onProposalSaved"
    />

    <CompanyFormModal
      :show="showCompanyModal"
      @close="showCompanyModal = false"
      @save="onCompanySaved"
    />
  </template>
</template>

<script setup lang="ts">
import { ref, onMounted, onUnmounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { useAuth } from '@/composables/useAuth'
import ClientFormModal from '@/components/ClientFormModal.vue'
import ProposalFormModal from '@/components/ProposalFormModal.vue'
import CompanyFormModal from '@/components/CompanyFormModal.vue'

const router = useRouter()
const route = useRoute()
const auth = useAuth()

// Responsive Layout Handset observer
const isHandset = ref(false)
const isSidebarOpen = ref(false)

let mediaQueryList: MediaQueryList | null = null

function updateHandsetMatch(e: MediaQueryListEvent | MediaQueryList) {
  isHandset.value = e.matches
  if (!e.matches) {
    isSidebarOpen.value = false
  }
}

onMounted(() => {
  mediaQueryList = window.matchMedia('(max-width: 959px)')
  updateHandsetMatch(mediaQueryList)
  mediaQueryList.addEventListener('change', updateHandsetMatch)
  window.addEventListener('click', closeMenus)
})

onUnmounted(() => {
  if (mediaQueryList) {
    mediaQueryList.removeEventListener('change', updateHandsetMatch)
  }
  window.removeEventListener('click', closeMenus)
})

function closeSidebarOnMobile() {
  if (isHandset.value) {
    isSidebarOpen.value = false
  }
}

// Quick Add Dropdown Menu state
const quickAddOpen = ref(false)
const userMenuOpen = ref(false)

const quickAddRef = ref<HTMLElement | null>(null)
const userMenuRef = ref<HTMLElement | null>(null)

function closeMenus(e: MouseEvent) {
  if (quickAddRef.value && !quickAddRef.value.contains(e.target as Node)) {
    quickAddOpen.value = false
  }
  if (userMenuRef.value && !userMenuRef.value.contains(e.target as Node)) {
    userMenuOpen.value = false
  }
}

// Modals Trigger State
const showClientModal = ref(false)
const showProposalModal = ref(false)
const showCompanyModal = ref(false)

function triggerNewClient() {
  quickAddOpen.value = false
  showClientModal.value = true
}

function triggerNewProposal() {
  quickAddOpen.value = false
  showProposalModal.value = true
}

function triggerNewCompany() {
  quickAddOpen.value = false
  showCompanyModal.value = true
}

function onClientSaved() {
  showClientModal.value = false
  if (route.path.startsWith('/clientes')) {
    window.location.reload()
  } else {
    router.push('/clientes')
  }
}

function onProposalSaved() {
  showProposalModal.value = false
  if (route.path.startsWith('/propostas')) {
    window.location.reload()
  } else {
    router.push('/propostas')
  }
}

function onCompanySaved() {
  showCompanyModal.value = false
  if (route.path.startsWith('/configuracoes') || route.path.startsWith('/empresas')) {
    window.location.reload()
  } else {
    router.push('/empresas')
  }
}

function goToSettings() {
  userMenuOpen.value = false
  router.push('/configuracoes')
}

function logout() {
  userMenuOpen.value = false
  auth.logout()
}
</script>

<style scoped>
@import "./css/App.css";
</style>

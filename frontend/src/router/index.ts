import { createRouter, createWebHistory } from 'vue-router'
import { useAuth } from '@/composables/useAuth'

// Lazy loaded views
const LoginView = () => import('@/views/LoginView.vue')
const DashboardView = () => import('@/views/DashboardView.vue')
const ClientsView = () => import('@/views/ClientsView.vue')
const ProposalsView = () => import('@/views/ProposalsView.vue')
const CompaniesView = () => import('@/views/CompaniesView.vue')
const SupervisorView = () => import('@/views/SupervisorView.vue')
const SettingsView = () => import('@/views/SettingsView.vue')

const routes = [
  {
    path: '/login',
    name: 'login',
    component: LoginView,
    meta: { public: true }
  },
  {
    path: '/',
    redirect: '/dashboard'
  },
  {
    path: '/dashboard',
    name: 'dashboard',
    component: DashboardView
  },
  {
    path: '/clientes',
    name: 'clients',
    component: ClientsView
  },
  {
    path: '/propostas',
    name: 'proposals',
    component: ProposalsView
  },
  {
    path: '/empresas',
    name: 'companies',
    component: CompaniesView
  },
  {
    path: '/supervisor',
    name: 'supervisor',
    component: SupervisorView,
    meta: { permission: 'supervisor.access' }
  },
  {
    path: '/configuracoes',
    name: 'settings',
    component: SettingsView,
    meta: { permission: 'settings.read' }
  },
  {
    path: '/:pathMatch(.*)*',
    redirect: '/dashboard'
  }
]

export const router = createRouter({
  history: createWebHistory(),
  routes
})

router.beforeEach((to, _from, next) => {
  const auth = useAuth()
  
  if (!to.meta.public && !auth.isLoggedIn.value) {
    return next({ name: 'login' })
  }
  
  if (to.meta.public && auth.isLoggedIn.value) {
    return next({ name: 'dashboard' })
  }
  
  if (to.meta.permission) {
    const requiredPermission = to.meta.permission as string
    if (!auth.hasPermission(requiredPermission)) {
      return next({ name: 'dashboard' })
    }
  }
  
  next()
})

export default router

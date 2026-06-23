import { ref, computed } from 'vue'
import { useRouter } from 'vue-router'
import { Usuario, LoginRequest } from '@/types'
import { api } from '@/services/api'

const STORAGE_KEY = 'portal_user'

// Declared outside of useAuth to act as a global singleton state
const currentUser = ref<Usuario | null>(loadFromStorage())

function loadFromStorage(): Usuario | null {
  try {
    const raw = localStorage.getItem(STORAGE_KEY)
    return raw ? JSON.parse(raw) : null
  } catch {
    return null
  }
}

export function useAuth() {
  const router = useRouter()

  const isLoggedIn = computed(() => !!currentUser.value)

  const isSuperAdmin = computed(() => currentUser.value?.perfil?.nome === 'Super Admin')

  const userInitials = computed(() => {
    const name = currentUser.value?.nome || ''
    return name
      .split(' ')
      .slice(0, 2)
      .map(w => w[0]?.toUpperCase() || '')
      .join('')
  })

  const permissoes = computed((): string[] => {
    const user = currentUser.value
    if (!user?.perfil?.permissoes) return []
    let perms = user.perfil.permissoes
    if (typeof perms === 'string') {
      try {
        perms = JSON.parse(perms)
      } catch {
        return []
      }
    }
    return perms as string[]
  })

  function hasPermission(permission: string): boolean {
    if (isSuperAdmin.value) return true
    const perms = permissoes.value
    return perms.includes('*') || perms.includes(permission)
  }

  const canSeeSettings = computed(() => {
    return isSuperAdmin.value || hasPermission('settings.read')
  })

  const canSeeSupervisor = computed(() => {
    return isSuperAdmin.value || hasPermission('supervisor.access')
  })

  async function login(req: LoginRequest): Promise<Usuario> {
    const user = await api.post<Usuario>('/api/auth/login', req)
    currentUser.value = user
    localStorage.setItem(STORAGE_KEY, JSON.stringify(user))
    return user
  }

  function logout() {
    currentUser.value = null
    localStorage.removeItem(STORAGE_KEY)
    if (router) {
      router.push('/login')
    } else {
      window.location.href = '/login'
    }
  }

  return {
    currentUser,
    isLoggedIn,
    isSuperAdmin,
    userInitials,
    permissoes,
    hasPermission,
    canSeeSettings,
    canSeeSupervisor,
    login,
    logout
  }
}
export default useAuth;

<template>
  <div class="login-page">
    <!-- Left panel: branding -->
    <div class="brand-panel">
      <div class="brand-content">
        <div class="brand-logo">
          <i class="material-icons">business_center</i>
        </div>
        <h1>Portal de Propostas Comerciais</h1>
        <p>Gerencie clientes, propostas, comissões e equipes com total controle e segurança.</p>

        <div class="brand-features">
          <div class="feature-item">
            <i class="material-icons">check_circle</i>
            <span>Gestão completa de clientes e propostas</span>
          </div>
          <div class="feature-item">
            <i class="material-icons">check_circle</i>
            <span>Controle de comissões e empresas parceiras</span>
          </div>
          <div class="feature-item">
            <i class="material-icons">check_circle</i>
            <span>Perfis de acesso personalizáveis</span>
          </div>
          <div class="feature-item">
            <i class="material-icons">check_circle</i>
            <span>Dashboard analítico em tempo real</span>
          </div>
        </div>
      </div>

      <div class="brand-blobs">
        <div class="blob blob-1"></div>
        <div class="blob blob-2"></div>
        <div class="blob blob-3"></div>
      </div>
    </div>

    <!-- Right panel: login form -->
    <div class="form-panel">
      <div class="form-wrapper">
        <div class="form-header">
          <div class="form-icon">
            <i class="material-icons">lock</i>
          </div>
          <h2>Bem-vindo de volta</h2>
          <p>Acesse o sistema com suas credenciais</p>
        </div>

        <form @submit.prevent="handleLogin" class="login-form">
          <div class="form-group">
            <label class="form-label">E-mail</label>
            <div class="input-with-icon">
              <i class="material-icons icon-prefix">alternate_email</i>
              <input
                type="email"
                v-model="email"
                class="form-control"
                placeholder="seu@email.com"
                required
                autocomplete="email"
              />
            </div>
          </div>

          <div class="form-group">
            <label class="form-label">Senha</label>
            <div class="input-with-icon">
              <i class="material-icons icon-prefix">lock_outline</i>
              <input
                :type="showPassword ? 'text' : 'password'"
                v-model="senha"
                class="form-control"
                placeholder="••••••••"
                required
                autocomplete="current-password"
              />
              <button type="button" class="suffix-btn" @click="showPassword = !showPassword">
                <i class="material-icons">{{ showPassword ? 'visibility_off' : 'visibility' }}</i>
              </button>
            </div>
          </div>

          <span v-if="authError" class="error-text" style="margin-bottom: 12px; display: block; font-weight: 600;">
            {{ authError }}
          </span>

          <button type="submit" class="btn btn-primary submit-btn" :disabled="loading || !isFormValid">
            <span v-if="loading" class="btn-spinner"></span>
            <i v-if="!loading" class="material-icons">login</i>
            <span>{{ loading ? 'Entrando...' : 'Entrar no Sistema' }}</span>
          </button>
        </form>

        <div class="login-hint">
          <i class="material-icons">info_outline</i>
          <span>Credencial padrão: <code>admin@sistema.com</code> / <code>admin123</code></span>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import { useRouter } from 'vue-router'
import { useAuth } from '@/composables/useAuth'

const router = useRouter()
const auth = useAuth()

const email = ref('')
const senha = ref('')
const loading = ref(false)
const showPassword = ref(false)

const authError = ref('')

const isFormValid = computed(() => {
  return email.value && /\S+@\S+\.\S+/.test(email.value) && senha.value.length >= 1
})

async function handleLogin() {
  if (!isFormValid.value) return
  
  loading.value = true
  authError.value = ''
  
  try {
    await auth.login({
      email: email.value,
      senha: senha.value
    })
    router.push('/dashboard')
  } catch (err: any) {
    authError.value = err.error || 'Email ou senha inválidos.'
  } finally {
    loading.value = false
  }
}
</script>

<style scoped>
@import "./css/LoginView.css";
</style>

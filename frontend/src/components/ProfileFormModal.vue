<template>
  <Modal :show="show" :title="isEditMode ? 'Editar Perfil de Acesso' : 'Novo Perfil de Acesso'" icon="security" width="680px" @close="$emit('close')">
    <form @submit.prevent="onSubmit" class="form-container">
      <div class="form-group">
        <label class="form-label">Nome do Perfil</label>
        <input
          type="text"
          v-model="form.nome"
          class="form-control"
          placeholder="Ex: Supervisor Geral"
          :disabled="profile?.is_sistema"
          required
        />
      </div>

      <div class="form-group">
        <label class="form-label">Descrição</label>
        <input
          type="text"
          v-model="form.descricao"
          class="form-control"
          placeholder="Descreva o propósito do perfil..."
        />
      </div>

      <div class="divider"></div>

      <div class="permissions-section">
        <h3>Permissões do Perfil</h3>
        <p v-if="isSuperAdmin" class="superadmin-note">
          Super Admin possui permissões globais irrestritas (★).
        </p>
        <div v-else class="permissions-grid">
          <label v-for="p in ALL_PERMISSIONS" :key="p.key" class="perm-checkbox-container">
            <input
              type="checkbox"
              :value="p.key"
              v-model="selectedPermissions"
            />
            <span class="perm-label">{{ p.label }}</span>
          </label>
        </div>
      </div>
    </form>

    <template #actions>
      <button type="button" class="btn btn-secondary" @click="$emit('close')">
        Cancelar
      </button>
      <button
        type="button"
        class="btn btn-primary"
        :disabled="!form.nome"
        @click="onSubmit"
      >
        <span>{{ isEditMode ? 'Salvar' : 'Criar' }}</span>
      </button>
    </template>
  </Modal>
</template>

<script setup lang="ts">
import { ref, computed, watch } from 'vue'
import { Perfil } from '@/types'
import Modal from './Modal.vue'

const ALL_PERMISSIONS = [
  { key: 'clients.read',     label: 'Clientes — Visualizar' },
  { key: 'clients.write',    label: 'Clientes — Criar / Editar / Excluir' },
  { key: 'proposals.read',   label: 'Propostas — Visualizar' },
  { key: 'proposals.write',  label: 'Propostas — Criar / Editar / Excluir' },
  { key: 'companies.read',   label: 'Empresas Parceiras — Visualizar' },
  { key: 'companies.write',  label: 'Empresas Parceiras — Criar / Editar / Excluir' },
  { key: 'dashboard.read',   label: 'Dashboard — Visualizar' },
  { key: 'settings.read',    label: 'Configurações — Visualizar' },
  { key: 'settings.write',   label: 'Configurações — Editar' },
  { key: 'users.read',       label: 'Usuários — Visualizar' },
  { key: 'users.write',      label: 'Usuários — Criar / Editar / Excluir' },
  { key: 'supervisor.access',label: 'Painel Supervisor' },
]

const props = defineProps({
  show: {
    type: Boolean,
    required: true
  },
  profile: {
    type: Object as () => Perfil | null,
    default: null
  }
})

const emit = defineEmits(['close', 'save'])

const isEditMode = computed(() => !!props.profile?.id)
const isSuperAdmin = computed(() => props.profile?.nome === 'Super Admin')

const form = ref({
  nome: '',
  descricao: ''
})

const selectedPermissions = ref<string[]>([])

watch(
  () => props.show,
  (newShow) => {
    if (newShow) {
      if (props.profile) {
        form.value = {
          nome: props.profile.nome,
          descricao: props.profile.descricao || ''
        }
        let perms: string[] = []
        const rawPerms = props.profile.permissoes
        if (rawPerms) {
          if (typeof rawPerms === 'string') {
            try {
              perms = JSON.parse(rawPerms)
            } catch {
              perms = []
            }
          } else {
            perms = rawPerms as string[]
          }
        }
        selectedPermissions.value = perms
      } else {
        form.value = {
          nome: '',
          descricao: ''
        }
        selectedPermissions.value = []
      }
    }
  },
  { immediate: true }
)

function onSubmit() {
  if (!form.value.nome) return
  
  const payload: Perfil = {
    nome: form.value.nome,
    descricao: form.value.descricao,
    permissoes: isSuperAdmin.value ? ['*'] : selectedPermissions.value
  }
  
  if (props.profile?.id) {
    payload.id = props.profile.id
  }
  
  emit('save', payload)
}
</script>

<style scoped>
@import "./css/ProfileFormModal.css";
</style>

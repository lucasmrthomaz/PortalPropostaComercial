<template>
  <Modal :show="show" title="Detalhes da Proposta" icon="assignment" width="650px" @close="$emit('close')">
    <div class="proposal-details-container" v-if="proposal">
      
      <!-- Primary Info Grid -->
      <div class="details-grid">
        <div class="detail-card">
          <span class="label">Cliente</span>
          <span class="value">{{ clientName }}</span>
        </div>

        <div class="detail-card">
          <span class="label">Tipo de Proposta</span>
          <span class="value">{{ getTypeLabel(proposal.tipo) }}</span>
        </div>

        <div class="detail-card">
          <span class="label">Valor</span>
          <span class="value valor">{{ formatCurrency(proposal.valor) }}</span>
        </div>

        <div class="detail-card">
          <span class="label">Status</span>
          <div class="status-badge-wrapper">
            <span class="status-tag" :class="proposal.status.toLowerCase().replace(' ', '-')">
              {{ getStatusLabel(proposal.status) }}
            </span>
          </div>
        </div>

        <div class="detail-card" v-if="proposal.created_at">
          <span class="label">Data de Cadastro</span>
          <span class="value">{{ formatDate(proposal.created_at) }}</span>
        </div>

        <div class="detail-card full-width" v-if="proposal.descricao">
          <span class="label">Descrição / Observações</span>
          <span class="value block">{{ proposal.descricao }}</span>
        </div>
      </div>

      <div class="divider"></div>

      <!-- Specific Dynamic Info Grid -->
      <div class="specific-details-section">
        <h3>Dados Específicos</h3>

        <!-- Imobiliaria Details -->
        <div v-if="proposal.tipo === 'Imobiliaria'" class="details-grid">
          <div class="detail-card full-width">
            <span class="label">Endereço do Imóvel</span>
            <span class="value">{{ dados.endereco_imovel }}</span>
          </div>
          <div class="detail-card">
            <span class="label">Tipo do Imóvel</span>
            <span class="value">{{ dados.tipo_imovel }}</span>
          </div>
          <div class="detail-card">
            <span class="label">Área Privativa</span>
            <span class="value">{{ formatarArea(dados.area_m2) }} m²</span>
          </div>
          
          <!-- Photo Row -->
          <div class="detail-card full-width" v-if="dados.foto">
            <span class="label">Foto do Imóvel</span>
            <div class="media-card">
              <div class="media-preview-wrapper">
                <img :src="dados.foto" alt="Foto do Imóvel" class="detail-photo" />
              </div>
              <div class="media-actions">
                <a :href="dados.foto" download="foto_imovel.png" class="btn btn-secondary btn-sm">
                  <i class="material-icons">download</i> Baixar Imagem
                </a>
              </div>
            </div>
          </div>
        </div>

        <!-- Auto Details -->
        <div v-else-if="proposal.tipo === 'Auto'" class="details-grid">
          <div class="detail-card">
            <span class="label">Veículo</span>
            <span class="value">{{ dados.marca }} {{ dados.modelo }}</span>
          </div>
          <div class="detail-card">
            <span class="label">Ano de Fabricação</span>
            <span class="value">{{ dados.ano }}</span>
          </div>
          <div class="detail-card">
            <span class="label">Placa</span>
            <span class="value uppercase">{{ dados.placa }}</span>
          </div>
          
          <!-- Photo Row -->
          <div class="detail-card full-width" v-if="dados.foto">
            <span class="label">Foto do Veículo</span>
            <div class="media-card">
              <div class="media-preview-wrapper">
                <img :src="dados.foto" alt="Foto do Veículo" class="detail-photo" />
              </div>
              <div class="media-actions">
                <a :href="dados.foto" download="foto_veiculo.png" class="btn btn-secondary btn-sm">
                  <i class="material-icons">download</i> Baixar Imagem
                </a>
              </div>
            </div>
          </div>
        </div>

        <!-- Comissionados Details -->
        <div v-else-if="proposal.tipo === 'Comissionados'" class="details-grid">
          <div class="detail-card full-width">
            <span class="label">Itens / Serviços</span>
            <span class="value block">{{ dados.itens }}</span>
          </div>
          <div class="detail-card full-width">
            <span class="label">Condições de Pagamento</span>
            <span class="value">{{ dados.condicoes_pagamento }}</span>
          </div>
          
          <!-- Photo Row -->
          <div class="detail-card full-width" v-if="dados.foto">
            <span class="label">Foto do Item</span>
            <div class="media-card">
              <div class="media-preview-wrapper">
                <img :src="dados.foto" alt="Foto do Item" class="detail-photo" />
              </div>
              <div class="media-actions">
                <a :href="dados.foto" download="foto_item.png" class="btn btn-secondary btn-sm">
                  <i class="material-icons">download</i> Baixar Imagem
                </a>
              </div>
            </div>
          </div>

          <!-- Attachment Row -->
          <div class="detail-card full-width" v-if="dados.anexo">
            <span class="label">Documento Anexo</span>
            <div class="detail-doc-card">
              <i class="material-icons doc-icon" style="color: var(--primary);">insert_drive_file</i>
              <div class="doc-details">
                <span class="doc-title">{{ dados.nome_anexo || 'Documento Anexo' }}</span>
              </div>
              <a :href="dados.anexo" :download="dados.nome_anexo || 'documento'" class="btn-icon">
                <i class="material-icons">download</i>
              </a>
            </div>
          </div>
        </div>

        <!-- Dynamic/Custom Details -->
        <div v-else class="details-grid">
          <div class="detail-card" v-for="entry in getCustomFields()" :key="entry.label" :class="{ 'full-width': entry.value && entry.value.length > 50 }">
            <span class="label">{{ entry.label }}</span>
            <span class="value">{{ entry.value }}</span>
          </div>
        </div>
      </div>

    </div>

    <template #actions>
      <button type="button" class="btn btn-primary" @click="$emit('close')">
        Fechar
      </button>
    </template>
  </Modal>
</template>

<script setup lang="ts">
import { ref, computed, watch } from 'vue'
import { Proposta, TipoProposta, CampoTipoProposta } from '@/types'
import { api } from '@/services/api'
import Modal from './Modal.vue'
import { formatarArea } from '@/utils/formatters'

const props = defineProps({
  show: {
    type: Boolean,
    required: true
  },
  proposal: {
    type: Object as () => Proposta | null,
    default: null
  },
  clientName: {
    type: String,
    default: ''
  }
})

defineEmits(['close'])

const proposalTypes = ref<TipoProposta[]>([])

const dados = computed(() => {
  if (!props.proposal?.dados_especificos) return {}
  let spec = props.proposal.dados_especificos
  if (typeof spec === 'string') {
    try {
      spec = JSON.parse(spec)
    } catch {
      spec = {}
    }
  }
  return spec
})

watch(
  () => props.show,
  async (newShow) => {
    if (newShow) {
      loadProposalTypes()
    }
  }
)

async function loadProposalTypes() {
  try {
    proposalTypes.value = await api.get<TipoProposta[]>('/api/proposal-types')
  } catch (err) {
    console.error('Erro ao carregar tipos de proposta:', err)
  }
}

function getTypeLabel(tipo: string): string {
  const found = proposalTypes.value.find(t => t.chave === tipo)
  return found ? found.nome : tipo
}

function getStatusLabel(status: string): string {
  switch(status) {
    case 'Pendente': return 'Pendente'
    case 'Aprovada': return 'Aprovada'
    case 'Recusada': return 'Recusada'
    case 'Em Analise': return 'Em Análise'
    default: return status
  }
}

function formatCurrency(val: number): string {
  if (!val) return 'R$ 0,00'
  return new Intl.NumberFormat('pt-BR', { style: 'currency', currency: 'BRL' }).format(val)
}

function formatDate(dateStr: string): string {
  if (!dateStr) return ''
  const date = new Date(dateStr)
  return new Intl.DateTimeFormat('pt-BR', { day: '2-digit', month: '2-digit', year: 'numeric', hour: '2-digit', minute: '2-digit' }).format(date)
}

function getCustomFields(): { label: string; value: any }[] {
  const p = props.proposal
  if (!p) return []
  const specData = dados.value
  
  const foundType = proposalTypes.value.find(t => t.chave === p.tipo)
  if (!foundType || !foundType.campos) {
    return Object.keys(specData).map(key => {
      const label = key
        .replace(/_/g, ' ')
        .replace(/\b\w/g, c => c.toUpperCase())
      return { label, value: formatValue(specData[key]) }
    })
  }

  let fieldsList: CampoTipoProposta[] = []
  if (typeof foundType.campos === 'string') {
    try {
      fieldsList = JSON.parse(foundType.campos)
    } catch {
      // Fallback
    }
  } else {
    fieldsList = foundType.campos as CampoTipoProposta[]
  }

  return fieldsList.map(c => {
    const rawVal = specData[c.chave]
    return {
      label: c.nome,
      value: formatValue(rawVal, c.tipo)
    }
  })
}

function formatValue(val: any, tipo?: string): string {
  if (val === undefined || val === null) return '-'
  if (tipo === 'boolean' || typeof val === 'boolean') {
    return val ? 'Sim' : 'Não'
  }
  return String(val)
}
</script>

<style scoped>
@import "./css/ProposalDetailsModal.css";
</style>

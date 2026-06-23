<template>
  <Modal :show="show" :title="isEditMode ? 'Editar Proposta' : 'Nova Proposta'" icon="assignment" width="700px" @close="$emit('close')">
    <form @submit.prevent="onSubmit" class="form-container">
      
      <!-- Cliente Field -->
      <div class="form-group" v-if="!presetClientId">
        <label class="form-label">Cliente</label>
        <select v-model="form.cliente_id" class="form-control" required>
          <option value="" disabled>Selecione um cliente...</option>
          <option v-for="client in clients" :key="client.id" :value="client.id">
            {{ client.nome }} ({{ formatarCpfCnpj(client.cpf_cnpj) }})
          </option>
        </select>
      </div>
      <div v-else class="preset-client-info">
        <strong>Cliente:</strong> {{ presetClientName }}
      </div>

      <div class="row">
        <!-- Tipo Field -->
        <div class="half-width form-group">
          <label class="form-label">Tipo de Proposta</label>
          <select v-model="form.tipo" class="form-control" required @change="onTipoChange">
            <option value="" disabled>Selecione o tipo...</option>
            <option v-for="type in proposalTypes" :key="type.id" :value="type.chave">
              {{ type.nome }}
            </option>
          </select>
        </div>

        <!-- Status Field -->
        <div class="half-width form-group">
          <label class="form-label">Status</label>
          <select v-model="form.status" class="form-control" required>
            <option value="Pendente">Pendente</option>
            <option value="Em Analise">Em Análise</option>
            <option value="Aprovada">Aprovada</option>
            <option value="Recusada">Recusada</option>
          </select>
        </div>
      </div>

      <!-- Valor Field -->
      <div class="form-group">
        <label class="form-label">Valor (R$)</label>
        <input
          type="text"
          :value="displayValor"
          @input="onValorInput"
          class="form-control"
          placeholder="R$ 0,00"
          required
        />
      </div>

      <!-- Descricao Field -->
      <div class="form-group">
        <label class="form-label">Descrição geral da proposta</label>
        <textarea
          v-model="form.descricao"
          class="form-control"
          placeholder="Escreva observações gerais..."
          rows="2"
        ></textarea>
      </div>

      <!-- Dynamic Specific Fields Wrapper -->
      <div class="specific-fields-container" v-if="form.tipo">
        
        <!-- Imobiliaria Fields -->
        <div v-if="form.tipo === 'Imobiliaria'" class="type-section">
          <h3>Detalhes da Proposta Imobiliária</h3>
          <div class="form-group">
            <label class="form-label">Endereço Completo do Imóvel</label>
            <input
              type="text"
              v-model="dados.endereco_imovel"
              class="form-control"
              placeholder="Rua, Número, Bairro, Cidade - UF"
              required
            />
          </div>

          <div class="row">
            <div class="half-width form-group">
              <label class="form-label">Tipo do Imóvel</label>
              <select v-model="dados.tipo_imovel" class="form-control" required>
                <option value="Casa">Casa</option>
                <option value="Apartamento">Apartamento</option>
                <option value="Comercial">Comercial</option>
                <option value="Terreno">Terreno</option>
              </select>
            </div>
            <div class="half-width form-group">
              <label class="form-label">Área Privativa (m²)</label>
              <input
                type="text"
                :value="displayArea"
                @input="onAreaInput"
                class="form-control"
                placeholder="Ex: 65.000"
                required
              />
            </div>
          </div>

          <!-- Photo Upload Field -->
          <div class="attachment-upload-section">
            <span class="attachment-label">Foto do Imóvel</span>
            <div class="upload-controls">
              <input type="file" ref="photoInput" @change="onPhotoSelected" accept="image/*" style="display: none;">
              <button type="button" class="btn btn-secondary" @click="triggerPhotoInput">
                <i class="material-icons">photo_camera</i> Anexar Foto
              </button>
              <span class="upload-tip">Selecione uma imagem (PNG, JPG)</span>
            </div>
            <div class="preview-container" v-if="dados.foto">
              <div class="preview-card">
                <img :src="dados.foto" alt="Foto do Imóvel" class="photo-preview">
                <button type="button" class="btn-icon btn-icon-danger remove-btn" @click="removePhoto">
                  <i class="material-icons">delete</i>
                </button>
              </div>
            </div>
          </div>
        </div>

        <!-- Auto Fields -->
        <div v-else-if="form.tipo === 'Auto'" class="type-section">
          <h3>Detalhes do Veículo</h3>
          <div class="row">
            <div class="half-width form-group">
              <label class="form-label">Marca</label>
              <input
                type="text"
                v-model="dados.marca"
                class="form-control"
                placeholder="Ex: Chevrolet"
                required
              />
            </div>
            <div class="half-width form-group">
              <label class="form-label">Modelo</label>
              <input
                type="text"
                v-model="dados.modelo"
                class="form-control"
                placeholder="Ex: Onix"
                required
              />
            </div>
          </div>

          <div class="row">
            <div class="half-width form-group">
              <label class="form-label">Ano de Fabricação</label>
              <input
                type="number"
                v-model.number="dados.ano"
                class="form-control"
                placeholder="Ex: 2022"
                min="1900"
                required
              />
            </div>
            <div class="half-width form-group">
              <label class="form-label">Placa do Veículo</label>
              <input
                type="text"
                :value="dados.placa"
                @input="onPlacaInput"
                class="form-control"
                placeholder="Ex: ABC-1234"
                required
              />
            </div>
          </div>

          <!-- Photo Upload Field -->
          <div class="attachment-upload-section">
            <span class="attachment-label">Foto do Veículo</span>
            <div class="upload-controls">
              <input type="file" ref="photoInputAuto" @change="onPhotoSelected" accept="image/*" style="display: none;">
              <button type="button" class="btn btn-secondary" @click="triggerPhotoInputAuto">
                <i class="material-icons">photo_camera</i> Anexar Foto
              </button>
              <span class="upload-tip">Selecione uma imagem (PNG, JPG)</span>
            </div>
            <div class="preview-container" v-if="dados.foto">
              <div class="preview-card">
                <img :src="dados.foto" alt="Foto do Veículo" class="photo-preview">
                <button type="button" class="btn-icon btn-icon-danger remove-btn" @click="removePhoto">
                  <i class="material-icons">delete</i>
                </button>
              </div>
            </div>
          </div>
        </div>

        <!-- Comissionados Fields -->
        <div v-else-if="form.tipo === 'Comissionados'" class="type-section">
          <h3>Detalhes de Comissionados (PVA)</h3>
          <div class="form-group">
            <label class="form-label">Descrição dos Itens / Serviços</label>
            <textarea
              v-model="dados.itens"
              class="form-control"
              placeholder="Liste detalhadamente os itens..."
              rows="2"
              required
            ></textarea>
          </div>

          <div class="form-group">
            <label class="form-label">Condições de Pagamento</label>
            <input
              type="text"
              v-model="dados.condicoes_pagamento"
              class="form-control"
              placeholder="Ex: Entrada de 50% + 3x"
              required
            />
          </div>

          <div class="row" style="margin-top: 16px;">
            <!-- Photo Upload -->
            <div class="half-width attachment-upload-section">
              <span class="attachment-label">Foto do Item</span>
              <div class="upload-controls">
                <input type="file" ref="photoInputCV" @change="onPhotoSelected" accept="image/*" style="display: none;">
                <button type="button" class="btn btn-secondary" @click="triggerPhotoInputCV">
                  <i class="material-icons">photo_camera</i> Foto
                </button>
              </div>
              <div class="preview-container" v-if="dados.foto" style="margin-top: 8px;">
                <div class="preview-card">
                  <img :src="dados.foto" alt="Foto do Item" class="photo-preview">
                  <button type="button" class="btn-icon btn-icon-danger remove-btn" @click="removePhoto">
                    <i class="material-icons">delete</i>
                  </button>
                </div>
              </div>
            </div>

            <!-- Document Upload -->
            <div class="half-width attachment-upload-section">
              <span class="attachment-label">Documento Adicional (Até 8MB)</span>
              <div class="upload-controls">
                <input type="file" ref="docInputCV" @change="onAttachmentSelected" style="display: none;">
                <button type="button" class="btn btn-secondary" @click="triggerDocInputCV">
                  <i class="material-icons">attach_file</i> Documento
                </button>
              </div>
              <div class="doc-preview-container" v-if="dados.anexo" style="margin-top: 8px;">
                <div class="doc-card">
                  <i class="material-icons doc-icon" style="color: var(--primary);">insert_drive_file</i>
                  <div class="doc-info">
                    <span class="doc-name">{{ dados.nome_anexo || 'Documento' }}</span>
                  </div>
                  <button type="button" class="btn-icon btn-icon-danger" @click="removeAttachment">
                    <i class="material-icons">close</i>
                  </button>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- Custom/Dynamic Fields -->
        <div v-else class="type-section">
          <h3>Detalhes de {{ getSelectedTypeLabel() }}</h3>
          
          <div v-for="campo in getSelectedTypeFields()" :key="campo.chave" class="form-group">
            <label class="form-label">{{ campo.nome }} <span v-if="campo.obrigatorio">*</span></label>
            
            <!-- Text field -->
            <input
              v-if="campo.tipo === 'text'"
              type="text"
              v-model="dados[campo.chave]"
              class="form-control"
              :placeholder="campo.nome"
              :required="campo.obrigatorio"
            />

            <!-- Number field -->
            <input
              v-else-if="campo.tipo === 'number'"
              type="number"
              v-model.number="dados[campo.chave]"
              class="form-control"
              :placeholder="campo.nome"
              :required="campo.obrigatorio"
            />

            <!-- Boolean select -->
            <select
              v-else-if="campo.tipo === 'boolean'"
              v-model="dados[campo.chave]"
              class="form-control"
              :required="campo.obrigatorio"
            >
              <option :value="true">Sim</option>
              <option :value="false">Não</option>
            </select>
          </div>
        </div>

      </div>
    </form>

    <template #actions>
      <button type="button" class="btn btn-secondary" @click="$emit('close')" :disabled="loading">
        Cancelar
      </button>
      <button
        type="button"
        class="btn btn-primary"
        :disabled="loading || !isFormValid"
        @click="onSubmit"
      >
        <span v-if="loading" class="btn-spinner"></span>
        <span>{{ isEditMode ? 'Salvar' : 'Criar' }}</span>
      </button>
    </template>
  </Modal>
</template>

<script setup lang="ts">
import { ref, computed, watch } from 'vue'
import { Cliente, Proposta, TipoProposta, CampoTipoProposta } from '@/types'
import { api } from '@/services/api'
import Modal from './Modal.vue'
import { formatarCpfCnpj } from '@/utils/formatters'

const props = defineProps({
  show: {
    type: Boolean,
    required: true
  },
  proposal: {
    type: Object as () => any,
    default: null
  }
})

const emit = defineEmits(['close', 'save'])

const photoInput = ref<HTMLInputElement | null>(null)
const photoInputAuto = ref<HTMLInputElement | null>(null)
const photoInputCV = ref<HTMLInputElement | null>(null)
const docInputCV = ref<HTMLInputElement | null>(null)

function triggerPhotoInput() {
  photoInput.value?.click()
}
function triggerPhotoInputAuto() {
  photoInputAuto.value?.click()
}
function triggerPhotoInputCV() {
  photoInputCV.value?.click()
}
function triggerDocInputCV() {
  docInputCV.value?.click()
}

const displayValor = ref('')

function formatarMoeda(value: number | string): string {
  if (value === undefined || value === null || value === '') return ''
  const cleanValue = String(value).replace(/\D/g, '')
  if (!cleanValue) return ''
  const numberValue = parseFloat(cleanValue) / 100
  return new Intl.NumberFormat('pt-BR', {
    style: 'currency',
    currency: 'BRL'
  }).format(numberValue)
}

function onValorInput(e: Event) {
  const input = e.target as HTMLInputElement
  let raw = input.value.replace(/\D/g, '')
  
  // Update internal numeric value
  const numValue = raw ? parseFloat(raw) / 100 : 0
  form.value.valor = numValue
  
  // Format target display
  displayValor.value = formatarMoeda(raw)
}

const displayArea = ref('')

function formatarArea(val: string | number): string {
  if (val === undefined || val === null || val === '') return ''
  const clean = String(val).replace(/\D/g, '')
  if (!clean) return ''
  return new Intl.NumberFormat('pt-BR').format(parseInt(clean))
}

function onAreaInput(e: Event) {
  const input = e.target as HTMLInputElement
  const clean = input.value.replace(/\D/g, '')
  dados.value.area_m2 = clean ? parseInt(clean) : undefined
  displayArea.value = formatarArea(clean)
}

function formatarPlaca(val: string): string {
  let clean = val.replace(/[^a-zA-Z0-9]/g, '').toUpperCase().substring(0, 7)
  if (clean.length === 7) {
    if (/^[A-Z]{3}\d{4}$/.test(clean)) {
      return clean.replace(/^([A-Z]{3})(\d{4})$/, '$1-$2')
    }
  }
  return clean
}

function onPlacaInput(e: Event) {
  const input = e.target as HTMLInputElement
  dados.value.placa = formatarPlaca(input.value)
}

const loading = ref(false)
const clients = ref<Cliente[]>([])
const proposalTypes = ref<TipoProposta[]>([])

const presetClientId = ref<string | null>(null)
const presetClientName = ref<string | null>(null)
const isEditMode = ref(false)

const form = ref<Partial<Proposta>>({
  cliente_id: '',
  tipo: '',
  valor: 0,
  status: 'Pendente',
  descricao: ''
})

// Specific dynamic data
const dados = ref<any>({})

watch(
  () => props.show,
  async (newShow) => {
    if (newShow) {
      loading.value = true
      await Promise.all([loadClients(), loadProposalTypes()])
      setupForm()
      loading.value = false
    }
  }
)

function setupForm() {
  const p = props.proposal
  isEditMode.value = !!p?.id
  
  if (p) {
    if (!isEditMode.value && p.cliente_id) {
      // Preset client info from route redirect
      presetClientId.value = p.cliente_id
      presetClientName.value = p.cliente_nome
      form.value = {
        cliente_id: p.cliente_id,
        tipo: '',
        valor: undefined,
        status: 'Pendente',
        descricao: ''
      }
      dados.value = {}
      displayValor.value = ''
      displayArea.value = ''
    } else {
      // Edit mode
      presetClientId.value = null
      presetClientName.value = null
      form.value = {
        id: p.id,
        cliente_id: p.cliente_id,
        tipo: p.tipo,
        valor: p.valor,
        status: p.status,
        descricao: p.descricao
      }
      
      let spec = p.dados_especificos
      if (typeof spec === 'string') {
        try {
          spec = JSON.parse(spec)
        } catch {
          spec = {}
        }
      }
      dados.value = { ...spec }
      
      if (p.valor) {
        const cents = Math.round(p.valor * 100)
        displayValor.value = formatarMoeda(cents)
      } else {
        displayValor.value = ''
      }
      
      if (spec.area_m2) {
        displayArea.value = formatarArea(spec.area_m2)
      } else {
        displayArea.value = ''
      }
    }
  } else {
    presetClientId.value = null
    presetClientName.value = null
    form.value = {
      cliente_id: '',
      tipo: '',
      valor: undefined,
      status: 'Pendente',
      descricao: ''
    }
    dados.value = {}
    displayValor.value = ''
    displayArea.value = ''
  }
}

async function loadClients() {
  try {
    clients.value = await api.get<Cliente[]>('/api/clients')
  } catch (err) {
    console.error('Erro ao carregar clientes:', err)
  }
}

async function loadProposalTypes() {
  try {
    proposalTypes.value = await api.get<TipoProposta[]>('/api/proposal-types')
  } catch (err) {
    console.error('Erro ao carregar tipos de proposta:', err)
  }
}

function onTipoChange() {
  const tipo = form.value.tipo
  dados.value = {}
  
  if (tipo === 'Imobiliaria') {
    dados.value = {
      endereco_imovel: '',
      tipo_imovel: 'Casa',
      area_m2: undefined,
      foto: ''
    }
    displayArea.value = ''
  } else if (tipo === 'Auto') {
    dados.value = {
      marca: '',
      modelo: '',
      ano: undefined,
      placa: '',
      foto: ''
    }
  } else if (tipo === 'Comissionados') {
    dados.value = {
      itens: '',
      condicoes_pagamento: '',
      foto: '',
      anexo: '',
      nome_anexo: ''
    }
  } else {
    // Dynamic fields initialization
    const fields = getSelectedTypeFields()
    fields.forEach(c => {
      dados.value[c.chave] = c.tipo === 'boolean' ? false : (c.tipo === 'number' ? undefined : '')
    })
  }
}

function getSelectedTypeLabel(): string {
  const found = proposalTypes.value.find(t => t.chave === form.value.tipo)
  return found ? found.nome : form.value.tipo || ''
}

function getSelectedTypeFields(): CampoTipoProposta[] {
  const found = proposalTypes.value.find(t => t.chave === form.value.tipo)
  if (!found || !found.campos) return []
  if (typeof found.campos === 'string') {
    try {
      return JSON.parse(found.campos)
    } catch {
      return []
    }
  }
  return found.campos as CampoTipoProposta[]
}

function onPhotoSelected(e: Event) {
  const input = e.target as HTMLInputElement
  if (input.files && input.files[0]) {
    const file = input.files[0]
    if (!file.type.startsWith('image/')) {
      alert('Por favor, selecione apenas arquivos de imagem.')
      return
    }
    if (file.size > 10 * 1024 * 1024) {
      alert('A imagem excede o limite máximo permitido de 10MB.')
      return
    }
    const reader = new FileReader()
    reader.onload = () => {
      dados.value.foto = reader.result as string
    }
    reader.readAsDataURL(file)
  }
}

function removePhoto() {
  dados.value.foto = ''
}

function onAttachmentSelected(e: Event) {
  const input = e.target as HTMLInputElement
  if (input.files && input.files[0]) {
    const file = input.files[0]
    if (file.size > 8 * 1024 * 1024) {
      alert('O arquivo excede o limite máximo permitido de 8MB.')
      return
    }
    const reader = new FileReader()
    reader.onload = () => {
      dados.value.anexo = reader.result as string
      dados.value.nome_anexo = file.name
    }
    reader.readAsDataURL(file)
  }
}

function removeAttachment() {
  dados.value.anexo = ''
  dados.value.nome_anexo = ''
}

const isFormValid = computed(() => {
  const f = form.value
  if (!f.cliente_id || !f.tipo || !f.valor || f.valor <= 0) return false
  
  const d = dados.value
  if (f.tipo === 'Imobiliaria') {
    return d.endereco_imovel && d.tipo_imovel && d.area_m2 && d.area_m2 > 0
  } else if (f.tipo === 'Auto') {
    return d.marca && d.modelo && d.ano && d.ano >= 1900 && d.placa
  } else if (f.tipo === 'Comissionados') {
    return d.itens && d.condicoes_pagamento
  } else {
    // Custom types validation
    const fields = getSelectedTypeFields()
    for (const field of fields) {
      if (field.obrigatorio) {
        const val = d[field.chave]
        if (val === undefined || val === null || val === '') {
          return false
        }
      }
    }
  }
  return true
})

async function onSubmit() {
  if (!isFormValid.value) return
  
  loading.value = true
  
  // Filter specific data based on selected type
  let filteredDados: any = {}
  const tipo = form.value.tipo
  
  if (tipo === 'Imobiliaria') {
    filteredDados = {
      endereco_imovel: dados.value.endereco_imovel,
      tipo_imovel: dados.value.tipo_imovel,
      area_m2: dados.value.area_m2,
      foto: dados.value.foto
    }
  } else if (tipo === 'Auto') {
    filteredDados = {
      marca: dados.value.marca,
      modelo: dados.value.modelo,
      ano: dados.value.ano,
      placa: dados.value.placa,
      foto: dados.value.foto
    }
  } else if (tipo === 'Comissionados') {
    filteredDados = {
      itens: dados.value.itens,
      condicoes_pagamento: dados.value.condicoes_pagamento,
      foto: dados.value.foto,
      anexo: dados.value.anexo,
      nome_anexo: dados.value.nome_anexo
    }
  } else {
    const fields = getSelectedTypeFields()
    fields.forEach(c => {
      filteredDados[c.chave] = dados.value[c.chave]
    })
  }

  const payload: Proposta = {
    cliente_id: form.value.cliente_id!,
    tipo: form.value.tipo!,
    valor: Number(form.value.valor),
    status: form.value.status!,
    descricao: form.value.descricao,
    dados_especificos: JSON.stringify(filteredDados)
  }

  try {
    if (isEditMode.value && form.value.id) {
      payload.id = form.value.id
      await api.put<Proposta>(`/api/proposals/${form.value.id}`, payload)
    } else {
      await api.post<Proposta>('/api/proposals', payload)
    }
    emit('save')
  } catch (err) {
    console.error('Erro ao salvar proposta:', err)
  } finally {
    loading.value = false
  }
}
</script>

<style scoped>
@import "./css/ProposalFormModal.css";
</style>

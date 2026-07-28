import { api } from '@/services/api'

/**
 * Formata um valor numérico como moeda BRL (R$)
 */
export function formatCurrency(val: number | undefined | null): string {
  if (val === undefined || val === null) return 'R$ 0,00'
  return new Intl.NumberFormat('pt-BR', { style: 'currency', currency: 'BRL' }).format(val)
}

/**
 * Formata uma string de data ISO para o padrão brasileiro (dd/mm/aaaa)
 */
export function formatDate(dateStr?: string): string {
  if (!dateStr) return '—'
  const date = new Date(dateStr)
  return new Intl.DateTimeFormat('pt-BR', {
    day: '2-digit',
    month: '2-digit',
    year: 'numeric'
  }).format(date)
}

/**
 * Formata data com hora para uso em painéis de auditoria/supervisor
 */
export function formatDateTime(dateStr?: string): string {
  if (!dateStr) return ''
  const date = new Date(dateStr)
  return new Intl.DateTimeFormat('pt-BR', {
    day: '2-digit',
    month: '2-digit',
    year: 'numeric',
    hour: '2-digit',
    minute: '2-digit'
  }).format(date)
}

/**
 * Retorna o label traduzido para o status da proposta
 */
export function getStatusLabel(status: string): string {
  switch (status) {
    case 'Pendente': return 'Pendente'
    case 'Aprovada': return 'Aprovada'
    case 'Recusada': return 'Recusada'
    case 'Em Analise': return 'Em Análise'
    default: return status
  }
}

/**
 * Retorna o label traduzido para o tipo de proposta (fallback legado)
 */
export function getTypeLabel(tipo: string, types?: { chave: string; nome: string }[]): string {
  if (types) {
    const found = types.find(t => t.chave === tipo)
    if (found) return found.nome
  }
  // Fallback legado
  switch (tipo) {
    case 'Imobiliaria': return 'Imobiliária'
    case 'Auto': return 'Automotiva'
    case 'Comissionados': return 'Comissionados (PVA)'
    default: return tipo
  }
}

/**
 * Retorna o label traduzido para ações do painel supervisor
 */
export function getActionLabel(action: string): string {
  switch (action) {
    case 'DeletarCliente': return 'Excluir Cliente'
    case 'DeletarProposta': return 'Excluir Proposta'
    case 'AprovarProposta': return 'Aprovar Proposta'
    case 'EncaminharEmpresa': return 'Encaminhar para Empresa'
    default: return action
  }
}

/**
 * Retorna a classe CSS correspondente ao status
 */
export function getStatusClass(status: string): string {
  return status.toLowerCase().replace(' ', '-')
}

/**
 * Helper para formatar valores grandes (ex: área em m²)
 */
export function formatNumber(val: number | string | undefined | null): string {
  if (val === undefined || val === null) return ''
  const num = typeof val === 'string' ? parseFloat(val) : val
  if (isNaN(num)) return ''
  return new Intl.NumberFormat('pt-BR').format(num)
}

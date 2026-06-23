<template>
  <div>
    <div class="dashboard-header">
      <h1>Dashboard Geral</h1>
      <p>Resumo das atividades comerciais, comissões de corretagem e empresas parceiras.</p>
    </div>

    <div v-if="loading" class="spinner-container">
      <div class="spinner"></div>
    </div>

    <div v-else-if="stats" class="dashboard-content">
      <!-- Metrics Grid -->
      <div class="metrics-grid">
        <!-- Clientes -->
        <div class="card metric-card clients-card">
          <div class="metric-icon">
            <i class="material-icons">people</i>
          </div>
          <div class="metric-details">
            <h3>Clientes</h3>
            <h2>{{ stats.total_clients }}</h2>
            <p>Clientes cadastrados</p>
          </div>
        </div>

        <!-- Propostas -->
        <div class="card metric-card proposals-card">
          <div class="metric-icon">
            <i class="material-icons">assignment</i>
          </div>
          <div class="metric-details">
            <h3>Propostas</h3>
            <h2>{{ stats.total_proposals }}</h2>
            <p>Propostas registradas</p>
          </div>
        </div>

        <!-- Empresas Parceiras -->
        <div class="card metric-card companies-card">
          <div class="metric-icon">
            <i class="material-icons">business</i>
          </div>
          <div class="metric-details">
            <h3>Empresas Parceiras</h3>
            <h2>{{ stats.total_companies }}</h2>
            <p>Empresas credenciadas</p>
          </div>
        </div>

        <!-- Volume de Operações -->
        <div class="card metric-card value-card">
          <div class="metric-icon">
            <i class="material-icons">monetization_on</i>
          </div>
          <div class="metric-details">
            <h3>Volume de Operações</h3>
            <h2>{{ formatCurrency(stats.total_value) }}</h2>
            <p>Valor total de propostas</p>
          </div>
        </div>

        <!-- Comissões Faturadas -->
        <div class="card metric-card commission-closed-card">
          <div class="metric-icon">
            <i class="material-icons">check_circle</i>
          </div>
          <div class="metric-details">
            <h3>Comissões Faturadas</h3>
            <h2>{{ formatCurrency(stats.closed_commissions_value) }}</h2>
            <p>Corretagem ganha e fechada</p>
          </div>
        </div>

        <!-- Comissões Pendentes -->
        <div class="card metric-card commission-pending-card">
          <div class="metric-icon">
            <i class="material-icons">hourglass_empty</i>
          </div>
          <div class="metric-details">
            <h3>Comissões Pendentes</h3>
            <h2>{{ formatCurrency(stats.pending_commissions_value) }}</h2>
            <p>Estimativa em propostas ativas</p>
          </div>
        </div>
      </div>

      <!-- Breakdown Grid -->
      <div class="breakdown-grid">
        <!-- Breakdown por Tipo -->
        <div class="card breakdown-card">
          <div class="breakdown-header">
            <h2>Propostas por Tipo</h2>
          </div>
          <div class="breakdown-list">
            <div v-for="(count, key) in stats.proposals_by_type" :key="key" class="breakdown-item">
              <div class="item-info">
                <span class="item-name">{{ getTypeLabel(String(key)) }}</span>
                <span class="item-count">{{ count }} un.</span>
              </div>
              <div class="item-value">
                {{ formatCurrency(stats.value_by_type[key] || 0) }}
              </div>
            </div>
            <div v-if="!Object.keys(stats.proposals_by_type).length" class="empty-state">
              Nenhuma proposta registrada.
            </div>
          </div>
        </div>

        <!-- Breakdown por Status -->
        <div class="card breakdown-card">
          <div class="breakdown-header">
            <h2>Propostas por Status</h2>
          </div>
          <div class="breakdown-list">
            <div v-for="(count, key) in stats.proposals_by_status" :key="key" class="breakdown-item">
              <div class="item-info">
                <span class="status-tag" :class="String(key).toLowerCase().replace(' ', '-')">
                  {{ getStatusLabel(String(key)) }}
                </span>
                <span class="item-count">{{ count }} un.</span>
              </div>
              <div class="item-value">
                {{ formatCurrency(stats.value_by_status[key] || 0) }}
              </div>
            </div>
            <div v-if="!Object.keys(stats.proposals_by_status).length" class="empty-state">
              Nenhum status disponível.
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { DashboardStats } from '@/types'
import { api } from '@/services/api'

const stats = ref<DashboardStats | null>(null)
const loading = ref(true)

onMounted(async () => {
  try {
    stats.value = await api.get<DashboardStats>('/api/dashboard/stats')
  } catch (err) {
    console.error('Erro ao carregar estatísticas:', err)
  } finally {
    loading.value = false
  }
})

function formatCurrency(val: number): string {
  if (val === undefined || val === null) return 'R$ 0,00'
  return new Intl.NumberFormat('pt-BR', { style: 'currency', currency: 'BRL' }).format(val)
}

function getStatusLabel(status: string): string {
  switch (status) {
    case 'Pendente': return 'Pendente'
    case 'Aprovada': return 'Aprovada'
    case 'Recusada': return 'Recusada'
    case 'Em Analise': return 'Em Análise'
    default: return status
  }
}

function getTypeLabel(tipo: string): string {
  switch (tipo) {
    case 'Imobiliaria': return 'Imobiliária'
    case 'Auto': return 'Automotiva'
    case 'Comissionados': return 'Comissionados (PVA)'
    default: return tipo
  }
}
</script>

<style scoped>
@import "./css/DashboardView.css";
</style>

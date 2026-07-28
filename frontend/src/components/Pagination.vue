<template>
  <div v-if="totalPages > 1" class="pagination-bar">
    <!-- Info: "Mostrando X a Y de Z registros" -->
    <div class="pagination-info">
      Mostrando
      <strong>{{ rangeStart }}</strong>
      a
      <strong>{{ rangeEnd }}</strong>
      de
      <strong>{{ totalItems }}</strong>
      {{ pluralSuffix }}
    </div>

    <!-- Per-page selector -->
    <div class="pagination-per-page">
      <label class="per-page-label">Itens/página:</label>
      <select
        :value="perPage"
        @change="onPerPageChange"
        class="per-page-select"
      >
        <option
          v-for="opt in perPageOptions"
          :key="opt"
          :value="opt"
        >
          {{ opt }}
        </option>
      </select>
    </div>

    <!-- Navigation buttons -->
    <div class="pagination-nav">
      <!-- Previous -->
      <button
        class="page-btn page-nav-btn"
        :disabled="modelValue <= 1"
        @click="goTo(modelValue - 1)"
        title="Página anterior"
      >
        <i class="material-icons">chevron_left</i>
      </button>

      <!-- Page numbers -->
      <template v-for="page in visiblePages" :key="page">
        <!-- Ellipsis -->
        <span v-if="page === '...'" class="page-ellipsis">...</span>

        <!-- Page button -->
        <button
          v-else
          class="page-btn"
          :class="{ 'page-active': page === modelValue }"
          @click="goTo(page as number)"
        >
          {{ page }}
        </button>
      </template>

      <!-- Next -->
      <button
        class="page-btn page-nav-btn"
        :disabled="modelValue >= totalPages"
        @click="goTo(modelValue + 1)"
        title="Próxima página"
      >
        <i class="material-icons">chevron_right</i>
      </button>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue'

const props = defineProps({
  /** Current page (v-model) */
  modelValue: {
    type: Number,
    required: true
  },
  /** Total number of items across all pages */
  totalItems: {
    type: Number,
    required: true
  },
  /** Items per page */
  perPage: {
    type: Number,
    default: 10
  },
  /** Options for per-page selector */
  perPageOptions: {
    type: Array as () => number[],
    default: () => [10, 20, 50]
  }
})

const emit = defineEmits<{
  'update:modelValue': [page: number]
  'update:perPage': [perPage: number]
}>()

/** Total number of pages */
const totalPages = computed(() => Math.max(1, Math.ceil(props.totalItems / props.perPage)))

/** Start item number on current page (1-indexed) */
const rangeStart = computed(() => (props.modelValue - 1) * props.perPage + 1)

/** End item number on current page */
const rangeEnd = computed(() => Math.min(props.modelValue * props.perPage, props.totalItems))

const pluralSuffix = computed(() => props.totalItems === 1 ? 'registro' : 'registros')

/**
 * Returns an array of pages and ellipsis markers to display.
 * Always shows first, last, and a window around current page.
 */
const visiblePages = computed(() => {
  const total = totalPages.value
  const current = props.modelValue
  const pages: (number | '...')[] = []

  if (total <= 7) {
    // Show all pages
    for (let i = 1; i <= total; i++) pages.push(i)
    return pages
  }

  // Always include first page
  pages.push(1)

  if (current > 3) {
    pages.push('...')
  }

  // Window around current page
  const windowStart = Math.max(2, current - 1)
  const windowEnd = Math.min(total - 1, current + 1)

  for (let i = windowStart; i <= windowEnd; i++) {
    pages.push(i)
  }

  if (current < total - 2) {
    pages.push('...')
  }

  // Always include last page
  pages.push(total)

  return pages
})

function goTo(page: number) {
  if (page < 1 || page > totalPages.value) return
  emit('update:modelValue', page)
}

function onPerPageChange(event: Event) {
  const target = event.target as HTMLSelectElement
  const newPerPage = Number(target.value)
  emit('update:perPage', newPerPage)
  // Reset to first page when changing per-page
  emit('update:modelValue', 1)
}
</script>

<style scoped>
.pagination-bar {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 16px;
  padding: 16px 24px;
  border-top: 1px solid var(--border-color);
  background-color: #fafbfc;
  flex-wrap: wrap;
}

.pagination-info {
  font-size: 0.85rem;
  color: var(--text-muted);
  white-space: nowrap;
}

.pagination-info strong {
  color: var(--text-dark);
  font-weight: 700;
}

.pagination-per-page {
  display: flex;
  align-items: center;
  gap: 8px;
}

.per-page-label {
  font-size: 0.82rem;
  color: var(--text-muted);
  font-weight: 600;
  white-space: nowrap;
}

.per-page-select {
  font-family: var(--font-plain);
  font-size: 0.82rem;
  padding: 4px 8px;
  border-radius: var(--radius-sm);
  border: 1px solid #cbd5e1;
  background-color: #ffffff;
  color: var(--text-dark);
  outline: none;
  cursor: pointer;
  transition: var(--transition-smooth);
}

.per-page-select:focus {
  border-color: var(--primary);
  box-shadow: 0 0 0 2px rgba(79, 70, 229, 0.15);
}

.pagination-nav {
  display: flex;
  align-items: center;
  gap: 4px;
}

.page-btn {
  min-width: 36px;
  height: 36px;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  border: 1px solid #e2e8f0;
  border-radius: var(--radius-sm);
  background-color: #ffffff;
  color: var(--text-main);
  font-size: 0.85rem;
  font-weight: 600;
  cursor: pointer;
  transition: var(--transition-smooth);
  padding: 0 6px;
  font-family: var(--font-plain);
}

.page-btn:hover:not(:disabled):not(.page-active) {
  background-color: #f1f5f9;
  border-color: #94a3b8;
}

.page-btn:disabled {
  opacity: 0.4;
  cursor: not-allowed;
}

.page-active {
  background-color: var(--primary);
  border-color: var(--primary);
  color: #ffffff;
  box-shadow: 0 2px 8px rgba(79, 70, 229, 0.25);
}

.page-nav-btn i {
  font-size: 20px;
}

.page-ellipsis {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 28px;
  height: 36px;
  font-size: 0.9rem;
  color: var(--text-muted);
  letter-spacing: 2px;
  user-select: none;
}

@media (max-width: 600px) {
  .pagination-bar {
    flex-direction: column;
    align-items: stretch;
    gap: 12px;
    padding: 12px 16px;
  }

  .pagination-info {
    text-align: center;
  }

  .pagination-per-page {
    justify-content: center;
  }

  .pagination-nav {
    justify-content: center;
  }
}
</style>

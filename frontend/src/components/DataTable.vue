<template>
  <div class="card table-card">
    <!-- Filter slot -->
    <div v-if="$slots.filter" class="filter-header">
      <slot name="filter" />
    </div>

    <!-- Loading -->
    <div v-if="loading" class="spinner-container">
      <div class="spinner"></div>
    </div>

    <!-- Table -->
    <template v-else>
      <div class="table-container">
        <table class="data-table" :class="{ 'crud-table': compact }">
          <thead>
            <tr>
              <th
                v-for="col in columns"
                :key="col.key"
                :class="[
                  col.class,
                  col.responsive ? `col-${col.responsive}` : '',
                  { 'actions-header': isActionsColumn(col) }
                ]"
                :style="isActionsColumn(col) ? 'text-align: right;' : (col.align ? `text-align: ${col.align};` : undefined)"
              >
                {{ col.label }}
              </th>
            </tr>
          </thead>
          <tbody>
            <tr
              v-for="row in displayRows"
              :key="rowKey ? rowKey(row) : row.id"
              :class="{ 'row-clickable': clickable }"
              @click="onRowClick(row)"
            >
              <td
                v-for="col in columns"
                :key="col.key"
                :class="col.responsive ? `col-${col.responsive}` : ''"
                :style="col.align ? `text-align: ${col.align};` : undefined"
              >
                <!-- Slot for custom cell content: cell-{key} -->
                <slot :name="`cell-${col.key}`" :row="row" :value="getCellValue(row, col)">
                  <!-- Default rendering for non-actions columns -->
                  <template v-if="!isActionsColumn(col)">
                    <strong v-if="col.bold">{{ getCellValue(row, col) }}</strong>
                    <template v-else>{{ getCellValue(row, col) }}</template>
                  </template>
                </slot>

                <!-- Actions wrapper for 'actions' column if no cell slot provided -->
                <div v-if="isActionsColumn(col) && !$slots[`cell-${col.key}`]" class="actions-wrapper" @click.stop>
                  <slot name="actions" :row="row" />
                </div>
              </td>
            </tr>

            <!-- Empty state -->
            <tr v-if="displayRows.length === 0">
              <td :colspan="columns.length" class="no-data-placeholder">
                <i class="material-icons">{{ emptyIcon }}</i>
                <span>{{ emptyText }}</span>
              </td>
            </tr>
          </tbody>
        </table>
      </div>

      <!-- Pagination -->
      <Pagination
        v-if="paginate && rows.length > 0"
        v-model="currentPage"
        :total-items="rows.length"
        :per-page="internalPerPage"
        @update:per-page="onPerPageChange"
      />
    </template>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, watch } from 'vue'
import Pagination from '@/components/Pagination.vue'

export interface ColumnDefinition {
  /** Unique key for the column */
  key: string
  /** Display label (thead) */
  label: string
  /** Optional extra CSS class */
  class?: string
  /** Responsive breakpoint class (e.g., 'email', 'cnpj', 'created_at') */
  responsive?: string
  /** Text alignment */
  align?: 'left' | 'center' | 'right'
  /** If true, wraps value in <strong> */
  bold?: boolean
  /** Optional formatter function */
  formatter?: (value: any, row: any) => string
  /** Field path to extract value from row (supports dot notation). Defaults to column key */
  field?: string
}

const props = defineProps({
  columns: {
    type: Array as () => ColumnDefinition[],
    required: true
  },
  rows: {
    type: Array as () => any[],
    required: true
  },
  loading: {
    type: Boolean,
    default: false
  },
  emptyIcon: {
    type: String,
    default: 'info'
  },
  emptyText: {
    type: String,
    default: 'Nenhum registro encontrado.'
  },
  compact: {
    type: Boolean,
    default: false
  },
  /** If true, rows show a pointer cursor on hover */
  clickable: {
    type: Boolean,
    default: false
  },
  rowKey: {
    type: Function as () => (row: any) => string | number,
    default: undefined
  },
  /** Enable client-side pagination */
  paginate: {
    type: Boolean,
    default: false
  },
  /** Number of rows per page (when paginate is true) */
  perPage: {
    type: Number,
    default: 10
  }
})

const emit = defineEmits<{
  'row-click': [row: any]
}>()

// Pagination state
const currentPage = ref(1)
const internalPerPage = ref(props.perPage)

/** Sync internal perPage when prop changes externally */
watch(() => props.perPage, (val) => {
  internalPerPage.value = val
})

/** Reset to page 1 when data or per-page changes */
watch([() => props.rows.length, internalPerPage], () => {
  currentPage.value = 1
})

/** Sliced rows for current page */
const displayRows = computed(() => {
  if (!props.paginate) return props.rows
  const start = (currentPage.value - 1) * internalPerPage.value
  return props.rows.slice(start, start + internalPerPage.value)
})

/** Called when user changes per-page via Pagination selector */
function onPerPageChange(newPerPage: number) {
  internalPerPage.value = newPerPage
}

/** Columns that have key === 'actions' are treated as the actions column */
function isActionsColumn(col: ColumnDefinition): boolean {
  return col.key === 'actions'
}

/** Extract value from row using the column definition */
function getCellValue(row: any, col: ColumnDefinition): string {
  const field = col.field || col.key
  const raw = field.split('.').reduce((obj: any, key: string) => obj?.[key], row)
  if (raw === undefined || raw === null) return '—'
  return col.formatter ? col.formatter(raw, row) : String(raw)
}

/** Emit row-click with the clicked row */
function onRowClick(row: any) {
  emit('row-click', row)
}
</script>

<style scoped>
.row-clickable {
  cursor: pointer;
}

.row-clickable:hover td {
  background-color: #f0f4ff !important;
}
</style>

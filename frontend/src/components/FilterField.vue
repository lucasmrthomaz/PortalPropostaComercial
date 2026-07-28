<template>
  <!-- Search input with icon (debounced) -->
  <div v-if="type === 'search'" class="filter-field">
    <div class="input-with-icon">
      <i class="material-icons icon-prefix">search</i>
      <input
        ref="inputRef"
        type="text"
        :value="displayValue"
        @input="onInput($event)"
        class="form-control"
        :placeholder="placeholder"
      />
      <!-- Clear button appears when there's text -->
      <button
        v-if="displayValue"
        class="suffix-btn"
        @click="onClear"
        type="button"
        tabindex="-1"
        title="Limpar busca"
      >
        <i class="material-icons">close</i>
      </button>
    </div>
  </div>

  <!-- Select dropdown with label -->
  <div v-else-if="type === 'select'" class="form-group filter-field">
    <label v-if="label" class="form-label">{{ label }}</label>
    <select
      :value="modelValue"
      @change="onSelect($event)"
      class="form-control"
    >
      <option value="all">{{ allLabel }}</option>
      <option
        v-for="opt in normalizedOptions"
        :key="opt.value"
        :value="opt.value"
      >
        {{ opt.label }}
      </option>
    </select>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, watch } from 'vue'
import { useDebounce } from '@/composables/useDebounce'

export interface FilterOption {
  value: string
  label: string
}

const props = defineProps({
  /** v-model binding */
  modelValue: {
    type: String,
    default: ''
  },
  /** Filter type: 'search' (input with icon) or 'select' (dropdown) */
  type: {
    type: String as () => 'search' | 'select',
    default: 'search'
  },
  /** Placeholder text (type=search) */
  placeholder: {
    type: String,
    default: 'Buscar...'
  },
  /** Label above the select (type=select) */
  label: {
    type: String,
    default: ''
  },
  /** Options array for select (type=select) */
  options: {
    type: Array as () => (FilterOption | string)[],
    default: () => []
  },
  /** Label for the 'all' default option (type=select) */
  allLabel: {
    type: String,
    default: 'Todos'
  },
  /**
   * Debounce delay in ms for type="search".
   * The input updates visually immediately, but the v-model
   * only emits after the user stops typing for this duration.
   * Set to 0 to disable debounce.
   */
  debounceMs: {
    type: Number,
    default: 300
  }
})

const emit = defineEmits<{
  'update:modelValue': [value: string]
}>()

// ---- Local display value (updates immediately) ----
const inputRef = ref<HTMLInputElement | null>(null)
const displayValue = ref(props.modelValue)

/** Sync displayValue whenever modelValue changes externally (e.g., clear from parent) */
watch(() => props.modelValue, (newVal) => {
  displayValue.value = newVal
})

// ---- Debounced emit via shared composable ----
const { exec: scheduleEmit, cancel: cancelEmit } = useDebounce(
  (value: string) => emit('update:modelValue', value),
  props.debounceMs
)

// ---- Event handlers ----
function onInput(event: Event) {
  const target = event.target as HTMLInputElement
  displayValue.value = target.value
  scheduleEmit(target.value)
}

function onClear() {
  displayValue.value = ''
  cancelEmit()
  emit('update:modelValue', '')
  inputRef.value?.focus()
}

function onSelect(event: Event) {
  const target = event.target as HTMLSelectElement
  emit('update:modelValue', target.value)
}

/** Normalize options: allow both FilterOption[] and string[] */
const normalizedOptions = computed(() => {
  return props.options.map(opt => {
    if (typeof opt === 'string') {
      return { value: opt, label: opt }
    }
    return opt
  })
})
</script>

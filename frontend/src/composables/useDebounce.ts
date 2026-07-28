import { onUnmounted } from 'vue'

/**
 * Creates a debounced version of a callback function.
 *
 * The callback is only invoked after `delay` milliseconds have passed
 * since the last call to `exec`. Useful for search inputs, resize handlers,
 * or any high-frequency event that should batch updates.
 *
 * @example
 * ```ts
 * const { exec: search, cancel } = useDebounce(
 *   (query: string) => api.search(query),
 *   300
 * )
 *
 * // Call as many times as needed; the API call only fires after 300ms of inactivity
 * search('hello')
 * search('hello world')
 *
 * // Cancel a pending execution
 * cancel()
 * ```
 */
export function useDebounce<T extends (...args: any[]) => void>(
  fn: T,
  delay: number = 300
): {
  /** Invoke the debounced function */
  exec: (...args: Parameters<T>) => void
  /** Cancel any pending execution */
  cancel: () => void
  /** Execute immediately with the given arguments, cancelling any pending execution */
  flush: (...args: Parameters<T>) => void
} {
  let timer: ReturnType<typeof setTimeout> | null = null

  function clear() {
    if (timer !== null) {
      clearTimeout(timer)
      timer = null
    }
  }

  function exec(...args: Parameters<T>) {
    clear()
    if (delay > 0) {
      timer = setTimeout(() => {
        timer = null
        fn(...args)
      }, delay)
    } else {
      fn(...args)
    }
  }

  function flush(...args: Parameters<T>) {
    clear()
    fn(...args)
  }

  onUnmounted(clear)

  return { exec, cancel: clear, flush }
}

export function formatarCpfCnpj(val: string | undefined | null): string {
  if (!val) return ''
  const clean = val.replace(/\D/g, '').substring(0, 14)
  if (clean.length <= 11) {
    if (clean.length <= 3) return clean
    if (clean.length <= 6) return `${clean.substring(0, 3)}.${clean.substring(3)}`
    if (clean.length <= 9) return `${clean.substring(0, 3)}.${clean.substring(3, 6)}.${clean.substring(6)}`
    return `${clean.substring(0, 3)}.${clean.substring(3, 6)}.${clean.substring(6, 9)}-${clean.substring(9)}`
  } else {
    if (clean.length <= 12) {
      return `${clean.substring(0, 2)}.${clean.substring(2, 5)}.${clean.substring(5, 8)}/${clean.substring(8)}`
    }
    return `${clean.substring(0, 2)}.${clean.substring(2, 5)}.${clean.substring(5, 8)}/${clean.substring(8, 12)}-${clean.substring(12)}`
  }
}

export function formatarCNPJ(val: string | undefined | null): string {
  if (!val) return ''
  const clean = val.replace(/\D/g, '').substring(0, 14)
  if (clean.length <= 2) return clean
  if (clean.length <= 5) return `${clean.substring(0, 2)}.${clean.substring(2)}`
  if (clean.length <= 8) return `${clean.substring(0, 2)}.${clean.substring(2, 5)}.${clean.substring(5)}`
  if (clean.length <= 12) return `${clean.substring(0, 2)}.${clean.substring(2, 5)}.${clean.substring(5, 8)}/${clean.substring(8)}`
  return `${clean.substring(0, 2)}.${clean.substring(2, 5)}.${clean.substring(5, 8)}/${clean.substring(8, 12)}-${clean.substring(12)}`
}

export function formatarTelefone(val: string | undefined | null): string {
  if (!val) return ''
  const clean = val.replace(/\D/g, '').substring(0, 11)
  if (!clean) return ''
  if (clean.length <= 2) {
    return `(${clean}`
  }
  if (clean.length <= 6) {
    return `(${clean.substring(0, 2)}) ${clean.substring(2)}`
  }
  if (clean.length <= 10) {
    return `(${clean.substring(0, 2)}) ${clean.substring(2, 6)}-${clean.substring(6)}`
  }
  return `(${clean.substring(0, 2)}) ${clean.substring(2, 7)}-${clean.substring(7)}`
}

export function formatarMoeda(value: number | string | undefined | null): string {
  if (value === undefined || value === null || value === '') return ''
  const cleanValue = String(value).replace(/\D/g, '')
  if (!cleanValue) return ''
  const numberValue = parseFloat(cleanValue) / 100
  return new Intl.NumberFormat('pt-BR', {
    style: 'currency',
    currency: 'BRL'
  }).format(numberValue)
}

export function formatarArea(val: string | number | undefined | null): string {
  if (val === undefined || val === null || val === '') return ''
  const clean = String(val).replace(/\D/g, '')
  if (!clean) return ''
  return new Intl.NumberFormat('pt-BR').format(parseInt(clean))
}

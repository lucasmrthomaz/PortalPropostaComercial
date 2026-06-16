export interface CampoTipoProposta {
  nome: string;
  chave: string;
  tipo: 'text' | 'number' | 'boolean';
  obrigatorio: boolean;
}

export interface TipoProposta {
  id?: string;
  nome: string;
  chave: string;
  campos: CampoTipoProposta[];
  created_at?: string;
  updated_at?: string;
}

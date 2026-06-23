export type ProposalType = string;

export type ProposalStatus = 'Pendente' | 'Aprovada' | 'Recusada' | 'Em Analise';

export interface Proposta {
  id?: string;
  cliente_id: string;
  tipo: ProposalType;
  valor: number;
  status: ProposalStatus;
  descricao?: string;
  dados_especificos: any; // Detalhes específicos de cada tipo
  created_at?: string;
  updated_at?: string;
}

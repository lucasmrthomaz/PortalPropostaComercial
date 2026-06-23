export interface Perfil {
  id?: string;
  nome: string;
  descricao?: string;
  permissoes?: string[] | string; // backend stores as JSON, parsed as string[]
  is_sistema?: boolean;
  created_at?: string;
  updated_at?: string;
}

export interface Usuario {
  id?: string;
  nome: string;
  email: string;
  senha?: string;
  perfil_id: string;
  perfil?: Perfil;
  ativo: boolean;
  created_at?: string;
  updated_at?: string;
}

export interface LoginRequest {
  email: string;
  senha: string;
}

export interface Cliente {
  id?: string;
  nome: string;
  cpf_cnpj: string;
  email: string;
  telefone?: string;
  endereco?: string;
  created_at?: string;
  updated_at?: string;
  propostas?: Proposta[];
}

export interface Empresa {
  id?: string;
  nome: string;
  cnpj: string;
  email: string;
  telefone?: string;
  responsavel_nome?: string;
  responsavel_email?: string;
  responsavel_telefone?: string;
  ativo?: boolean;
  created_at?: string;
  updated_at?: string;
}

export type ProposalType = string;

export type ProposalStatus = 'Pendente' | 'Aprovada' | 'Recusada' | 'Em Analise';

export interface Proposta {
  id?: string;
  cliente_id: string;
  tipo: ProposalType;
  valor: number;
  status: ProposalStatus;
  descricao?: string;
  empresa_id?: string;
  valor_comissao?: number;
  dados_especificos: any; // Detalhes específicos de cada tipo (JSON string or object)
  created_at?: string;
  updated_at?: string;
}

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
  campos: CampoTipoProposta[] | string;
  created_at?: string;
  updated_at?: string;
}

export interface Settings {
  taxa_corretagem: number;
  senha_supervisor?: string;
}

export interface DashboardStats {
  total_clients: number;
  total_proposals: number;
  total_companies: number;
  total_value: number;
  closed_commissions_value: number;
  pending_commissions_value: number;
  proposals_by_status: { [key: string]: number };
  proposals_by_type: { [key: string]: number };
  value_by_status: { [key: string]: number };
  value_by_type: { [key: string]: number };
}

export interface PedidoAnalise {
  id?: string;
  tipo_acao: 'DeletarCliente' | 'AprovarProposta' | 'EncaminharEmpresa' | 'DeletarProposta';
  entidade_id: string;
  entidade_tipo: 'Cliente' | 'Proposta' | 'Empresa';
  descricao?: string;
  status?: 'Pendente' | 'Aprovado' | 'Recusado';
  solicitado_por?: string;
  dados_acao: string; // JSON String
  created_at?: string;
  updated_at?: string;
}

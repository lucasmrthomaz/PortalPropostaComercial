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

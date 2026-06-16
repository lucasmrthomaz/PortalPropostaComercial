import { Proposta } from './proposal.model';

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

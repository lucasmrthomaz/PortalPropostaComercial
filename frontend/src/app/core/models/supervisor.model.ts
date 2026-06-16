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

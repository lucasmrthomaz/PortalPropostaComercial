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
  senha?: string; // only for create/update; never returned by API
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

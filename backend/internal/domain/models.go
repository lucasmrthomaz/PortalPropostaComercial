package domain

import (
	"database/sql/driver"
	"errors"
	"time"
)

type ProposalType string

const (
	ProposalTypeImobiliaria ProposalType = "Imobiliaria"
	ProposalTypeAuto        ProposalType = "Auto"
	ProposalTypeCompraVenda  ProposalType = "CompraVenda"
)

type ProposalStatus string

const (
	ProposalStatusPendente  ProposalStatus = "Pendente"
	ProposalStatusAprovada  ProposalStatus = "Aprovada"
	ProposalStatusRecusada  ProposalStatus = "Recusada"
	ProposalStatusEmAnalise ProposalStatus = "Em Analise"
)

// JSONB is a custom type for storing JSON in SQLite
type JSONB []byte

func (j JSONB) Value() (driver.Value, error) {
	if len(j) == 0 {
		return "{}", nil
	}
	return string(j), nil
}

func (j *JSONB) Scan(value interface{}) error {
	if value == nil {
		*j = nil
		return nil
	}
	s, ok := value.(string)
	if !ok {
		b, ok := value.([]byte)
		if !ok {
			return errors.New("invalid scan source for JSONB")
		}
		*j = b
		return nil
	}
	*j = []byte(s)
	return nil
}

func (j JSONB) MarshalJSON() ([]byte, error) {
	if len(j) == 0 {
		return []byte("{}"), nil
	}
	return j, nil
}

func (j *JSONB) UnmarshalJSON(b []byte) error {
	*j = append((*j)[0:0], b...)
	return nil
}

type Cliente struct {
	ID        string     `json:"id" gorm:"primaryKey"`
	Nome      string     `json:"nome" gorm:"not null"`
	CPFCNPJ   string     `json:"cpf_cnpj" gorm:"uniqueIndex;not null;column:cpf_cnpj"`
	Email     string     `json:"email" gorm:"not null"`
	Telefone  string     `json:"telefone"`
	Endereco  string     `json:"endereco"`
	CreatedAt time.Time  `json:"created_at"`
	UpdatedAt time.Time  `json:"updated_at"`
	Propostas []Proposta `json:"propostas,omitempty" gorm:"foreignKey:ClienteID;constraint:OnDelete:CASCADE"`
}

type Proposta struct {
	ID               string         `json:"id" gorm:"primaryKey"`
	ClienteID        string         `json:"cliente_id" gorm:"not null;index"`
	Tipo             ProposalType   `json:"tipo" gorm:"not null"`
	Valor            float64        `json:"valor" gorm:"not null"`
	Status           ProposalStatus `json:"status" gorm:"not null;default:'Pendente'"`
	Descricao        string         `json:"descricao"`
	DadosEspecificos JSONB          `json:"dados_especificos" gorm:"type:text"`
	
	EmpresaID        *string        `json:"empresa_id" gorm:"index"`
	Empresa          *Empresa       `json:"empresa,omitempty" gorm:"foreignKey:EmpresaID"`
	StatusCorretagem string         `json:"status_corretagem" gorm:"default:'Pendente'"`
	ValorComissao    float64        `json:"valor_comissao" gorm:"default:0"`
	
	CreatedAt        time.Time      `json:"created_at"`
	UpdatedAt        time.Time      `json:"updated_at"`
}

type Empresa struct {
	ID                  string    `json:"id" gorm:"primaryKey"`
	Nome                string    `json:"nome" gorm:"not null"`
	CNPJ                string    `json:"cnpj" gorm:"uniqueIndex;not null"`
	Email               string    `json:"email" gorm:"not null"`
	Telefone            string    `json:"telefone"`
	ResponsavelNome     string    `json:"responsavel_nome"`
	ResponsavelEmail    string    `json:"responsavel_email"`
	ResponsavelTelefone string    `json:"responsavel_telefone"`
	Ativo               bool      `json:"ativo" gorm:"default:true"`
	CreatedAt           time.Time `json:"created_at"`
	UpdatedAt           time.Time `json:"updated_at"`
}

type Configuracao struct {
	Chave string `json:"chave" gorm:"primaryKey"`
	Valor string `json:"valor" gorm:"not null"`
}

type CampoTipoProposta struct {
	Nome        string `json:"nome"`
	Chave       string `json:"chave"`
	Tipo        string `json:"tipo"` // "text", "number", "boolean"
	Obrigatorio bool   `json:"obrigatorio"`
}

type TipoProposta struct {
	ID        string    `json:"id" gorm:"primaryKey"`
	Nome      string    `json:"nome" gorm:"uniqueIndex;not null"`
	Chave     string    `json:"chave" gorm:"uniqueIndex;not null"`
	Campos    JSONB     `json:"campos" gorm:"type:text"` // JSON serializado de []CampoTipoProposta
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
}

type PedidoAnalise struct {
	ID            string    `json:"id" gorm:"primaryKey"`
	TipoAcao      string    `json:"tipo_acao" gorm:"not null"`
	EntidadeID    string    `json:"entidade_id" gorm:"not null"`
	EntidadeTipo  string    `json:"entidade_tipo" gorm:"not null"`
	Descricao     string    `json:"descricao"`
	Status        string    `json:"status" gorm:"default:'Pendente'"`
	SolicitadoPor string    `json:"solicitado_por"`
	DadosAcao     string    `json:"dados_acao"`
	CreatedAt     time.Time `json:"created_at"`
	UpdatedAt     time.Time `json:"updated_at"`
}

// Interfaces de Repositório
type ClienteRepository interface {
	Create(cliente *Cliente) error
	GetByID(id string) (*Cliente, error)
	GetByCPFCNPJ(cpfCnpj string) (*Cliente, error)
	Update(cliente *Cliente) error
	Delete(id string) error
	List() ([]Cliente, error)
}

type PropostaRepository interface {
	Create(proposta *Proposta) error
	GetByID(id string) (*Proposta, error)
	Update(proposta *Proposta) error
	Delete(id string) error
	ListByClienteID(clienteID string) ([]Proposta, error)
	List() ([]Proposta, error)
	CountByTipo(tipo string) (int64, error)
}

type EmpresaRepository interface {
	Create(empresa *Empresa) error
	GetByID(id string) (*Empresa, error)
	GetByCNPJ(cnpj string) (*Empresa, error)
	Update(empresa *Empresa) error
	Delete(id string) error
	List() ([]Empresa, error)
}

type ConfiguracaoRepository interface {
	Get(chave string) (string, error)
	Set(chave string, valor string) error
}

type TipoPropostaRepository interface {
	Create(tipo *TipoProposta) error
	GetByID(id string) (*TipoProposta, error)
	GetByChave(chave string) (*TipoProposta, error)
	Update(tipo *TipoProposta) error
	Delete(id string) error
	List() ([]TipoProposta, error)
}

type PedidoAnaliseRepository interface {
	Create(pedido *PedidoAnalise) error
	GetByID(id string) (*PedidoAnalise, error)
	Update(pedido *PedidoAnalise) error
	Delete(id string) error
	List() ([]PedidoAnalise, error)
	ListPendentes() ([]PedidoAnalise, error)
}

// Erros de Domínio
var (
	ErrClientNotFound          = errors.New("cliente não encontrado")
	ErrProposalNotFound        = errors.New("proposta não encontrada")
	ErrCompanyNotFound         = errors.New("empresa parceira não encontrada")
	ErrSettingNotFound         = errors.New("configuração não encontrada")
	ErrAnalysisRequestNotFound = errors.New("pedido de análise não encontrado")
	ErrInvalidCPFCNPJ          = errors.New("CPF ou CNPJ inválido")
	ErrInvalidCNPJ             = errors.New("CNPJ inválido")
	ErrClientAlreadyExists     = errors.New("cliente com este CPF/CNPJ já cadastrado")
	ErrCompanyAlreadyExists    = errors.New("empresa com este CNPJ já cadastrada")
	ErrInvalidClientName       = errors.New("nome do cliente é obrigatório")
	ErrInvalidClientEmail      = errors.New("email do cliente é obrigatório ou inválido")
	ErrInvalidCompanyName      = errors.New("nome da empresa é obrigatório")
	ErrInvalidCompanyEmail     = errors.New("email da empresa é obrigatório ou inválido")
	ErrInvalidProposalType     = errors.New("tipo de proposta inválido (use Imobiliaria, Auto ou CompraVenda)")
	ErrInvalidProposalVal      = errors.New("valor da proposta deve ser maior que zero")
	ErrSupervisorAuthFailed    = errors.New("senha do supervisor incorreta")
	ErrSupervisorActionDone    = errors.New("este pedido de análise já foi processado")
	ErrUserNotFound            = errors.New("usuário não encontrado")
	ErrUserAlreadyExists       = errors.New("já existe um usuário com este email")
	ErrInvalidUserEmail        = errors.New("email do usuário é obrigatório ou inválido")
	ErrInvalidUserName         = errors.New("nome do usuário é obrigatório")
	ErrInvalidCredentials      = errors.New("email ou senha inválidos")
	ErrPerfilNotFound          = errors.New("perfil de acesso não encontrado")
	ErrPerfilAlreadyExists     = errors.New("já existe um perfil com este nome")
	ErrInvalidPerfilName       = errors.New("nome do perfil é obrigatório")
	ErrCannotDeleteSystemPerfil = errors.New("não é permitido excluir perfis do sistema")
	ErrCannotDeleteLastAdmin   = errors.New("não é possível excluir o último usuário super admin")
)

// ==========================================
// PERFIL (ACCESS PROFILE / ROLE)
// ==========================================
type Perfil struct {
	ID          string    `json:"id" gorm:"primaryKey"`
	Nome        string    `json:"nome" gorm:"uniqueIndex;not null"`
	Descricao   string    `json:"descricao"`
	Permissoes  JSONB     `json:"permissoes" gorm:"type:text"` // JSON: []string of permission keys
	IsSistema   bool      `json:"is_sistema" gorm:"default:false"` // true = system profile (cannot be deleted)
	CreatedAt   time.Time `json:"created_at"`
	UpdatedAt   time.Time `json:"updated_at"`
}

// ==========================================
// USUARIO (USER)
// ==========================================
type Usuario struct {
	ID        string    `json:"id" gorm:"primaryKey"`
	Nome      string    `json:"nome" gorm:"not null"`
	Email     string    `json:"email" gorm:"uniqueIndex;not null"`
	SenhaHash string    `json:"-" gorm:"not null;column:senha_hash"` // never exposed via JSON
	PerfilID  string    `json:"perfil_id" gorm:"not null;index"`
	Perfil    *Perfil   `json:"perfil,omitempty" gorm:"foreignKey:PerfilID"`
	Ativo     bool      `json:"ativo" gorm:"default:true"`
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
}

// UsuarioResponse is the safe DTO returned by the API (no senha_hash)
type UsuarioResponse struct {
	ID        string    `json:"id"`
	Nome      string    `json:"nome"`
	Email     string    `json:"email"`
	PerfilID  string    `json:"perfil_id"`
	Perfil    *Perfil   `json:"perfil,omitempty"`
	Ativo     bool      `json:"ativo"`
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
}

func (u *Usuario) ToResponse() UsuarioResponse {
	return UsuarioResponse{
		ID:        u.ID,
		Nome:      u.Nome,
		Email:     u.Email,
		PerfilID:  u.PerfilID,
		Perfil:    u.Perfil,
		Ativo:     u.Ativo,
		CreatedAt: u.CreatedAt,
		UpdatedAt: u.UpdatedAt,
	}
}

// ==========================================
// REPOSITORY INTERFACES
// ==========================================
type PerfilRepository interface {
	Create(perfil *Perfil) error
	GetByID(id string) (*Perfil, error)
	GetByNome(nome string) (*Perfil, error)
	Update(perfil *Perfil) error
	Delete(id string) error
	List() ([]Perfil, error)
}

type UsuarioRepository interface {
	Create(usuario *Usuario) error
	GetByID(id string) (*Usuario, error)
	GetByEmail(email string) (*Usuario, error)
	Update(usuario *Usuario) error
	Delete(id string) error
	List() ([]Usuario, error)
	CountByPerfilID(perfilID string) (int64, error)
	CountSuperAdmins() (int64, error)
}


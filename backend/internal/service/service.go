package service

import (
	"cadastro-cliente-proposta/backend/internal/domain"
	"crypto/sha256"
	"encoding/json"
	"errors"
	"fmt"
	"math"
	"regexp"
	"strconv"
	"strings"
	"time"

	"github.com/google/uuid"
)

// ==========================================
// CLIENTE SERVICE
// ==========================================
type ClienteService struct {
	repo domain.ClienteRepository
}

func NewClienteService(repo domain.ClienteRepository) *ClienteService {
	return &ClienteService{repo: repo}
}

func (s *ClienteService) Create(c *domain.Cliente) error {
	if strings.TrimSpace(c.Nome) == "" {
		return domain.ErrInvalidClientName
	}
	if !strings.Contains(c.Email, "@") || strings.TrimSpace(c.Email) == "" {
		return domain.ErrInvalidClientEmail
	}

	c.CPFCNPJ = domain.CleanCPFCNPJ(c.CPFCNPJ)
	if !domain.IsValidCPFCNPJ(c.CPFCNPJ) {
		return domain.ErrInvalidCPFCNPJ
	}

	existing, err := s.repo.GetByCPFCNPJ(c.CPFCNPJ)
	if err == nil && existing != nil {
		return domain.ErrClientAlreadyExists
	}

	c.ID = uuid.New().String()
	c.CreatedAt = time.Now()
	c.UpdatedAt = time.Now()

	return s.repo.Create(c)
}

func (s *ClienteService) GetByID(id string) (*domain.Cliente, error) {
	c, err := s.repo.GetByID(id)
	if err != nil {
		return nil, domain.ErrClientNotFound
	}
	return c, nil
}

func (s *ClienteService) Update(id string, input *domain.Cliente) (*domain.Cliente, error) {
	c, err := s.repo.GetByID(id)
	if err != nil {
		return nil, domain.ErrClientNotFound
	}

	if strings.TrimSpace(input.Nome) == "" {
		return nil, domain.ErrInvalidClientName
	}
	if !strings.Contains(input.Email, "@") {
		return nil, domain.ErrInvalidClientEmail
	}

	cleanCPF := domain.CleanCPFCNPJ(input.CPFCNPJ)
	if cleanCPF != c.CPFCNPJ {
		if !domain.IsValidCPFCNPJ(cleanCPF) {
			return nil, domain.ErrInvalidCPFCNPJ
		}
		existing, err := s.repo.GetByCPFCNPJ(cleanCPF)
		if err == nil && existing != nil && existing.ID != c.ID {
			return nil, domain.ErrClientAlreadyExists
		}
		c.CPFCNPJ = cleanCPF
	}

	c.Nome = input.Nome
	c.Email = input.Email
	c.Telefone = input.Telefone
	c.Endereco = input.Endereco
	c.UpdatedAt = time.Now()

	err = s.repo.Update(c)
	if err != nil {
		return nil, err
	}
	return c, nil
}

func (s *ClienteService) Delete(id string) error {
	_, err := s.repo.GetByID(id)
	if err != nil {
		return domain.ErrClientNotFound
	}
	return s.repo.Delete(id)
}

func (s *ClienteService) List() ([]domain.Cliente, error) {
	return s.repo.List()
}

// ==========================================
// CONFIGURACAO SERVICE
// ==========================================
type ConfiguracaoService struct {
	repo domain.ConfiguracaoRepository
}

func NewConfiguracaoService(repo domain.ConfiguracaoRepository) *ConfiguracaoService {
	return &ConfiguracaoService{repo: repo}
}

func (s *ConfiguracaoService) GetCommissionRate() (float64, error) {
	val, err := s.repo.Get("taxa_corretagem")
	if err != nil {
		return 5.0, nil
	}
	rate, err := strconv.ParseFloat(val, 64)
	if err != nil {
		return 5.0, nil
	}
	return rate, nil
}

func (s *ConfiguracaoService) UpdateCommissionRate(rate float64) error {
	if rate < 0 || rate > 100 {
		return errors.New("taxa de corretagem inválida (deve ser entre 0% e 100%)")
	}
	val := strconv.FormatFloat(rate, 'f', 2, 64)
	return s.repo.Set("taxa_corretagem", val)
}

func (s *ConfiguracaoService) VerifySupervisorPassword(inputPassword string) error {
	pwd, err := s.repo.Get("senha_supervisor")
	if err != nil {
		if inputPassword == "admin123" {
			return nil
		}
		return domain.ErrSupervisorAuthFailed
	}
	if pwd != inputPassword {
		return domain.ErrSupervisorAuthFailed
	}
	return nil
}

func (s *ConfiguracaoService) UpdateSupervisorPassword(newPassword string) error {
	if len(strings.TrimSpace(newPassword)) < 4 {
		return errors.New("a senha do supervisor deve ter no mínimo 4 caracteres")
	}
	return s.repo.Set("senha_supervisor", newPassword)
}

// ==========================================
// EMPRESA SERVICE
// ==========================================
type EmpresaService struct {
	repo domain.EmpresaRepository
}

func NewEmpresaService(repo domain.EmpresaRepository) *EmpresaService {
	return &EmpresaService{repo: repo}
}

func (s *EmpresaService) Create(e *domain.Empresa) error {
	if strings.TrimSpace(e.Nome) == "" {
		return domain.ErrInvalidCompanyName
	}
	if !strings.Contains(e.Email, "@") || strings.TrimSpace(e.Email) == "" {
		return domain.ErrInvalidCompanyEmail
	}

	e.CNPJ = domain.CleanCPFCNPJ(e.CNPJ)
	if !domain.IsValidCNPJ(e.CNPJ) {
		return domain.ErrInvalidCNPJ
	}

	existing, err := s.repo.GetByCNPJ(e.CNPJ)
	if err == nil && existing != nil {
		return domain.ErrCompanyAlreadyExists
	}

	e.ID = uuid.New().String()
	e.Ativo = true
	e.CreatedAt = time.Now()
	e.UpdatedAt = time.Now()

	return s.repo.Create(e)
}

func (s *EmpresaService) GetByID(id string) (*domain.Empresa, error) {
	e, err := s.repo.GetByID(id)
	if err != nil {
		return nil, domain.ErrCompanyNotFound
	}
	return e, nil
}

func (s *EmpresaService) Update(id string, input *domain.Empresa) (*domain.Empresa, error) {
	e, err := s.repo.GetByID(id)
	if err != nil {
		return nil, domain.ErrCompanyNotFound
	}

	if strings.TrimSpace(input.Nome) == "" {
		return nil, domain.ErrInvalidCompanyName
	}
	if !strings.Contains(input.Email, "@") {
		return nil, domain.ErrInvalidCompanyEmail
	}

	cleanCNPJ := domain.CleanCPFCNPJ(input.CNPJ)
	if cleanCNPJ != e.CNPJ {
		if !domain.IsValidCNPJ(cleanCNPJ) {
			return nil, domain.ErrInvalidCNPJ
		}
		existing, err := s.repo.GetByCNPJ(cleanCNPJ)
		if err == nil && existing != nil && existing.ID != e.ID {
			return nil, domain.ErrCompanyAlreadyExists
		}
		e.CNPJ = cleanCNPJ
	}

	e.Nome = input.Nome
	e.Email = input.Email
	e.Telefone = input.Telefone
	e.ResponsavelNome = input.ResponsavelNome
	e.ResponsavelEmail = input.ResponsavelEmail
	e.ResponsavelTelefone = input.ResponsavelTelefone
	e.Ativo = input.Ativo
	e.UpdatedAt = time.Now()

	err = s.repo.Update(e)
	if err != nil {
		return nil, err
	}
	return e, nil
}

func (s *EmpresaService) Delete(id string) error {
	_, err := s.repo.GetByID(id)
	if err != nil {
		return domain.ErrCompanyNotFound
	}
	return s.repo.Delete(id)
}

func (s *EmpresaService) List() ([]domain.Empresa, error) {
	return s.repo.List()
}

// ==========================================
// PROPOSTA SERVICE
// ==========================================
type PropostaService struct {
	repo             domain.PropostaRepository
	clientRepo       domain.ClienteRepository
	configRepo       domain.ConfiguracaoRepository
	tipoPropostaRepo domain.TipoPropostaRepository
}

func NewPropostaService(
	repo domain.PropostaRepository,
	clientRepo domain.ClienteRepository,
	configRepo domain.ConfiguracaoRepository,
	tipoPropostaRepo domain.TipoPropostaRepository,
) *PropostaService {
	return &PropostaService{
		repo:             repo,
		clientRepo:       clientRepo,
		configRepo:       configRepo,
		tipoPropostaRepo: tipoPropostaRepo,
	}
}

func (s *PropostaService) Create(p *domain.Proposta) error {
	_, err := s.clientRepo.GetByID(p.ClienteID)
	if err != nil {
		return domain.ErrClientNotFound
	}

	tipoProposta, err := s.tipoPropostaRepo.GetByChave(string(p.Tipo))
	if err != nil || tipoProposta == nil {
		return domain.ErrInvalidProposalType
	}

	if p.Valor <= 0 {
		return domain.ErrInvalidProposalVal
	}

	if err := s.validateDynamicFields(tipoProposta, p.DadosEspecificos); err != nil {
		return err
	}

	p.ID = uuid.New().String()
	if p.Status == "" {
		p.Status = domain.ProposalStatusPendente
	}

	s.handleBrokerageCommission(p)

	p.CreatedAt = time.Now()
	p.UpdatedAt = time.Now()

	return s.repo.Create(p)
}

func (s *PropostaService) GetByID(id string) (*domain.Proposta, error) {
	p, err := s.repo.GetByID(id)
	if err != nil {
		return nil, domain.ErrProposalNotFound
	}
	return p, nil
}

func (s *PropostaService) Update(id string, input *domain.Proposta) (*domain.Proposta, error) {
	p, err := s.repo.GetByID(id)
	if err != nil {
		return nil, domain.ErrProposalNotFound
	}

	if input.Tipo != "" {
		tipoProposta, err := s.tipoPropostaRepo.GetByChave(string(input.Tipo))
		if err != nil || tipoProposta == nil {
			return nil, domain.ErrInvalidProposalType
		}
		if err := s.validateDynamicFields(tipoProposta, input.DadosEspecificos); err != nil {
			return nil, err
		}
		p.Tipo = input.Tipo
	}

	if input.Valor <= 0 {
		return nil, domain.ErrInvalidProposalVal
	}

	p.Valor = input.Valor
	p.Status = input.Status
	p.Descricao = input.Descricao
	p.DadosEspecificos = input.DadosEspecificos

	p.EmpresaID = input.EmpresaID
	p.StatusCorretagem = input.StatusCorretagem

	s.handleBrokerageCommission(p)

	p.UpdatedAt = time.Now()

	err = s.repo.Update(p)
	if err != nil {
		return nil, err
	}
	return p, nil
}

func (s *PropostaService) validateDynamicFields(tipo *domain.TipoProposta, dadosEspecificos domain.JSONB) error {
	if tipo.Chave == "Imobiliaria" || tipo.Chave == "Auto" || tipo.Chave == "Comissionados" {
		return nil
	}

	if len(dadosEspecificos) == 0 {
		var campos []domain.CampoTipoProposta
		if err := json.Unmarshal(tipo.Campos, &campos); err == nil {
			for _, campo := range campos {
				if campo.Obrigatorio {
					return fmt.Errorf("o campo '%s' é obrigatório", campo.Nome)
				}
			}
		}
		return nil
	}

	var data map[string]interface{}
	if err := json.Unmarshal(dadosEspecificos, &data); err != nil {
		return errors.New("formato de dados específicos inválido")
	}

	var campos []domain.CampoTipoProposta
	if err := json.Unmarshal(tipo.Campos, &campos); err != nil {
		return errors.New("erro ao ler a definição dos campos do tipo de proposta")
	}

	for _, campo := range campos {
		val, exists := data[campo.Chave]

		if campo.Obrigatorio {
			if !exists || val == nil {
				return fmt.Errorf("o campo '%s' é obrigatório", campo.Nome)
			}
			if strVal, ok := val.(string); ok && strings.TrimSpace(strVal) == "" {
				return fmt.Errorf("o campo '%s' é obrigatório", campo.Nome)
			}
		}

		if exists && val != nil {
			switch campo.Tipo {
			case "number":
				_, okFloat := val.(float64)
				_, okInt := val.(int)
				if !okFloat && !okInt {
					if strVal, ok := val.(string); ok {
						if _, err := strconv.ParseFloat(strVal, 64); err != nil {
							return fmt.Errorf("o campo '%s' deve ser um número", campo.Nome)
						}
					} else {
						return fmt.Errorf("o campo '%s' deve ser um número", campo.Nome)
					}
				}
			case "boolean":
				_, okBool := val.(bool)
				if !okBool {
					if strVal, ok := val.(string); ok {
						if strVal != "true" && strVal != "false" {
							return fmt.Errorf("o campo '%s' deve ser verdadeiro ou falso", campo.Nome)
						}
					} else {
						return fmt.Errorf("o campo '%s' deve ser verdadeiro ou falso", campo.Nome)
					}
				}
			}
		}
	}

	return nil
}

func (s *PropostaService) Delete(id string) error {
	_, err := s.repo.GetByID(id)
	if err != nil {
		return domain.ErrProposalNotFound
	}
	return s.repo.Delete(id)
}

func (s *PropostaService) ListByClienteID(clienteID string) ([]domain.Proposta, error) {
	_, err := s.clientRepo.GetByID(clienteID)
	if err != nil {
		return nil, domain.ErrClientNotFound
	}
	return s.repo.ListByClienteID(clienteID)
}

func (s *PropostaService) List() ([]domain.Proposta, error) {
	return s.repo.List()
}

func (s *PropostaService) handleBrokerageCommission(p *domain.Proposta) {
	if p.EmpresaID != nil && (p.StatusCorretagem == "FechadaComSucesso" || p.Status == domain.ProposalStatusAprovada) {
		p.StatusCorretagem = "FechadaComSucesso"

		taxaStr, err := s.configRepo.Get("taxa_corretagem")
		taxa := 5.0
		if err == nil {
			if t, err := strconv.ParseFloat(taxaStr, 64); err == nil {
				taxa = t
			}
		}

		p.ValorComissao = math.Round((p.Valor*(taxa/100))*100) / 100
	} else if p.EmpresaID != nil {
		p.StatusCorretagem = "Encaminhada"
		p.ValorComissao = 0
	} else {
		p.StatusCorretagem = "Pendente"
		p.ValorComissao = 0
	}
}

// ==========================================
// SUPERVISOR SERVICE (PEDIDOS DE ANÁLISE)
// ==========================================
type SupervisorService struct {
	repo            domain.PedidoAnaliseRepository
	clienteService  *ClienteService
	propostaService *PropostaService
	empresaService  *EmpresaService
	configRepo      domain.ConfiguracaoRepository
}

func NewSupervisorService(
	repo domain.PedidoAnaliseRepository,
	cs *ClienteService,
	ps *PropostaService,
	es *EmpresaService,
	configRepo domain.ConfiguracaoRepository,
) *SupervisorService {
	return &SupervisorService{
		repo:            repo,
		clienteService:  cs,
		propostaService: ps,
		empresaService:  es,
		configRepo:      configRepo,
	}
}

func (s *SupervisorService) CreateRequest(p *domain.PedidoAnalise) error {
	p.ID = uuid.New().String()
	p.Status = "Pendente"
	p.CreatedAt = time.Now()
	p.UpdatedAt = time.Now()
	return s.repo.Create(p)
}

func (s *SupervisorService) ApproveRequest(id string) error {
	pedido, err := s.repo.GetByID(id)
	if err != nil {
		return domain.ErrAnalysisRequestNotFound
	}
	if pedido.Status != "Pendente" {
		return domain.ErrSupervisorActionDone
	}

	switch pedido.TipoAcao {
	case "AprovarProposta":
		var req struct {
			PropostaID string `json:"proposta_id"`
		}
		if err := json.Unmarshal([]byte(pedido.DadosAcao), &req); err != nil {
			return err
		}
		prop, err := s.propostaService.GetByID(req.PropostaID)
		if err != nil {
			return err
		}
		prop.Status = domain.ProposalStatusAprovada
		
		s.propostaService.handleBrokerageCommission(prop)

		if _, err := s.propostaService.Update(prop.ID, prop); err != nil {
			return err
		}

	case "EncaminharEmpresa":
		var req struct {
			PropostaID string `json:"proposta_id"`
			EmpresaID  string `json:"empresa_id"`
		}
		if err := json.Unmarshal([]byte(pedido.DadosAcao), &req); err != nil {
			return err
		}
		prop, err := s.propostaService.GetByID(req.PropostaID)
		if err != nil {
			return err
		}
		prop.EmpresaID = &req.EmpresaID
		prop.StatusCorretagem = "Encaminhada"
		
		s.propostaService.handleBrokerageCommission(prop)

		if _, err := s.propostaService.Update(prop.ID, prop); err != nil {
			return err
		}

	case "DeletarCliente":
		var req struct {
			ClienteID string `json:"cliente_id"`
		}
		if err := json.Unmarshal([]byte(pedido.DadosAcao), &req); err != nil {
			return err
		}
		if err := s.clienteService.Delete(req.ClienteID); err != nil {
			return err
		}

	case "DeletarProposta":
		var req struct {
			PropostaID string `json:"proposta_id"`
		}
		if err := json.Unmarshal([]byte(pedido.DadosAcao), &req); err != nil {
			return err
		}
		if err := s.propostaService.Delete(req.PropostaID); err != nil {
			return err
		}

	default:
		return errors.New("tipo de ação do supervisor não suportado")
	}

	pedido.Status = "Aprovado"
	pedido.UpdatedAt = time.Now()
	return s.repo.Update(pedido)
}

func (s *SupervisorService) RejectRequest(id string) error {
	pedido, err := s.repo.GetByID(id)
	if err != nil {
		return domain.ErrAnalysisRequestNotFound
	}
	if pedido.Status != "Pendente" {
		return domain.ErrSupervisorActionDone
	}

	pedido.Status = "Recusado"
	pedido.UpdatedAt = time.Now()
	return s.repo.Update(pedido)
}

func (s *SupervisorService) ListAll() ([]domain.PedidoAnalise, error) {
	return s.repo.List()
}

func (s *SupervisorService) ListPendentes() ([]domain.PedidoAnalise, error) {
	return s.repo.ListPendentes()
}

// ==========================================
// TIPO PROPOSTA SERVICE
// ==========================================
type TipoPropostaService struct {
	repo         domain.TipoPropostaRepository
	proposalRepo domain.PropostaRepository
}

func NewTipoPropostaService(repo domain.TipoPropostaRepository, proposalRepo domain.PropostaRepository) *TipoPropostaService {
	return &TipoPropostaService{
		repo:         repo,
		proposalRepo: proposalRepo,
	}
}

func (s *TipoPropostaService) Create(tipo *domain.TipoProposta) error {
	if strings.TrimSpace(tipo.Nome) == "" {
		return errors.New("o nome do tipo de proposta é obrigatório")
	}
	if strings.TrimSpace(tipo.Chave) == "" {
		return errors.New("a chave do tipo de proposta é obrigatória")
	}

	reg := regexp.MustCompile(`[^a-zA-Z0-9]`)
	tipo.Chave = reg.ReplaceAllString(tipo.Chave, "")
	if tipo.Chave == "" {
		return errors.New("a chave do tipo de proposta deve conter caracteres alfanuméricos")
	}

	existing, err := s.repo.GetByChave(tipo.Chave)
	if err == nil && existing != nil {
		return errors.New("já existe um tipo de proposta com esta chave")
	}

	tipo.ID = uuid.New().String()
	tipo.CreatedAt = time.Now()
	tipo.UpdatedAt = time.Now()

	return s.repo.Create(tipo)
}

func (s *TipoPropostaService) GetByID(id string) (*domain.TipoProposta, error) {
	tipo, err := s.repo.GetByID(id)
	if err != nil {
		return nil, errors.New("tipo de proposta não encontrado")
	}
	return tipo, nil
}

func (s *TipoPropostaService) Update(id string, input *domain.TipoProposta) (*domain.TipoProposta, error) {
	tipo, err := s.repo.GetByID(id)
	if err != nil {
		return nil, errors.New("tipo de proposta não encontrado")
	}

	if strings.TrimSpace(input.Nome) == "" {
		return nil, errors.New("o nome do tipo de proposta é obrigatório")
	}

	isLegacy := tipo.Chave == "Imobiliaria" || tipo.Chave == "Auto" || tipo.Chave == "Comissionados"

	if !isLegacy && strings.TrimSpace(input.Chave) != "" && input.Chave != tipo.Chave {
		reg := regexp.MustCompile(`[^a-zA-Z0-9]`)
		newChave := reg.ReplaceAllString(input.Chave, "")
		if newChave == "" {
			return nil, errors.New("a chave do tipo de proposta deve conter caracteres alfanuméricos")
		}

		existing, err := s.repo.GetByChave(newChave)
		if err == nil && existing != nil && existing.ID != tipo.ID {
			return nil, errors.New("já existe um tipo de proposta com esta chave")
		}
		tipo.Chave = newChave
	}

	tipo.Nome = input.Nome
	tipo.Campos = input.Campos
	tipo.UpdatedAt = time.Now()

	err = s.repo.Update(tipo)
	if err != nil {
		return nil, err
	}
	return tipo, nil
}

func (s *TipoPropostaService) Delete(id string) error {
	tipo, err := s.repo.GetByID(id)
	if err != nil {
		return errors.New("tipo de proposta não encontrado")
	}

	if tipo.Chave == "Imobiliaria" || tipo.Chave == "Auto" || tipo.Chave == "Comissionados" {
		return errors.New("não é permitido excluir tipos de proposta do sistema")
	}

	count, err := s.proposalRepo.CountByTipo(tipo.Chave)
	if err != nil {
		return err
	}
	if count > 0 {
		return fmt.Errorf("não é possível excluir este tipo de proposta pois existem %d proposta(s) associada(s) a ele", count)
	}

	return s.repo.Delete(id)
}

func (s *TipoPropostaService) List() ([]domain.TipoProposta, error) {
	return s.repo.List()
}

// ==========================================
// PERFIL SERVICE
// ==========================================
type PerfilService struct {
	repo        domain.PerfilRepository
	usuarioRepo domain.UsuarioRepository
}

func NewPerfilService(repo domain.PerfilRepository, usuarioRepo domain.UsuarioRepository) *PerfilService {
	return &PerfilService{repo: repo, usuarioRepo: usuarioRepo}
}

func (s *PerfilService) Create(p *domain.Perfil) error {
	if strings.TrimSpace(p.Nome) == "" {
		return domain.ErrInvalidPerfilName
	}
	existing, err := s.repo.GetByNome(p.Nome)
	if err == nil && existing != nil {
		return domain.ErrPerfilAlreadyExists
	}
	p.ID = uuid.New().String()
	p.CreatedAt = time.Now()
	p.UpdatedAt = time.Now()
	return s.repo.Create(p)
}

func (s *PerfilService) GetByID(id string) (*domain.Perfil, error) {
	p, err := s.repo.GetByID(id)
	if err != nil {
		return nil, domain.ErrPerfilNotFound
	}
	return p, nil
}

func (s *PerfilService) Update(id string, input *domain.Perfil) (*domain.Perfil, error) {
	p, err := s.repo.GetByID(id)
	if err != nil {
		return nil, domain.ErrPerfilNotFound
	}
	if strings.TrimSpace(input.Nome) == "" {
		return nil, domain.ErrInvalidPerfilName
	}
	if input.Nome != p.Nome {
		existing, err := s.repo.GetByNome(input.Nome)
		if err == nil && existing != nil && existing.ID != p.ID {
			return nil, domain.ErrPerfilAlreadyExists
		}
	}
	// Cannot rename system profile
	if !p.IsSistema {
		p.Nome = input.Nome
	}
	p.Descricao = input.Descricao
	p.Permissoes = input.Permissoes
	p.UpdatedAt = time.Now()
	err = s.repo.Update(p)
	if err != nil {
		return nil, err
	}
	return p, nil
}

func (s *PerfilService) Delete(id string) error {
	p, err := s.repo.GetByID(id)
	if err != nil {
		return domain.ErrPerfilNotFound
	}
	if p.IsSistema {
		return domain.ErrCannotDeleteSystemPerfil
	}
	count, err := s.usuarioRepo.CountByPerfilID(id)
	if err != nil {
		return err
	}
	if count > 0 {
		return fmt.Errorf("não é possível excluir este perfil pois existem %d usuário(s) associado(s) a ele", count)
	}
	return s.repo.Delete(id)
}

func (s *PerfilService) List() ([]domain.Perfil, error) {
	return s.repo.List()
}

// ==========================================
// USUARIO SERVICE
// ==========================================
type UsuarioService struct {
	repo      domain.UsuarioRepository
	perfilRepo domain.PerfilRepository
}

func NewUsuarioService(repo domain.UsuarioRepository, perfilRepo domain.PerfilRepository) *UsuarioService {
	return &UsuarioService{repo: repo, perfilRepo: perfilRepo}
}

func hashPassword(password string) string {
	// Simple SHA-256 hash for local zero-config auth
	// In production, use bcrypt; this is intentionally lightweight for this system
	hash := sha256.Sum256([]byte(password))
	return fmt.Sprintf("%x", hash)
}

func (s *UsuarioService) Create(u *domain.Usuario, senha string) error {
	if strings.TrimSpace(u.Nome) == "" {
		return domain.ErrInvalidUserName
	}
	if !strings.Contains(u.Email, "@") || strings.TrimSpace(u.Email) == "" {
		return domain.ErrInvalidUserEmail
	}
	_, err := s.perfilRepo.GetByID(u.PerfilID)
	if err != nil {
		return domain.ErrPerfilNotFound
	}
	existing, err := s.repo.GetByEmail(u.Email)
	if err == nil && existing != nil {
		return domain.ErrUserAlreadyExists
	}
	if strings.TrimSpace(senha) == "" {
		return errors.New("a senha é obrigatória")
	}
	u.ID = uuid.New().String()
	u.SenhaHash = hashPassword(senha)
	u.CreatedAt = time.Now()
	u.UpdatedAt = time.Now()
	return s.repo.Create(u)
}

func (s *UsuarioService) GetByID(id string) (*domain.Usuario, error) {
	u, err := s.repo.GetByID(id)
	if err != nil {
		return nil, domain.ErrUserNotFound
	}
	return u, nil
}

func (s *UsuarioService) Update(id string, input *domain.Usuario, novaSenha string) (*domain.Usuario, error) {
	u, err := s.repo.GetByID(id)
	if err != nil {
		return nil, domain.ErrUserNotFound
	}
	if strings.TrimSpace(input.Nome) == "" {
		return nil, domain.ErrInvalidUserName
	}
	if !strings.Contains(input.Email, "@") || strings.TrimSpace(input.Email) == "" {
		return nil, domain.ErrInvalidUserEmail
	}
	if input.Email != u.Email {
		existing, err := s.repo.GetByEmail(input.Email)
		if err == nil && existing != nil && existing.ID != u.ID {
			return nil, domain.ErrUserAlreadyExists
		}
	}
	if input.PerfilID != "" && input.PerfilID != u.PerfilID {
		_, err := s.perfilRepo.GetByID(input.PerfilID)
		if err != nil {
			return nil, domain.ErrPerfilNotFound
		}
		u.PerfilID = input.PerfilID
	}
	u.Nome = input.Nome
	u.Email = input.Email
	u.Ativo = input.Ativo
	if strings.TrimSpace(novaSenha) != "" {
		u.SenhaHash = hashPassword(novaSenha)
	}
	u.UpdatedAt = time.Now()
	err = s.repo.Update(u)
	if err != nil {
		return nil, err
	}
	return u, nil
}

func (s *UsuarioService) Delete(id string) error {
	u, err := s.repo.GetByID(id)
	if err != nil {
		return domain.ErrUserNotFound
	}
	// Prevent deleting last super admin
	if u.Perfil != nil && u.Perfil.Nome == "Super Admin" {
		count, err := s.repo.CountSuperAdmins()
		if err != nil {
			return err
		}
		if count <= 1 {
			return domain.ErrCannotDeleteLastAdmin
		}
	}
	return s.repo.Delete(id)
}

func (s *UsuarioService) List() ([]domain.Usuario, error) {
	return s.repo.List()
}

func (s *UsuarioService) Login(email, senha string) (*domain.Usuario, error) {
	u, err := s.repo.GetByEmail(email)
	if err != nil || u == nil {
		return nil, domain.ErrInvalidCredentials
	}
	if !u.Ativo {
		return nil, domain.ErrInvalidCredentials
	}
	if u.SenhaHash != hashPassword(senha) {
		return nil, domain.ErrInvalidCredentials
	}
	return u, nil
}


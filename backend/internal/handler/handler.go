package handler

import (
	"cadastro-cliente-proposta/backend/internal/domain"
	"cadastro-cliente-proposta/backend/internal/service"
	"encoding/json"
	"errors"
	"net/http"

	"github.com/go-chi/chi/v5"
)

type Handler struct {
	clientService       *service.ClienteService
	proposalService     *service.PropostaService
	companyService      *service.EmpresaService
	configService       *service.ConfiguracaoService
	supervisorService   *service.SupervisorService
	proposalTypeService *service.TipoPropostaService
	perfilService       *service.PerfilService
	usuarioService      *service.UsuarioService
}

func NewHandler(
	cs *service.ClienteService,
	ps *service.PropostaService,
	es *service.EmpresaService,
	cfgS *service.ConfiguracaoService,
	ss *service.SupervisorService,
	pts *service.TipoPropostaService,
	pfs *service.PerfilService,
	us *service.UsuarioService,
) *Handler {
	return &Handler{
		clientService:       cs,
		proposalService:     ps,
		companyService:      es,
		configService:       cfgS,
		supervisorService:   ss,
		proposalTypeService: pts,
		perfilService:       pfs,
		usuarioService:      us,
	}
}

func (h *Handler) Routes(r chi.Router) {
	r.Route("/api", func(r chi.Router) {
		// Clientes
		r.Route("/clients", func(r chi.Router) {
			r.Get("/", h.listClients)
			r.Post("/", h.createClient)
			r.Route("/{id}", func(r chi.Router) {
				r.Get("/", h.getClient)
				r.Put("/", h.updateClient)
				r.Delete("/", h.deleteClient)
				r.Get("/proposals", h.listClientProposals)
			})
		})

		// Propostas
		r.Route("/proposals", func(r chi.Router) {
			r.Get("/", h.listProposals)
			r.Post("/", h.createProposal)
			r.Route("/{id}", func(r chi.Router) {
				r.Get("/", h.getProposal)
				r.Put("/", h.updateProposal)
				r.Delete("/", h.deleteProposal)
			})
		})

		// Empresas Parceiras
		r.Route("/companies", func(r chi.Router) {
			r.Get("/", h.listCompanies)
			r.Post("/", h.createCompany)
			r.Route("/{id}", func(r chi.Router) {
				r.Get("/", h.getCompany)
				r.Put("/", h.updateCompany)
				r.Delete("/", h.deleteCompany)
			})
		})

		// Configurações do Portal
		r.Route("/settings", func(r chi.Router) {
			r.Get("/", h.getSettings)
			r.Put("/", h.updateSettings)
		})

		// Tipos de Proposta
		r.Route("/proposal-types", func(r chi.Router) {
			r.Get("/", h.listProposalTypes)
			r.Post("/", h.createProposalType)
			r.Route("/{id}", func(r chi.Router) {
				r.Get("/", h.getProposalType)
				r.Put("/", h.updateProposalType)
				r.Delete("/", h.deleteProposalType)
			})
		})

		// Perfis de Acesso
		r.Route("/profiles", func(r chi.Router) {
			r.Get("/", h.listPerfis)
			r.Post("/", h.createPerfil)
			r.Route("/{id}", func(r chi.Router) {
				r.Get("/", h.getPerfil)
				r.Put("/", h.updatePerfil)
				r.Delete("/", h.deletePerfil)
			})
		})

		// Usuários
		r.Route("/users", func(r chi.Router) {
			r.Get("/", h.listUsuarios)
			r.Post("/", h.createUsuario)
			r.Route("/{id}", func(r chi.Router) {
				r.Get("/", h.getUsuario)
				r.Put("/", h.updateUsuario)
				r.Delete("/", h.deleteUsuario)
			})
		})

		// Auth
		r.Post("/auth/login", h.login)

		// Fluxo do Supervisor
		r.Route("/supervisor", func(r chi.Router) {
			r.Post("/verify-password", h.verifySupervisorPassword)
			r.Route("/requests", func(r chi.Router) {
				r.Get("/", h.listSupervisorRequests)
				r.Post("/", h.createSupervisorRequest)
				r.Route("/{id}", func(r chi.Router) {
					r.Post("/approve", h.approveSupervisorRequest)
					r.Post("/reject", h.rejectSupervisorRequest)
				})
			})
		})

		// Dashboard Stats
		r.Get("/dashboard/stats", h.getDashboardStats)
	})
}

// Helpers
func (h *Handler) respondWithJSON(w http.ResponseWriter, code int, payload interface{}) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(code)
	_ = json.NewEncoder(w).Encode(payload)
}

func (h *Handler) respondWithError(w http.ResponseWriter, code int, message string) {
	h.respondWithJSON(w, code, map[string]string{"error": message})
}

func (h *Handler) handleError(w http.ResponseWriter, err error) {
	if err == nil {
		return
	}

	switch {
	case errors.Is(err, domain.ErrClientNotFound),
		errors.Is(err, domain.ErrProposalNotFound),
		errors.Is(err, domain.ErrCompanyNotFound),
		errors.Is(err, domain.ErrSettingNotFound),
		errors.Is(err, domain.ErrAnalysisRequestNotFound),
		errors.Is(err, domain.ErrUserNotFound),
		errors.Is(err, domain.ErrPerfilNotFound):
		h.respondWithError(w, http.StatusNotFound, err.Error())

	case errors.Is(err, domain.ErrInvalidCPFCNPJ),
		errors.Is(err, domain.ErrInvalidCNPJ),
		errors.Is(err, domain.ErrClientAlreadyExists),
		errors.Is(err, domain.ErrCompanyAlreadyExists),
		errors.Is(err, domain.ErrInvalidClientName),
		errors.Is(err, domain.ErrInvalidClientEmail),
		errors.Is(err, domain.ErrInvalidCompanyName),
		errors.Is(err, domain.ErrInvalidCompanyEmail),
		errors.Is(err, domain.ErrInvalidProposalType),
		errors.Is(err, domain.ErrInvalidProposalVal),
		errors.Is(err, domain.ErrSupervisorAuthFailed),
		errors.Is(err, domain.ErrSupervisorActionDone),
		errors.Is(err, domain.ErrUserAlreadyExists),
		errors.Is(err, domain.ErrInvalidUserEmail),
		errors.Is(err, domain.ErrInvalidUserName),
		errors.Is(err, domain.ErrPerfilAlreadyExists),
		errors.Is(err, domain.ErrInvalidPerfilName),
		errors.Is(err, domain.ErrCannotDeleteSystemPerfil),
		errors.Is(err, domain.ErrCannotDeleteLastAdmin):
		h.respondWithError(w, http.StatusBadRequest, err.Error())

	case errors.Is(err, domain.ErrInvalidCredentials):
		h.respondWithError(w, http.StatusUnauthorized, err.Error())

	default:
		h.respondWithError(w, http.StatusInternalServerError, "Erro interno no servidor: "+err.Error())
	}
}

// ==========================================
// CLIENTES HANDLERS
// ==========================================
func (h *Handler) listClients(w http.ResponseWriter, r *http.Request) {
	clients, err := h.clientService.List()
	if err != nil {
		h.handleError(w, err)
		return
	}
	h.respondWithJSON(w, http.StatusOK, clients)
}

func (h *Handler) createClient(w http.ResponseWriter, r *http.Request) {
	var c domain.Cliente
	if err := json.NewDecoder(r.Body).Decode(&c); err != nil {
		h.respondWithError(w, http.StatusBadRequest, "Corpo da requisição inválido")
		return
	}

	if err := h.clientService.Create(&c); err != nil {
		h.handleError(w, err)
		return
	}
	h.respondWithJSON(w, http.StatusCreated, c)
}

func (h *Handler) getClient(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")
	client, err := h.clientService.GetByID(id)
	if err != nil {
		h.handleError(w, err)
		return
	}
	h.respondWithJSON(w, http.StatusOK, client)
}

func (h *Handler) updateClient(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")
	var c domain.Cliente
	if err := json.NewDecoder(r.Body).Decode(&c); err != nil {
		h.respondWithError(w, http.StatusBadRequest, "Corpo da requisição inválido")
		return
	}

	updated, err := h.clientService.Update(id, &c)
	if err != nil {
		h.handleError(w, err)
		return
	}
	h.respondWithJSON(w, http.StatusOK, updated)
}

func (h *Handler) deleteClient(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")
	if err := h.clientService.Delete(id); err != nil {
		h.handleError(w, err)
		return
	}
	h.respondWithJSON(w, http.StatusOK, map[string]string{"message": "Cliente deletado com sucesso"})
}

func (h *Handler) listClientProposals(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")
	proposals, err := h.proposalService.ListByClienteID(id)
	if err != nil {
		h.handleError(w, err)
		return
	}
	h.respondWithJSON(w, http.StatusOK, proposals)
}

// ==========================================
// PROPOSTAS HANDLERS
// ==========================================
func (h *Handler) listProposals(w http.ResponseWriter, r *http.Request) {
	proposals, err := h.proposalService.List()
	if err != nil {
		h.handleError(w, err)
		return
	}
	h.respondWithJSON(w, http.StatusOK, proposals)
}

func (h *Handler) createProposal(w http.ResponseWriter, r *http.Request) {
	var p domain.Proposta
	if err := json.NewDecoder(r.Body).Decode(&p); err != nil {
		h.respondWithError(w, http.StatusBadRequest, "Corpo da requisição inválido")
		return
	}

	if err := h.proposalService.Create(&p); err != nil {
		h.handleError(w, err)
		return
	}
	h.respondWithJSON(w, http.StatusCreated, p)
}

func (h *Handler) getProposal(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")
	proposal, err := h.proposalService.GetByID(id)
	if err != nil {
		h.handleError(w, err)
		return
	}
	h.respondWithJSON(w, http.StatusOK, proposal)
}

func (h *Handler) updateProposal(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")
	var p domain.Proposta
	if err := json.NewDecoder(r.Body).Decode(&p); err != nil {
		h.respondWithError(w, http.StatusBadRequest, "Corpo da requisição inválido")
		return
	}

	updated, err := h.proposalService.Update(id, &p)
	if err != nil {
		h.handleError(w, err)
		return
	}
	h.respondWithJSON(w, http.StatusOK, updated)
}

func (h *Handler) deleteProposal(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")
	if err := h.proposalService.Delete(id); err != nil {
		h.handleError(w, err)
		return
	}
	h.respondWithJSON(w, http.StatusOK, map[string]string{"message": "Proposta deletada com sucesso"})
}

// ==========================================
// EMPRESAS HANDLERS
// ==========================================
func (h *Handler) listCompanies(w http.ResponseWriter, r *http.Request) {
	companies, err := h.companyService.List()
	if err != nil {
		h.handleError(w, err)
		return
	}
	h.respondWithJSON(w, http.StatusOK, companies)
}

func (h *Handler) createCompany(w http.ResponseWriter, r *http.Request) {
	var e domain.Empresa
	if err := json.NewDecoder(r.Body).Decode(&e); err != nil {
		h.respondWithError(w, http.StatusBadRequest, "Corpo da requisição inválido")
		return
	}
	if err := h.companyService.Create(&e); err != nil {
		h.handleError(w, err)
		return
	}
	h.respondWithJSON(w, http.StatusCreated, e)
}

func (h *Handler) getCompany(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")
	company, err := h.companyService.GetByID(id)
	if err != nil {
		h.handleError(w, err)
		return
	}
	h.respondWithJSON(w, http.StatusOK, company)
}

func (h *Handler) updateCompany(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")
	var e domain.Empresa
	if err := json.NewDecoder(r.Body).Decode(&e); err != nil {
		h.respondWithError(w, http.StatusBadRequest, "Corpo da requisição inválido")
		return
	}
	updated, err := h.companyService.Update(id, &e)
	if err != nil {
		h.handleError(w, err)
		return
	}
	h.respondWithJSON(w, http.StatusOK, updated)
}

func (h *Handler) deleteCompany(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")
	if err := h.companyService.Delete(id); err != nil {
		h.handleError(w, err)
		return
	}
	h.respondWithJSON(w, http.StatusOK, map[string]string{"message": "Empresa parceira deletada com sucesso"})
}

// ==========================================
// CONFIGURAÇÕES HANDLERS
// ==========================================
type SettingsResponse struct {
	TaxaCorretagem float64 `json:"taxa_corretagem"`
}

func (h *Handler) getSettings(w http.ResponseWriter, r *http.Request) {
	rate, err := h.configService.GetCommissionRate()
	if err != nil {
		h.handleError(w, err)
		return
	}
	h.respondWithJSON(w, http.StatusOK, SettingsResponse{TaxaCorretagem: rate})
}

type SettingsUpdateRequest struct {
	TaxaCorretagem  *float64 `json:"taxa_corretagem"`
	SenhaSupervisor *string  `json:"senha_supervisor"`
}

func (h *Handler) updateSettings(w http.ResponseWriter, r *http.Request) {
	var req SettingsUpdateRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		h.respondWithError(w, http.StatusBadRequest, "Corpo da requisição inválido")
		return
	}

	if req.TaxaCorretagem != nil {
		if err := h.configService.UpdateCommissionRate(*req.TaxaCorretagem); err != nil {
			h.handleError(w, err)
			return
		}
	}

	if req.SenhaSupervisor != nil {
		if err := h.configService.UpdateSupervisorPassword(*req.SenhaSupervisor); err != nil {
			h.handleError(w, err)
			return
		}
	}

	h.respondWithJSON(w, http.StatusOK, map[string]string{"message": "Configurações atualizadas com sucesso"})
}

// ==========================================
// TIPOS DE PROPOSTA HANDLERS
// ==========================================
func (h *Handler) listProposalTypes(w http.ResponseWriter, r *http.Request) {
	tipos, err := h.proposalTypeService.List()
	if err != nil {
		h.handleError(w, err)
		return
	}
	h.respondWithJSON(w, http.StatusOK, tipos)
}

func (h *Handler) createProposalType(w http.ResponseWriter, r *http.Request) {
	var tipo domain.TipoProposta
	if err := json.NewDecoder(r.Body).Decode(&tipo); err != nil {
		h.respondWithError(w, http.StatusBadRequest, "Corpo da requisição inválido")
		return
	}

	if err := h.proposalTypeService.Create(&tipo); err != nil {
		h.handleError(w, err)
		return
	}
	h.respondWithJSON(w, http.StatusCreated, tipo)
}

func (h *Handler) getProposalType(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")
	tipo, err := h.proposalTypeService.GetByID(id)
	if err != nil {
		h.handleError(w, err)
		return
	}
	h.respondWithJSON(w, http.StatusOK, tipo)
}

func (h *Handler) updateProposalType(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")
	var tipo domain.TipoProposta
	if err := json.NewDecoder(r.Body).Decode(&tipo); err != nil {
		h.respondWithError(w, http.StatusBadRequest, "Corpo da requisição inválido")
		return
	}

	updated, err := h.proposalTypeService.Update(id, &tipo)
	if err != nil {
		h.handleError(w, err)
		return
	}
	h.respondWithJSON(w, http.StatusOK, updated)
}

func (h *Handler) deleteProposalType(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")
	if err := h.proposalTypeService.Delete(id); err != nil {
		h.handleError(w, err)
		return
	}
	h.respondWithJSON(w, http.StatusOK, map[string]string{"message": "Tipo de proposta excluído com sucesso"})
}

// ==========================================
// SUPERVISOR HANDLERS
// ==========================================
type VerifyPasswordRequest struct {
	Password string `json:"password"`
}

type VerifyPasswordResponse struct {
	Valid bool `json:"valid"`
}

func (h *Handler) verifySupervisorPassword(w http.ResponseWriter, r *http.Request) {
	var req VerifyPasswordRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		h.respondWithError(w, http.StatusBadRequest, "Corpo da requisição inválido")
		return
	}

	err := h.configService.VerifySupervisorPassword(req.Password)
	if err != nil {
		h.respondWithJSON(w, http.StatusOK, VerifyPasswordResponse{Valid: false})
		return
	}
	h.respondWithJSON(w, http.StatusOK, VerifyPasswordResponse{Valid: true})
}

func (h *Handler) listSupervisorRequests(w http.ResponseWriter, r *http.Request) {
	status := r.URL.Query().Get("status")
	var requests []domain.PedidoAnalise
	var err error

	if status == "Pendente" {
		requests, err = h.supervisorService.ListPendentes()
	} else {
		requests, err = h.supervisorService.ListAll()
	}

	if err != nil {
		h.handleError(w, err)
		return
	}
	h.respondWithJSON(w, http.StatusOK, requests)
}

func (h *Handler) createSupervisorRequest(w http.ResponseWriter, r *http.Request) {
	var req domain.PedidoAnalise
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		h.respondWithError(w, http.StatusBadRequest, "Corpo da requisição inválido")
		return
	}

	if err := h.supervisorService.CreateRequest(&req); err != nil {
		h.handleError(w, err)
		return
	}
	h.respondWithJSON(w, http.StatusCreated, req)
}

func (h *Handler) approveSupervisorRequest(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")
	if err := h.supervisorService.ApproveRequest(id); err != nil {
		h.handleError(w, err)
		return
	}
	h.respondWithJSON(w, http.StatusOK, map[string]string{"message": "Solicitação aprovada e executada com sucesso"})
}

func (h *Handler) rejectSupervisorRequest(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")
	if err := h.supervisorService.RejectRequest(id); err != nil {
		h.handleError(w, err)
		return
	}
	h.respondWithJSON(w, http.StatusOK, map[string]string{"message": "Solicitação rejeitada com sucesso"})
}

// ==========================================
// DASHBOARD HANDLERS
// ==========================================
type DashboardStatsExtended struct {
	TotalClients             int                `json:"total_clients"`
	TotalProposals           int                `json:"total_proposals"`
	TotalCompanies           int                `json:"total_companies"`
	TotalValue               float64            `json:"total_value"`
	ClosedCommissionsValue   float64            `json:"closed_commissions_value"`
	PendingCommissionsValue  float64            `json:"pending_commissions_value"`
	ProposalsByStatus        map[string]int     `json:"proposals_by_status"`
	ProposalsByType          map[string]int     `json:"proposals_by_type"`
	ValueByStatus            map[string]float64 `json:"value_by_status"`
	ValueByType              map[string]float64 `json:"value_by_type"`
}

func (h *Handler) getDashboardStats(w http.ResponseWriter, r *http.Request) {
	clients, err := h.clientService.List()
	if err != nil {
		h.handleError(w, err)
		return
	}
	proposals, err := h.proposalService.List()
	if err != nil {
		h.handleError(w, err)
		return
	}
	companies, err := h.companyService.List()
	if err != nil {
		h.handleError(w, err)
		return
	}

	rate, _ := h.configService.GetCommissionRate()

	stats := DashboardStatsExtended{
		TotalClients:            len(clients),
		TotalProposals:          len(proposals),
		TotalCompanies:          len(companies),
		TotalValue:              0,
		ClosedCommissionsValue:  0,
		PendingCommissionsValue: 0,
		ProposalsByStatus:       make(map[string]int),
		ProposalsByType:         make(map[string]int),
		ValueByStatus:           make(map[string]float64),
		ValueByType:             make(map[string]float64),
	}

	for _, p := range proposals {
		stats.TotalValue += p.Valor
		stats.ProposalsByStatus[string(p.Status)]++
		stats.ProposalsByType[string(p.Tipo)]++
		stats.ValueByStatus[string(p.Status)] += p.Valor
		stats.ValueByType[string(p.Tipo)] += p.Valor

		if p.EmpresaID != nil {
			if p.StatusCorretagem == "FechadaComSucesso" {
				stats.ClosedCommissionsValue += p.ValorComissao
			} else if p.StatusCorretagem == "Encaminhada" {
				stats.PendingCommissionsValue += p.Valor * (rate / 100)
			}
		}
	}

	h.respondWithJSON(w, http.StatusOK, stats)
}

// ==========================================
// PERFIS HANDLERS
// ==========================================
func (h *Handler) listPerfis(w http.ResponseWriter, r *http.Request) {
	perfis, err := h.perfilService.List()
	if err != nil {
		h.handleError(w, err)
		return
	}
	h.respondWithJSON(w, http.StatusOK, perfis)
}

func (h *Handler) createPerfil(w http.ResponseWriter, r *http.Request) {
	var perfil domain.Perfil
	if err := json.NewDecoder(r.Body).Decode(&perfil); err != nil {
		h.respondWithError(w, http.StatusBadRequest, "Corpo da requisição inválido")
		return
	}
	if err := h.perfilService.Create(&perfil); err != nil {
		h.handleError(w, err)
		return
	}
	h.respondWithJSON(w, http.StatusCreated, perfil)
}

func (h *Handler) getPerfil(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")
	perfil, err := h.perfilService.GetByID(id)
	if err != nil {
		h.handleError(w, err)
		return
	}
	h.respondWithJSON(w, http.StatusOK, perfil)
}

func (h *Handler) updatePerfil(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")
	var perfil domain.Perfil
	if err := json.NewDecoder(r.Body).Decode(&perfil); err != nil {
		h.respondWithError(w, http.StatusBadRequest, "Corpo da requisição inválido")
		return
	}
	updated, err := h.perfilService.Update(id, &perfil)
	if err != nil {
		h.handleError(w, err)
		return
	}
	h.respondWithJSON(w, http.StatusOK, updated)
}

func (h *Handler) deletePerfil(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")
	if err := h.perfilService.Delete(id); err != nil {
		h.handleError(w, err)
		return
	}
	h.respondWithJSON(w, http.StatusOK, map[string]string{"message": "Perfil excluído com sucesso"})
}

// ==========================================
// USUÁRIOS HANDLERS
// ==========================================
type CreateUsuarioRequest struct {
	Nome     string `json:"nome"`
	Email    string `json:"email"`
	Senha    string `json:"senha"`
	PerfilID string `json:"perfil_id"`
	Ativo    bool   `json:"ativo"`
}

type UpdateUsuarioRequest struct {
	Nome     string `json:"nome"`
	Email    string `json:"email"`
	Senha    string `json:"senha"` // optional; empty means no change
	PerfilID string `json:"perfil_id"`
	Ativo    bool   `json:"ativo"`
}

type LoginRequest struct {
	Email string `json:"email"`
	Senha string `json:"senha"`
}

func (h *Handler) listUsuarios(w http.ResponseWriter, r *http.Request) {
	usuarios, err := h.usuarioService.List()
	if err != nil {
		h.handleError(w, err)
		return
	}
	// Convert to safe DTO
	resps := make([]domain.UsuarioResponse, len(usuarios))
	for i, u := range usuarios {
		resps[i] = u.ToResponse()
	}
	h.respondWithJSON(w, http.StatusOK, resps)
}

func (h *Handler) createUsuario(w http.ResponseWriter, r *http.Request) {
	var req CreateUsuarioRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		h.respondWithError(w, http.StatusBadRequest, "Corpo da requisição inválido")
		return
	}
	u := &domain.Usuario{
		Nome:     req.Nome,
		Email:    req.Email,
		PerfilID: req.PerfilID,
		Ativo:    req.Ativo,
	}
	if err := h.usuarioService.Create(u, req.Senha); err != nil {
		h.handleError(w, err)
		return
	}
	h.respondWithJSON(w, http.StatusCreated, u.ToResponse())
}

func (h *Handler) getUsuario(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")
	u, err := h.usuarioService.GetByID(id)
	if err != nil {
		h.handleError(w, err)
		return
	}
	h.respondWithJSON(w, http.StatusOK, u.ToResponse())
}

func (h *Handler) updateUsuario(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")
	var req UpdateUsuarioRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		h.respondWithError(w, http.StatusBadRequest, "Corpo da requisição inválido")
		return
	}
	input := &domain.Usuario{
		Nome:     req.Nome,
		Email:    req.Email,
		PerfilID: req.PerfilID,
		Ativo:    req.Ativo,
	}
	updated, err := h.usuarioService.Update(id, input, req.Senha)
	if err != nil {
		h.handleError(w, err)
		return
	}
	h.respondWithJSON(w, http.StatusOK, updated.ToResponse())
}

func (h *Handler) deleteUsuario(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")
	if err := h.usuarioService.Delete(id); err != nil {
		h.handleError(w, err)
		return
	}
	h.respondWithJSON(w, http.StatusOK, map[string]string{"message": "Usuário excluído com sucesso"})
}

func (h *Handler) login(w http.ResponseWriter, r *http.Request) {
	var req LoginRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		h.respondWithError(w, http.StatusBadRequest, "Corpo da requisição inválido")
		return
	}
	u, err := h.usuarioService.Login(req.Email, req.Senha)
	if err != nil {
		h.respondWithError(w, http.StatusUnauthorized, err.Error())
		return
	}
	h.respondWithJSON(w, http.StatusOK, u.ToResponse())
}


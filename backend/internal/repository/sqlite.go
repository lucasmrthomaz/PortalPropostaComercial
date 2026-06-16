package repository

import (
	"cadastro-cliente-proposta/backend/internal/domain"
	"gorm.io/gorm"
)

// ==========================================
// CLIENTE REPOSITORY
// ==========================================
type sqliteClienteRepository struct {
	db *gorm.DB
}

func NewSQLiteClienteRepository(db *gorm.DB) domain.ClienteRepository {
	return &sqliteClienteRepository{db: db}
}

func (r *sqliteClienteRepository) Create(cliente *domain.Cliente) error {
	return r.db.Create(cliente).Error
}

func (r *sqliteClienteRepository) GetByID(id string) (*domain.Cliente, error) {
	var cliente domain.Cliente
	err := r.db.Preload("Propostas").Preload("Propostas.Empresa").First(&cliente, "id = ?", id).Error
	if err != nil {
		return nil, err
	}
	return &cliente, nil
}

func (r *sqliteClienteRepository) GetByCPFCNPJ(cpfCnpj string) (*domain.Cliente, error) {
	var cliente domain.Cliente
	err := r.db.Preload("Propostas").Preload("Propostas.Empresa").First(&cliente, "cpf_cnpj = ?", cpfCnpj).Error
	if err != nil {
		return nil, err
	}
	return &cliente, nil
}

func (r *sqliteClienteRepository) Update(cliente *domain.Cliente) error {
	return r.db.Save(cliente).Error
}

func (r *sqliteClienteRepository) Delete(id string) error {
	return r.db.Delete(&domain.Cliente{}, "id = ?", id).Error
}

func (r *sqliteClienteRepository) List() ([]domain.Cliente, error) {
	var clientes []domain.Cliente
	err := r.db.Find(&clientes).Error
	if err != nil {
		return nil, err
	}
	return clientes, nil
}

// ==========================================
// PROPOSTA REPOSITORY
// ==========================================
type sqlitePropostaRepository struct {
	db *gorm.DB
}

func NewSQLitePropostaRepository(db *gorm.DB) domain.PropostaRepository {
	return &sqlitePropostaRepository{db: db}
}

func (r *sqlitePropostaRepository) Create(proposta *domain.Proposta) error {
	return r.db.Create(proposta).Error
}

func (r *sqlitePropostaRepository) GetByID(id string) (*domain.Proposta, error) {
	var proposta domain.Proposta
	err := r.db.Preload("Empresa").First(&proposta, "id = ?", id).Error
	if err != nil {
		return nil, err
	}
	return &proposta, nil
}

func (r *sqlitePropostaRepository) Update(proposta *domain.Proposta) error {
	return r.db.Save(proposta).Error
}

func (r *sqlitePropostaRepository) Delete(id string) error {
	return r.db.Delete(&domain.Proposta{}, "id = ?", id).Error
}

func (r *sqlitePropostaRepository) ListByClienteID(clienteID string) ([]domain.Proposta, error) {
	var propostas []domain.Proposta
	err := r.db.Preload("Empresa").Find(&propostas, "cliente_id = ?", clienteID).Error
	if err != nil {
		return nil, err
	}
	return propostas, nil
}

func (r *sqlitePropostaRepository) List() ([]domain.Proposta, error) {
	var propostas []domain.Proposta
	err := r.db.Preload("Empresa").Find(&propostas).Error
	if err != nil {
		return nil, err
	}
	return propostas, nil
}

func (r *sqlitePropostaRepository) CountByTipo(tipo string) (int64, error) {
	var count int64
	err := r.db.Model(&domain.Proposta{}).Where("tipo = ?", tipo).Count(&count).Error
	return count, err
}

// ==========================================
// EMPRESA REPOSITORY
// ==========================================
type sqliteEmpresaRepository struct {
	db *gorm.DB
}

func NewSQLiteEmpresaRepository(db *gorm.DB) domain.EmpresaRepository {
	return &sqliteEmpresaRepository{db: db}
}

func (r *sqliteEmpresaRepository) Create(empresa *domain.Empresa) error {
	return r.db.Create(empresa).Error
}

func (r *sqliteEmpresaRepository) GetByID(id string) (*domain.Empresa, error) {
	var empresa domain.Empresa
	err := r.db.First(&empresa, "id = ?", id).Error
	if err != nil {
		return nil, err
	}
	return &empresa, nil
}

func (r *sqliteEmpresaRepository) GetByCNPJ(cnpj string) (*domain.Empresa, error) {
	var empresa domain.Empresa
	err := r.db.First(&empresa, "cnpj = ?", cnpj).Error
	if err != nil {
		return nil, err
	}
	return &empresa, nil
}

func (r *sqliteEmpresaRepository) Update(empresa *domain.Empresa) error {
	return r.db.Save(empresa).Error
}

func (r *sqliteEmpresaRepository) Delete(id string) error {
	return r.db.Delete(&domain.Empresa{}, "id = ?", id).Error
}

func (r *sqliteEmpresaRepository) List() ([]domain.Empresa, error) {
	var empresas []domain.Empresa
	err := r.db.Find(&empresas).Error
	if err != nil {
		return nil, err
	}
	return empresas, nil
}

// ==========================================
// CONFIGURACAO REPOSITORY
// ==========================================
type sqliteConfiguracaoRepository struct {
	db *gorm.DB
}

func NewSQLiteConfiguracaoRepository(db *gorm.DB) domain.ConfiguracaoRepository {
	return &sqliteConfiguracaoRepository{db: db}
}

func (r *sqliteConfiguracaoRepository) Get(chave string) (string, error) {
	var conf domain.Configuracao
	err := r.db.First(&conf, "chave = ?", chave).Error
	if err != nil {
		return "", err
	}
	return conf.Valor, nil
}

func (r *sqliteConfiguracaoRepository) Set(chave string, valor string) error {
	var conf domain.Configuracao
	err := r.db.First(&conf, "chave = ?", chave).Error
	if err != nil {
		conf = domain.Configuracao{Chave: chave, Valor: valor}
		return r.db.Create(&conf).Error
	}
	conf.Valor = valor
	return r.db.Save(&conf).Error
}

// ==========================================
// PEDIDO DE ANÁLISE REPOSITORY
// ==========================================
type sqlitePedidoAnaliseRepository struct {
	db *gorm.DB
}

func NewSQLitePedidoAnaliseRepository(db *gorm.DB) domain.PedidoAnaliseRepository {
	return &sqlitePedidoAnaliseRepository{db: db}
}

func (r *sqlitePedidoAnaliseRepository) Create(pedido *domain.PedidoAnalise) error {
	return r.db.Create(pedido).Error
}

func (r *sqlitePedidoAnaliseRepository) GetByID(id string) (*domain.PedidoAnalise, error) {
	var pedido domain.PedidoAnalise
	err := r.db.First(&pedido, "id = ?", id).Error
	if err != nil {
		return nil, err
	}
	return &pedido, nil
}

func (r *sqlitePedidoAnaliseRepository) Update(pedido *domain.PedidoAnalise) error {
	return r.db.Save(pedido).Error
}

func (r *sqlitePedidoAnaliseRepository) Delete(id string) error {
	return r.db.Delete(&domain.PedidoAnalise{}, "id = ?", id).Error
}

func (r *sqlitePedidoAnaliseRepository) List() ([]domain.PedidoAnalise, error) {
	var pedidos []domain.PedidoAnalise
	err := r.db.Order("created_at desc").Find(&pedidos).Error
	if err != nil {
		return nil, err
	}
	return pedidos, nil
}

func (r *sqlitePedidoAnaliseRepository) ListPendentes() ([]domain.PedidoAnalise, error) {
	var pedidos []domain.PedidoAnalise
	err := r.db.Where("status = ?", "Pendente").Order("created_at desc").Find(&pedidos).Error
	if err != nil {
		return nil, err
	}
	return pedidos, nil
}

// ==========================================
// TIPO PROPOSTA REPOSITORY
// ==========================================
type sqliteTipoPropostaRepository struct {
	db *gorm.DB
}

func NewSQLiteTipoPropostaRepository(db *gorm.DB) domain.TipoPropostaRepository {
	return &sqliteTipoPropostaRepository{db: db}
}

func (r *sqliteTipoPropostaRepository) Create(tipo *domain.TipoProposta) error {
	return r.db.Create(tipo).Error
}

func (r *sqliteTipoPropostaRepository) GetByID(id string) (*domain.TipoProposta, error) {
	var tipo domain.TipoProposta
	err := r.db.First(&tipo, "id = ?", id).Error
	if err != nil {
		return nil, err
	}
	return &tipo, nil
}

func (r *sqliteTipoPropostaRepository) GetByChave(chave string) (*domain.TipoProposta, error) {
	var tipo domain.TipoProposta
	err := r.db.First(&tipo, "chave = ?", chave).Error
	if err != nil {
		return nil, err
	}
	return &tipo, nil
}

func (r *sqliteTipoPropostaRepository) Update(tipo *domain.TipoProposta) error {
	return r.db.Save(tipo).Error
}

func (r *sqliteTipoPropostaRepository) Delete(id string) error {
	return r.db.Delete(&domain.TipoProposta{}, "id = ?", id).Error
}

func (r *sqliteTipoPropostaRepository) List() ([]domain.TipoProposta, error) {
	var tipos []domain.TipoProposta
	err := r.db.Order("nome asc").Find(&tipos).Error
	if err != nil {
		return nil, err
	}
	return tipos, nil
}

// ==========================================
// PERFIL REPOSITORY
// ==========================================
type sqlitePerfilRepository struct {
	db *gorm.DB
}

func NewSQLitePerfilRepository(db *gorm.DB) domain.PerfilRepository {
	return &sqlitePerfilRepository{db: db}
}

func (r *sqlitePerfilRepository) Create(perfil *domain.Perfil) error {
	return r.db.Create(perfil).Error
}

func (r *sqlitePerfilRepository) GetByID(id string) (*domain.Perfil, error) {
	var perfil domain.Perfil
	err := r.db.First(&perfil, "id = ?", id).Error
	if err != nil {
		return nil, err
	}
	return &perfil, nil
}

func (r *sqlitePerfilRepository) GetByNome(nome string) (*domain.Perfil, error) {
	var perfil domain.Perfil
	err := r.db.First(&perfil, "nome = ?", nome).Error
	if err != nil {
		return nil, err
	}
	return &perfil, nil
}

func (r *sqlitePerfilRepository) Update(perfil *domain.Perfil) error {
	return r.db.Save(perfil).Error
}

func (r *sqlitePerfilRepository) Delete(id string) error {
	return r.db.Delete(&domain.Perfil{}, "id = ?", id).Error
}

func (r *sqlitePerfilRepository) List() ([]domain.Perfil, error) {
	var perfis []domain.Perfil
	err := r.db.Order("nome asc").Find(&perfis).Error
	if err != nil {
		return nil, err
	}
	return perfis, nil
}

// ==========================================
// USUARIO REPOSITORY
// ==========================================
type sqliteUsuarioRepository struct {
	db *gorm.DB
}

func NewSQLiteUsuarioRepository(db *gorm.DB) domain.UsuarioRepository {
	return &sqliteUsuarioRepository{db: db}
}

func (r *sqliteUsuarioRepository) Create(usuario *domain.Usuario) error {
	return r.db.Create(usuario).Error
}

func (r *sqliteUsuarioRepository) GetByID(id string) (*domain.Usuario, error) {
	var usuario domain.Usuario
	err := r.db.Preload("Perfil").First(&usuario, "id = ?", id).Error
	if err != nil {
		return nil, err
	}
	return &usuario, nil
}

func (r *sqliteUsuarioRepository) GetByEmail(email string) (*domain.Usuario, error) {
	var usuario domain.Usuario
	err := r.db.Preload("Perfil").First(&usuario, "email = ?", email).Error
	if err != nil {
		return nil, err
	}
	return &usuario, nil
}

func (r *sqliteUsuarioRepository) Update(usuario *domain.Usuario) error {
	return r.db.Save(usuario).Error
}

func (r *sqliteUsuarioRepository) Delete(id string) error {
	return r.db.Delete(&domain.Usuario{}, "id = ?", id).Error
}

func (r *sqliteUsuarioRepository) List() ([]domain.Usuario, error) {
	var usuarios []domain.Usuario
	err := r.db.Preload("Perfil").Order("nome asc").Find(&usuarios).Error
	if err != nil {
		return nil, err
	}
	return usuarios, nil
}

func (r *sqliteUsuarioRepository) CountByPerfilID(perfilID string) (int64, error) {
	var count int64
	err := r.db.Model(&domain.Usuario{}).Where("perfil_id = ?", perfilID).Count(&count).Error
	return count, err
}

func (r *sqliteUsuarioRepository) CountSuperAdmins() (int64, error) {
	var count int64
	// Count active users whose profile is_sistema = true AND nome = 'Super Admin'
	err := r.db.Model(&domain.Usuario{}).
		Joins("JOIN perfis ON perfis.id = usuarios.perfil_id").
		Where("perfis.nome = ? AND usuarios.ativo = ?", "Super Admin", true).
		Count(&count).Error
	return count, err
}


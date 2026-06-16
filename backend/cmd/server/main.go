package main

import (
	"cadastro-cliente-proposta/backend/internal/config"
	"cadastro-cliente-proposta/backend/internal/domain"
	"cadastro-cliente-proposta/backend/internal/handler"
	"cadastro-cliente-proposta/backend/internal/repository"
	"cadastro-cliente-proposta/backend/internal/service"
	"fmt"
	"log"
	"net/http"
	"time"

	"github.com/glebarez/sqlite"
	"github.com/go-chi/chi/v5"
	"github.com/go-chi/chi/v5/middleware"
	"github.com/rs/cors"
	"gorm.io/gorm"
)

func main() {
	cfg := config.Load()

	// Inicializa banco de dados SQLite via GORM (pure Go driver)
	db, err := gorm.Open(sqlite.Open(cfg.DBPath), &gorm.Config{})
	if err != nil {
		log.Fatalf("Falha ao conectar com o banco de dados SQLite: %v", err)
	}

	// Habilita suporte a chaves estrangeiras no SQLite
	sqlDB, err := db.DB()
	if err == nil {
		_, _ = sqlDB.Exec("PRAGMA foreign_keys = ON;")
	}

	// Executa Migrações Automáticas
	log.Println("Executando migrações do banco de dados...")
	err = db.AutoMigrate(
		&domain.Cliente{},
		&domain.Proposta{},
		&domain.Empresa{},
		&domain.Configuracao{},
		&domain.PedidoAnalise{},
		&domain.TipoProposta{},
		&domain.Perfil{},
		&domain.Usuario{},
	)
	if err != nil {
		log.Fatalf("Falha ao executar migrações: %v", err)
	}

	// Seed de configurações iniciais se não existirem
	var count int64
	db.Model(&domain.Configuracao{}).Where("chave = ?", "taxa_corretagem").Count(&count)
	if count == 0 {
		log.Println("Criando configuração padrão: taxa_corretagem = 5.00")
		db.Create(&domain.Configuracao{Chave: "taxa_corretagem", Valor: "5.00"})
	}
	db.Model(&domain.Configuracao{}).Where("chave = ?", "senha_supervisor").Count(&count)
	if count == 0 {
		log.Println("Criando configuração padrão: senha_supervisor = 123")
		db.Create(&domain.Configuracao{Chave: "senha_supervisor", Valor: "123"})
	}

	// Seed de tipos de proposta iniciais se não existirem
	var countTipos int64
	db.Model(&domain.TipoProposta{}).Count(&countTipos)
	if countTipos == 0 {
		log.Println("Criando tipos de proposta padrão...")
		db.Create(&domain.TipoProposta{
			ID:        "1",
			Nome:      "Imobiliária",
			Chave:     "Imobiliaria",
			Campos:    domain.JSONB(`[{"nome":"Endereço Completo do Imóvel","chave":"endereco_imovel","tipo":"text","obrigatorio":true},{"nome":"Tipo do Imóvel","chave":"tipo_imovel","tipo":"text","obrigatorio":true},{"nome":"Área Privativa (m²)","chave":"area_m2","tipo":"number","obrigatorio":true}]`),
			CreatedAt: time.Now(),
			UpdatedAt: time.Now(),
		})
		db.Create(&domain.TipoProposta{
			ID:        "2",
			Nome:      "Automotiva",
			Chave:     "Auto",
			Campos:    domain.JSONB(`[{"nome":"Marca","chave":"marca","tipo":"text","obrigatorio":true},{"nome":"Modelo","chave":"modelo","tipo":"text","obrigatorio":true},{"nome":"Ano de Fabricação","chave":"ano","tipo":"number","obrigatorio":true},{"nome":"Placa do Veículo","chave":"placa","tipo":"text","obrigatorio":true}]`),
			CreatedAt: time.Now(),
			UpdatedAt: time.Now(),
		})
		db.Create(&domain.TipoProposta{
			ID:        "3",
			Nome:      "Compra/Venda Diversas",
			Chave:     "CompraVenda",
			Campos:    domain.JSONB(`[{"nome":"Descrição dos Itens / Serviços","chave":"itens","tipo":"text","obrigatorio":true},{"nome":"Condições de Pagamento","chave":"condicoes_pagamento","tipo":"text","obrigatorio":true}]`),
			CreatedAt: time.Now(),
			UpdatedAt: time.Now(),
		})
	}

	// Seed de Perfis de acesso padrão
	var countPerfis int64
	db.Model(&domain.Perfil{}).Count(&countPerfis)
	if countPerfis == 0 {
		log.Println("Criando perfis de acesso padrão...")
		db.Create(&domain.Perfil{
			ID:        "perfil-super-admin",
			Nome:      "Super Admin",
			Descricao: "Acesso total ao sistema sem restrições",
			Permissoes: domain.JSONB(`["*"]`),
			IsSistema:  true,
			CreatedAt:  time.Now(),
			UpdatedAt:  time.Now(),
		})
		db.Create(&domain.Perfil{
			ID:        "perfil-admin",
			Nome:      "Administrador",
			Descricao: "Acesso administrativo completo ao sistema",
			Permissoes: domain.JSONB(`["clients.read","clients.write","proposals.read","proposals.write","companies.read","companies.write","dashboard.read","settings.read"]`),
			IsSistema:  true,
			CreatedAt:  time.Now(),
			UpdatedAt:  time.Now(),
		})
		db.Create(&domain.Perfil{
			ID:        "perfil-operator",
			Nome:      "Operador",
			Descricao: "Acesso de leitura e operações básicas",
			Permissoes: domain.JSONB(`["clients.read","proposals.read","companies.read","dashboard.read"]`),
			IsSistema:  false,
			CreatedAt:  time.Now(),
			UpdatedAt:  time.Now(),
		})
	}

	// Seed do usuário Super Admin padrão
	var countUsers int64
	db.Model(&domain.Usuario{}).Count(&countUsers)
	if countUsers == 0 {
		log.Println("Criando usuário super admin padrão (admin@sistema.com / admin123)...")
		// SHA-256 of "admin123"
		senhaHash := "240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9"
		db.Create(&domain.Usuario{
			ID:        "usuario-super-admin",
			Nome:      "Administrador",
			Email:     "admin@sistema.com",
			SenhaHash: senhaHash,
			PerfilID:  "perfil-super-admin",
			Ativo:     true,
			CreatedAt: time.Now(),
			UpdatedAt: time.Now(),
		})
	}

	// Configuração das camadas (KISS: Repositórios e Serviços de Domínio)
	clientRepo := repository.NewSQLiteClienteRepository(db)
	proposalRepo := repository.NewSQLitePropostaRepository(db)
	companyRepo := repository.NewSQLiteEmpresaRepository(db)
	configRepo := repository.NewSQLiteConfiguracaoRepository(db)
	analysisRepo := repository.NewSQLitePedidoAnaliseRepository(db)
	tipoPropostaRepo := repository.NewSQLiteTipoPropostaRepository(db)
	perfilRepo := repository.NewSQLitePerfilRepository(db)
	usuarioRepo := repository.NewSQLiteUsuarioRepository(db)

	clientService := service.NewClienteService(clientRepo)
	proposalService := service.NewPropostaService(proposalRepo, clientRepo, configRepo, tipoPropostaRepo)
	companyService := service.NewEmpresaService(companyRepo)
	configService := service.NewConfiguracaoService(configRepo)
	tipoPropostaService := service.NewTipoPropostaService(tipoPropostaRepo, proposalRepo)
	supervisorService := service.NewSupervisorService(analysisRepo, clientService, proposalService, companyService, configRepo)
	perfilService := service.NewPerfilService(perfilRepo, usuarioRepo)
	usuarioService := service.NewUsuarioService(usuarioRepo, perfilRepo)

	h := handler.NewHandler(
		clientService,
		proposalService,
		companyService,
		configService,
		supervisorService,
		tipoPropostaService,
		perfilService,
		usuarioService,
	)

	// Configuração do Roteador Chi
	r := chi.NewRouter()
	r.Use(middleware.Logger)
	r.Use(middleware.Recoverer)

	// Configuração do CORS
	corsMiddleware := cors.New(cors.Options{
		AllowedOrigins:   cfg.AllowedOrigins,
		AllowedMethods:   []string{"GET", "POST", "PUT", "DELETE", "OPTIONS"},
		AllowedHeaders:   []string{"Accept", "Authorization", "Content-Type", "X-CSRF-Token", "X-User-ID"},
		ExposedHeaders:   []string{"Link"},
		AllowCredentials: true,
		MaxAge:           300,
	})
	r.Use(corsMiddleware.Handler)

	h.Routes(r)

	// Inicia o servidor HTTP
	addr := fmt.Sprintf(":%s", cfg.Port)
	log.Printf("Servidor backend rodando em http://localhost%s", addr)
	if err := http.ListenAndServe(addr, r); err != nil {
		log.Fatalf("Erro ao iniciar o servidor HTTP: %v", err)
	}
}

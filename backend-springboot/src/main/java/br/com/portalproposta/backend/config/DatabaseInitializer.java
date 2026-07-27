package br.com.portalproposta.backend.config;

import br.com.portalproposta.backend.model.*;
import br.com.portalproposta.backend.repository.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.Arrays;
import java.util.List;

@Component
public class DatabaseInitializer implements CommandLineRunner {

    private final PropostaRepository propostaRepository;
    private final ConfiguracaoRepository configuracaoRepository;
    private final TipoPropostaRepository tipoPropostaRepository;
    private final PerfilRepository perfilRepository;
    private final UsuarioRepository usuarioRepository;

    @Autowired
    public DatabaseInitializer(PropostaRepository propostaRepository,
            ConfiguracaoRepository configuracaoRepository,
            TipoPropostaRepository tipoPropostaRepository,
            PerfilRepository perfilRepository,
            UsuarioRepository usuarioRepository) {
        this.propostaRepository = propostaRepository;
        this.configuracaoRepository = configuracaoRepository;
        this.tipoPropostaRepository = tipoPropostaRepository;
        this.perfilRepository = perfilRepository;
        this.usuarioRepository = usuarioRepository;
    }

    @Override
    @Transactional
    public void run(String... args) throws Exception {
        // Perform Legacies Migration
        tipoPropostaRepository.findByChave("CompraVenda").ifPresent(legacyType -> {
            legacyType.setNome("Comissionados (PVA)");
            legacyType.setChave("Comissionados");
            tipoPropostaRepository.save(legacyType);
        });

        // Convert proposals types from Buy/Sell legacy name
        List<Proposta> legacyProposals = propostaRepository.findAll().stream()
                .filter(p -> "CompraVenda".equals(p.getTipo()))
                .toList();
        for (Proposta p : legacyProposals) {
            p.setTipo("Comissionados");
            propostaRepository.save(p);
        }

        tipoPropostaRepository.findByChave("Comissionados").ifPresent(comissionadosType -> {
            comissionadosType.setNome("Comissionados (PVA)");
            tipoPropostaRepository.save(comissionadosType);
        });

        // Settings seeds
        if (!configuracaoRepository.existsById("taxa_corretagem")) {
            configuracaoRepository.save(Configuracao.builder().chave("taxa_corretagem").valor("5.00").build());
        }
        if (!configuracaoRepository.existsById("senha_supervisor")) {
            configuracaoRepository.save(Configuracao.builder().chave("senha_supervisor").valor("123").build());
        }

        // Proposal Types seeds
        if (tipoPropostaRepository.count() == 0) {
            List<CampoTipoProposta> imobCampos = Arrays.asList(
                    new CampoTipoProposta("Endereço Completo do Imóvel", "endereco_imovel", "text", true),
                    new CampoTipoProposta("Tipo do Imóvel", "tipo_imovel", "text", true),
                    new CampoTipoProposta("Área Privativa (m²)", "area_m2", "number", true));
            tipoPropostaRepository.save(TipoProposta.builder()
                    .id("1")
                    .nome("Imobiliária")
                    .chave("Imobiliaria")
                    .campos(imobCampos)
                    .createdAt(LocalDateTime.now())
                    .updatedAt(LocalDateTime.now())
                    .build());

            List<CampoTipoProposta> autoCampos = Arrays.asList(
                    new CampoTipoProposta("Marca", "marca", "text", true),
                    new CampoTipoProposta("Modelo", "modelo", "text", true),
                    new CampoTipoProposta("Ano de Fabricação", "ano", "number", true),
                    new CampoTipoProposta("Placa do Veículo", "placa", "text", true));
            tipoPropostaRepository.save(TipoProposta.builder()
                    .id("2")
                    .nome("Automotiva")
                    .chave("Auto")
                    .campos(autoCampos)
                    .createdAt(LocalDateTime.now())
                    .updatedAt(LocalDateTime.now())
                    .build());

            List<CampoTipoProposta> comissionadosCampos = Arrays.asList(
                    new CampoTipoProposta("Descrição dos Itens / Serviços", "itens", "text", true),
                    new CampoTipoProposta("Condições de Pagamento", "condicoes_pagamento", "text", true));
            tipoPropostaRepository.save(TipoProposta.builder()
                    .id("3")
                    .nome("Comissionados (PVA)")
                    .chave("Comissionados")
                    .campos(comissionadosCampos)
                    .createdAt(LocalDateTime.now())
                    .updatedAt(LocalDateTime.now())
                    .build());
        }

        // Profiles seeds
        if (perfilRepository.count() == 0) {
            perfilRepository.save(Perfil.builder()
                    .id("perfil-super-admin")
                    .nome("Super Admin")
                    .descricao("Acesso total ao sistema sem restrições")
                    .permissoes(Arrays.asList("*"))
                    .isSistema(true)
                    .createdAt(LocalDateTime.now())
                    .updatedAt(LocalDateTime.now())
                    .build());

            perfilRepository.save(Perfil.builder()
                    .id("perfil-admin")
                    .nome("Administrador")
                    .descricao("Acesso administrativo completo ao sistema")
                    .permissoes(Arrays.asList("clients.read", "clients.write", "proposals.read", "proposals.write",
                            "companies.read", "companies.write", "dashboard.read", "settings.read"))
                    .isSistema(true)
                    .createdAt(LocalDateTime.now())
                    .updatedAt(LocalDateTime.now())
                    .build());

            perfilRepository.save(Perfil.builder()
                    .id("perfil-operator")
                    .nome("Operador")
                    .descricao("Acesso de leitura e operações básicas")
                    .permissoes(Arrays.asList("clients.read", "proposals.read", "companies.read", "dashboard.read"))
                    .isSistema(false)
                    .createdAt(LocalDateTime.now())
                    .updatedAt(LocalDateTime.now())
                    .build());
        }

        // Default admin user seed
        if (usuarioRepository.count() == 0) {
            usuarioRepository.save(Usuario.builder()
                    .id("usuario-super-admin")
                    .nome("Administrador")
                    .email("admin@sistema.com")
                    .senhaHash("240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9")
                    .perfilId("perfil-super-admin")
                    .ativo(true)
                    .createdAt(LocalDateTime.now())
                    .updatedAt(LocalDateTime.now())
                    .build());
        }
    }
}

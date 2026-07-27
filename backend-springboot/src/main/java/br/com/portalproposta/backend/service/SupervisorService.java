package br.com.portalproposta.backend.service;

import br.com.portalproposta.backend.exception.AppBadRequestException;
import br.com.portalproposta.backend.exception.AppNotFoundException;
import br.com.portalproposta.backend.model.PedidoAnalise;
import br.com.portalproposta.backend.model.Proposta;
import br.com.portalproposta.backend.repository.PedidoAnaliseRepository;
import tools.jackson.core.JacksonException;
import tools.jackson.databind.JsonNode;
import tools.jackson.databind.ObjectMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

@Service
public class SupervisorService {

    private final PedidoAnaliseRepository pedidoAnaliseRepository;
    private final ClienteService clienteService;
    private final PropostaService propostaService;
    private final ObjectMapper objectMapper = new ObjectMapper();

    @Autowired
    public SupervisorService(PedidoAnaliseRepository pedidoAnaliseRepository,
            ClienteService clienteService,
            PropostaService propostaService) {
        this.pedidoAnaliseRepository = pedidoAnaliseRepository;
        this.clienteService = clienteService;
        this.propostaService = propostaService;
    }

    public List<PedidoAnalise> listAll() {
        return pedidoAnaliseRepository.findAllByOrderByCreatedAtDesc();
    }

    public List<PedidoAnalise> listPendentes() {
        return pedidoAnaliseRepository.findByStatusOrderByCreatedAtDesc("Pendente");
    }

    @Transactional
    public PedidoAnalise createRequest(PedidoAnalise request) {
        request.setId(UUID.randomUUID().toString());
        request.setStatus("Pendente");
        request.setCreatedAt(LocalDateTime.now());
        request.setUpdatedAt(LocalDateTime.now());

        return pedidoAnaliseRepository.save(request);
    }

    @Transactional
    public void approveRequest(String id) {
        PedidoAnalise pedido = pedidoAnaliseRepository.findById(id)
                .orElseThrow(() -> new AppNotFoundException("pedido de análise não encontrado"));

        if (!"Pendente".equals(pedido.getStatus())) {
            throw new AppBadRequestException("este pedido de análise já foi processado");
        }

        String dadosJson = pedido.getDadosAcao() != null ? pedido.getDadosAcao() : "{}";

        try {
            JsonNode root = objectMapper.readTree(dadosJson);

            switch (pedido.getTipoAcao()) {
                case "AprovarProposta": {
                    if (root.get("proposta_id") == null || root.get("proposta_id").asText().isEmpty()) {
                        throw new AppBadRequestException("dados da ação inválidos para aprovar proposta");
                    }
                    String propostaId = root.get("proposta_id").asText();
                    Proposta prop = propostaService.getById(propostaId);
                    prop.setStatus("Aprovada");
                    propostaService.handleBrokerageCommission(prop);
                    propostaService.update(prop.getId(), prop);
                    break;
                }
                case "EncaminharEmpresa": {
                    if (root.get("proposta_id") == null || root.get("proposta_id").asText().isEmpty() ||
                            root.get("empresa_id") == null || root.get("empresa_id").asText().isEmpty()) {
                        throw new AppBadRequestException("dados da ação inválidos para encaminhar empresa");
                    }
                    String propostaId = root.get("proposta_id").asText();
                    String empresaId = root.get("empresa_id").asText();

                    Proposta prop = propostaService.getById(propostaId);
                    prop.setEmpresaId(empresaId);
                    prop.setStatusCorretagem("Encaminhada");
                    propostaService.handleBrokerageCommission(prop);
                    propostaService.update(prop.getId(), prop);
                    break;
                }
                case "DeletarCliente": {
                    if (root.get("cliente_id") == null || root.get("cliente_id").asText().isEmpty()) {
                        throw new AppBadRequestException("dados da ação inválidos para deletar cliente");
                    }
                    String clienteId = root.get("cliente_id").asText();
                    clienteService.delete(clienteId);
                    break;
                }
                case "DeletarProposta": {
                    if (root.get("proposta_id") == null || root.get("proposta_id").asText().isEmpty()) {
                        throw new AppBadRequestException("dados da ação inválidos para deletar proposta");
                    }
                    String propostaId = root.get("proposta_id").asText();
                    propostaService.delete(propostaId);
                    break;
                }
                default:
                    throw new AppBadRequestException("tipo de ação do supervisor não suportado");
            }
        } catch (JacksonException e) {
            throw new AppBadRequestException("dados da ação malformados ou inválidos");
        }

        pedido.setStatus("Aprovado");
        pedido.setUpdatedAt(LocalDateTime.now());
        pedidoAnaliseRepository.save(pedido);
    }

    @Transactional
    public void rejectRequest(String id) {
        PedidoAnalise pedido = pedidoAnaliseRepository.findById(id)
                .orElseThrow(() -> new AppNotFoundException("pedido de análise não encontrado"));

        if (!"Pendente".equals(pedido.getStatus())) {
            throw new AppBadRequestException("este pedido de análise já foi processado");
        }

        pedido.setStatus("Recusado");
        pedido.setUpdatedAt(LocalDateTime.now());
        pedidoAnaliseRepository.save(pedido);
    }
}

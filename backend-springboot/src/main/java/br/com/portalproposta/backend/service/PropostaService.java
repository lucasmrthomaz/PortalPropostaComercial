package br.com.portalproposta.backend.service;

import br.com.portalproposta.backend.exception.AppBadRequestException;
import br.com.portalproposta.backend.exception.AppNotFoundException;
import br.com.portalproposta.backend.model.CampoTipoProposta;
import br.com.portalproposta.backend.model.Proposta;
import br.com.portalproposta.backend.model.TipoProposta;
import br.com.portalproposta.backend.repository.ClienteRepository;
import br.com.portalproposta.backend.repository.EmpresaRepository;
import br.com.portalproposta.backend.repository.PropostaRepository;
import br.com.portalproposta.backend.repository.TipoPropostaRepository;
import tools.jackson.databind.JsonNode;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

@Service
public class PropostaService {

    private final PropostaRepository propostaRepository;
    private final ClienteRepository clienteRepository;
    private final TipoPropostaRepository tipoPropostaRepository;
    private final EmpresaRepository empresaRepository;
    private final ConfiguracaoService configuracaoService;

    @Autowired
    public PropostaService(PropostaRepository propostaRepository,
            ClienteRepository clienteRepository,
            TipoPropostaRepository tipoPropostaRepository,
            EmpresaRepository empresaRepository,
            ConfiguracaoService configuracaoService) {
        this.propostaRepository = propostaRepository;
        this.clienteRepository = clienteRepository;
        this.tipoPropostaRepository = tipoPropostaRepository;
        this.empresaRepository = empresaRepository;
        this.configuracaoService = configuracaoService;
    }

    public List<Proposta> list() {
        return propostaRepository.findAll();
    }

    public List<Proposta> listByClienteId(String clienteId) {
        if (!clienteRepository.existsById(clienteId)) {
            throw new AppNotFoundException("cliente não encontrado");
        }
        return propostaRepository.findByClienteId(clienteId);
    }

    public Proposta getById(String id) {
        return propostaRepository.findById(id)
                .orElseThrow(() -> new AppNotFoundException("proposta não encontrada"));
    }

    @Transactional
    public Proposta create(Proposta proposal) {
        if (!clienteRepository.existsById(proposal.getClienteId())) {
            throw new AppNotFoundException("cliente não encontrado");
        }

        TipoProposta tipoProposta = tipoPropostaRepository.findByChave(proposal.getTipo())
                .orElseThrow(() -> new AppBadRequestException(
                        "tipo de proposta inválido (use Imobiliaria, Auto ou Comissionados)"));

        if (proposal.getValor() <= 0) {
            throw new AppBadRequestException("valor da proposta deve ser maior que zero");
        }

        validateDynamicFields(tipoProposta, proposal.getDadosEspecificos());

        proposal.setId(UUID.randomUUID().toString());
        if (proposal.getStatus() == null || proposal.getStatus().trim().isEmpty()) {
            proposal.setStatus("Pendente");
        }

        handleBrokerageCommission(proposal);

        proposal.setCreatedAt(LocalDateTime.now());
        proposal.setUpdatedAt(LocalDateTime.now());

        Proposta saved = propostaRepository.save(proposal);
        loadRelations(saved);
        return saved;
    }

    @Transactional
    public Proposta update(String id, Proposta input) {
        Proposta proposal = getById(id);

        if (input.getTipo() != null && !input.getTipo().trim().isEmpty()) {
            TipoProposta tipoProposta = tipoPropostaRepository.findByChave(input.getTipo())
                    .orElseThrow(() -> new AppBadRequestException(
                            "tipo de proposta inválido (use Imobiliaria, Auto ou Comissionados)"));

            validateDynamicFields(tipoProposta, input.getDadosEspecificos());
            proposal.setTipo(input.getTipo());
        }

        if (input.getValor() <= 0) {
            throw new AppBadRequestException("valor da proposta deve ser maior que zero");
        }

        proposal.setValor(input.getValor());
        proposal.setStatus(input.getStatus());
        proposal.setDescricao(input.getDescricao());
        proposal.setDadosEspecificos(input.getDadosEspecificos());
        proposal.setEmpresaId(input.getEmpresaId());
        proposal.setStatusCorretagem(input.getStatusCorretagem());

        handleBrokerageCommission(proposal);

        proposal.setUpdatedAt(LocalDateTime.now());

        Proposta saved = propostaRepository.save(proposal);
        loadRelations(saved);
        return saved;
    }

    @Transactional
    public void delete(String id) {
        Proposta proposal = getById(id);
        propostaRepository.delete(proposal);
    }

    public void handleBrokerageCommission(Proposta p) {
        if (p.getEmpresaId() != null
                && ("FechadaComSucesso".equals(p.getStatusCorretagem()) || "Aprovada".equals(p.getStatus()))) {
            p.setStatusCorretagem("FechadaComSucesso");
            double taxa = configuracaoService.getCommissionRate();
            double value = p.getValor() * (taxa / 100.0);
            BigDecimal decimalValue = new BigDecimal(value).setScale(2, RoundingMode.HALF_UP);
            p.setValorComissao(decimalValue.doubleValue());
        } else if (p.getEmpresaId() != null) {
            p.setStatusCorretagem("Encaminhada");
            p.setValorComissao(0);
        } else {
            p.setStatusCorretagem("Pendente");
            p.setValorComissao(0);
        }
    }

    private void loadRelations(Proposta p) {
        if (p.getEmpresaId() != null) {
            p.setEmpresa(empresaRepository.findById(p.getEmpresaId()).orElse(null));
        } else {
            p.setEmpresa(null);
        }
    }

    private void validateDynamicFields(TipoProposta tipo, JsonNode dadosEspecificos) {
        if ("Imobiliaria".equals(tipo.getChave()) || "Auto".equals(tipo.getChave())
                || "Comissionados".equals(tipo.getChave())) {
            return;
        }

        boolean hasData = dadosEspecificos != null && dadosEspecificos.isObject();

        for (CampoTipoProposta campo : tipo.getCampos()) {
            boolean exists = hasData && dadosEspecificos.has(campo.getChave());
            JsonNode propValue = exists ? dadosEspecificos.get(campo.getChave()) : null;

            if (campo.isObrigatorio()) {
                if (propValue == null || propValue.isNull() || propValue.isMissingNode()) {
                    throw new AppBadRequestException(String.format("o campo '%s' é obrigatório", campo.getNome()));
                }
                if (propValue.isTextual() && propValue.asText().trim().isEmpty()) {
                    throw new AppBadRequestException(String.format("o campo '%s' é obrigatório", campo.getNome()));
                }
            }

            if (exists && propValue != null && !propValue.isNull() && !propValue.isMissingNode()) {
                if ("number".equals(campo.getTipo())) {
                    if (!propValue.isNumber()) {
                        if (propValue.isTextual()) {
                            try {
                                Double.parseDouble(propValue.asText());
                            } catch (NumberFormatException e) {
                                throw new AppBadRequestException(
                                        String.format("o campo '%s' deve ser um número", campo.getNome()));
                            }
                        } else {
                            throw new AppBadRequestException(
                                    String.format("o campo '%s' deve ser um número", campo.getNome()));
                        }
                    }
                } else if ("boolean".equals(campo.getTipo())) {
                    if (!propValue.isBoolean()) {
                        if (propValue.isTextual()) {
                            String text = propValue.asText();
                            if (!"true".equals(text) && !"false".equals(text)) {
                                throw new AppBadRequestException(
                                        String.format("o campo '%s' deve ser verdadeiro ou falso", campo.getNome()));
                            }
                        } else {
                            throw new AppBadRequestException(
                                    String.format("o campo '%s' deve ser verdadeiro ou falso", campo.getNome()));
                        }
                    }
                }
            }
        }
    }
}

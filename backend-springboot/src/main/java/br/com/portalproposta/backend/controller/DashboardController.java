package br.com.portalproposta.backend.controller;

import br.com.portalproposta.backend.model.Cliente;
import br.com.portalproposta.backend.model.Empresa;
import br.com.portalproposta.backend.model.Proposta;
import br.com.portalproposta.backend.service.ClienteService;
import br.com.portalproposta.backend.service.ConfiguracaoService;
import br.com.portalproposta.backend.service.EmpresaService;
import br.com.portalproposta.backend.service.PropostaService;
import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/dashboard")
public class DashboardController {

    private final ClienteService clienteService;
    private final PropostaService propostaService;
    private final EmpresaService empresaService;
    private final ConfiguracaoService configuracaoService;

    @Autowired
    public DashboardController(ClienteService clienteService,
            PropostaService propostaService,
            EmpresaService empresaService,
            ConfiguracaoService configuracaoService) {
        this.clienteService = clienteService;
        this.propostaService = propostaService;
        this.empresaService = empresaService;
        this.configuracaoService = configuracaoService;
    }

    @Data
    public static class DashboardStatsExtended {
        @JsonProperty("total_clients")
        private int totalClients;

        @JsonProperty("total_proposals")
        private int totalProposals;

        @JsonProperty("total_companies")
        private int totalCompanies;

        @JsonProperty("total_value")
        private double totalValue;

        @JsonProperty("closed_commissions_value")
        private double closedCommissionsValue;

        @JsonProperty("pending_commissions_value")
        private double pendingCommissionsValue;

        @JsonProperty("proposals_by_status")
        private Map<String, Integer> proposalsByStatus = new HashMap<>();

        @JsonProperty("proposals_by_type")
        private Map<String, Integer> proposalsByType = new HashMap<>();

        @JsonProperty("value_by_status")
        private Map<String, Double> valueByStatus = new HashMap<>();

        @JsonProperty("value_by_type")
        private Map<String, Double> valueByType = new HashMap<>();
    }

    @GetMapping("/stats")
    public ResponseEntity<DashboardStatsExtended> getStats() {
        List<Cliente> clients = clienteService.list();
        List<Proposta> proposals = propostaService.list();
        List<Empresa> companies = empresaService.list();
        double rate = configuracaoService.getCommissionRate();

        DashboardStatsExtended stats = new DashboardStatsExtended();
        stats.setTotalClients(clients.size());
        stats.setTotalProposals(proposals.size());
        stats.setTotalCompanies(companies.size());
        stats.setTotalValue(0);
        stats.setClosedCommissionsValue(0);
        stats.setPendingCommissionsValue(0);

        for (Proposta p : proposals) {
            stats.setTotalValue(stats.getTotalValue() + p.getValor());

            String statusStr = p.getStatus() != null ? p.getStatus() : "Pendente";
            String tipoStr = p.getTipo() != null ? p.getTipo() : "";

            // Prop stats by Status
            stats.getProposalsByStatus().put(statusStr, stats.getProposalsByStatus().getOrDefault(statusStr, 0) + 1);

            // Prop stats by Type
            stats.getProposalsByType().put(tipoStr, stats.getProposalsByType().getOrDefault(tipoStr, 0) + 1);

            // Value by Status
            stats.getValueByStatus().put(statusStr,
                    stats.getValueByStatus().getOrDefault(statusStr, 0.0) + p.getValor());

            // Value by Type
            stats.getValueByType().put(tipoStr, stats.getValueByType().getOrDefault(tipoStr, 0.0) + p.getValor());

            if (p.getEmpresaId() != null) {
                if ("FechadaComSucesso".equals(p.getStatusCorretagem())) {
                    stats.setClosedCommissionsValue(stats.getClosedCommissionsValue() + p.getValorComissao());
                } else if ("Encaminhada".equals(p.getStatusCorretagem())) {
                    stats.setPendingCommissionsValue(
                            stats.getPendingCommissionsValue() + (p.getValor() * (rate / 100.0)));
                }
            }
        }

        return ResponseEntity.ok(stats);
    }
}

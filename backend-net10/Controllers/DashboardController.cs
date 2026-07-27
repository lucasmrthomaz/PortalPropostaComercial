using Microsoft.AspNetCore.Mvc;
using backend_net10.Services;
using System.Text.Json.Serialization;

namespace backend_net10.Controllers;

[ApiController]
[Route("api/dashboard")]
public class DashboardController : ControllerBase
{
    private readonly ClienteService _clienteService;
    private readonly PropostaService _propostaService;
    private readonly EmpresaService _companyService;
    private readonly ConfiguracaoService _configService;

    public DashboardController(
        ClienteService clienteService,
        PropostaService propostaService,
        EmpresaService companyService,
        ConfiguracaoService configService)
    {
        _clienteService = clienteService;
        _propostaService = propostaService;
        _companyService = companyService;
        _configService = configService;
    }

    public class DashboardStatsExtended
    {
        [JsonPropertyName("total_clients")]
        public int TotalClients { get; set; }

        [JsonPropertyName("total_proposals")]
        public int TotalProposals { get; set; }

        [JsonPropertyName("total_companies")]
        public int TotalCompanies { get; set; }

        [JsonPropertyName("total_value")]
        public double TotalValue { get; set; }

        [JsonPropertyName("closed_commissions_value")]
        public double ClosedCommissionsValue { get; set; }

        [JsonPropertyName("pending_commissions_value")]
        public double PendingCommissionsValue { get; set; }

        [JsonPropertyName("proposals_by_status")]
        public Dictionary<string, int> ProposalsByStatus { get; set; } = new();

        [JsonPropertyName("proposals_by_type")]
        public Dictionary<string, int> ProposalsByType { get; set; } = new();

        [JsonPropertyName("value_by_status")]
        public Dictionary<string, double> ValueByStatus { get; set; } = new();

        [JsonPropertyName("value_by_type")]
        public Dictionary<string, double> ValueByType { get; set; } = new();
    }

    [HttpGet("stats")]
    public async Task<ActionResult<DashboardStatsExtended>> GetStats()
    {
        var clients = await _clienteService.ListAsync();
        var proposals = await _propostaService.ListAsync();
        var companies = await _companyService.ListAsync();
        var rate = await _configService.GetCommissionRateAsync();

        var stats = new DashboardStatsExtended
        {
            TotalClients = clients.Count,
            TotalProposals = proposals.Count,
            TotalCompanies = companies.Count,
            TotalValue = 0,
            ClosedCommissionsValue = 0,
            PendingCommissionsValue = 0
        };

        foreach (var p in proposals)
        {
            stats.TotalValue += p.Valor;

            var statusStr = p.Status ?? "Pendente";
            var tipoStr = p.Tipo ?? "";

            // Prop stats by Status
            if (!stats.ProposalsByStatus.ContainsKey(statusStr))
                stats.ProposalsByStatus[statusStr] = 0;
            stats.ProposalsByStatus[statusStr]++;

            // Prop stats by Type
            if (!stats.ProposalsByType.ContainsKey(tipoStr))
                stats.ProposalsByType[tipoStr] = 0;
            stats.ProposalsByType[tipoStr]++;

            // Value by Status
            if (!stats.ValueByStatus.ContainsKey(statusStr))
                stats.ValueByStatus[statusStr] = 0;
            stats.ValueByStatus[statusStr] += p.Valor;

            // Value by Type
            if (!stats.ValueByType.ContainsKey(tipoStr))
                stats.ValueByType[tipoStr] = 0;
            stats.ValueByType[tipoStr] += p.Valor;

            if (p.EmpresaId != null)
            {
                if (p.StatusCorretagem == "FechadaComSucesso")
                {
                    stats.ClosedCommissionsValue += p.ValorComissao;
                }
                else if (p.StatusCorretagem == "Encaminhada")
                {
                    stats.PendingCommissionsValue += p.Valor * (rate / 100.0);
                }
            }
        }

        return Ok(stats);
    }
}

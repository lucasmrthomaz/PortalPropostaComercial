using Microsoft.AspNetCore.Mvc;
using PortalProposta.Services;
using System.Text.Json.Serialization;

namespace PortalProposta.Controllers;

[ApiController]
[Route("api/dashboard")]
public class DashboardController(
    ClienteService clienteService,
    PropostaService propostaService,
    EmpresaService companyService,
    ConfiguracaoService configService) : ControllerBase
{
    public class DashboardStatsExtended
    {
        [JsonPropertyName("total_clients")] public int TotalClients { get; set; }
        [JsonPropertyName("total_proposals")] public int TotalProposals { get; set; }
        [JsonPropertyName("total_companies")] public int TotalCompanies { get; set; }
        [JsonPropertyName("total_value")] public double TotalValue { get; set; }
        [JsonPropertyName("closed_commissions_value")] public double ClosedCommissionsValue { get; set; }
        [JsonPropertyName("pending_commissions_value")] public double PendingCommissionsValue { get; set; }
        [JsonPropertyName("proposals_by_status")] public Dictionary<string, int> ProposalsByStatus { get; set; } = new();
        [JsonPropertyName("proposals_by_type")] public Dictionary<string, int> ProposalsByType { get; set; } = new();
        [JsonPropertyName("value_by_status")] public Dictionary<string, double> ValueByStatus { get; set; } = new();
        [JsonPropertyName("value_by_type")] public Dictionary<string, double> ValueByType { get; set; } = new();
    }

    [HttpGet("stats")]
    public async Task<ActionResult<DashboardStatsExtended>> GetStats()
    {
        var clients = await clienteService.ListAsync();
        var proposals = await propostaService.ListAsync();
        var companies = await companyService.ListAsync();
        var rate = await configService.GetCommissionRateAsync();

        var stats = new DashboardStatsExtended
        {
            TotalClients = clients.Count,
            TotalProposals = proposals.Count,
            TotalCompanies = companies.Count
        };

        foreach (var p in proposals)
        {
            stats.TotalValue += p.Valor;

            var status = p.Status ?? "Pendente";
            var tipo = p.Tipo ?? "";

            IncrementDict(stats.ProposalsByStatus, status);
            IncrementDict(stats.ProposalsByType, tipo);
            AddToDict(stats.ValueByStatus, status, p.Valor);
            AddToDict(stats.ValueByType, tipo, p.Valor);

            if (p.EmpresaId is not null)
            {
                if (p.StatusCorretagem == "FechadaComSucesso")
                    stats.ClosedCommissionsValue += p.ValorComissao;
                else if (p.StatusCorretagem == "Encaminhada")
                    stats.PendingCommissionsValue += p.Valor * (rate / 100.0);
            }
        }

        return Ok(stats);
    }

    private static void IncrementDict(Dictionary<string, int> dict, string key)
    {
        dict.TryGetValue(key, out var count);
        dict[key] = count + 1;
    }

    private static void AddToDict(Dictionary<string, double> dict, string key, double value)
    {
        dict.TryGetValue(key, out var current);
        dict[key] = current + value;
    }
}

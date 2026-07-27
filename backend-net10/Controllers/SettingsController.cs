using Microsoft.AspNetCore.Mvc;
using backend_net10.Services;
using System.Text.Json.Serialization;

namespace backend_net10.Controllers;

[ApiController]
[Route("api/settings")]
public class SettingsController : ControllerBase
{
    private readonly ConfiguracaoService _configService;

    public SettingsController(ConfiguracaoService configService)
    {
        _configService = configService;
    }

    public class SettingsResponse
    {
        [JsonPropertyName("taxa_corretagem")]
        public double TaxaCorretagem { get; set; }
    }

    public class SettingsUpdateRequest
    {
        [JsonPropertyName("taxa_corretagem")]
        public double? TaxaCorretagem { get; set; }

        [JsonPropertyName("senha_supervisor")]
        public string? SenhaSupervisor { get; set; }
    }

    [HttpGet]
    public async Task<ActionResult<SettingsResponse>> Get()
    {
        var rate = await _configService.GetCommissionRateAsync();
        return Ok(new SettingsResponse { TaxaCorretagem = rate });
    }

    [HttpPut]
    public async Task<IActionResult> Update(SettingsUpdateRequest req)
    {
        if (req.TaxaCorretagem.HasValue)
        {
            await _configService.UpdateCommissionRateAsync(req.TaxaCorretagem.Value);
        }

        if (req.SenhaSupervisor != null)
        {
            await _configService.UpdateSupervisorPasswordAsync(req.SenhaSupervisor);
        }

        return Ok(new { message = "Configurações atualizadas com sucesso" });
    }
}

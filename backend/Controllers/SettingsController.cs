using Microsoft.AspNetCore.Mvc;
using PortalProposta.Services;
using System.Text.Json.Serialization;

namespace PortalProposta.Controllers;

[ApiController]
[Route("api/settings")]
public class SettingsController(ConfiguracaoService configService) : ControllerBase
{
    public record SettingsResponse([property: JsonPropertyName("taxa_corretagem")] double TaxaCorretagem);

    public record SettingsUpdateRequest(
        [property: JsonPropertyName("taxa_corretagem")] double? TaxaCorretagem,
        [property: JsonPropertyName("senha_supervisor")] string? SenhaSupervisor);

    [HttpGet]
    public async Task<ActionResult<SettingsResponse>> Get() =>
        Ok(new SettingsResponse(await configService.GetCommissionRateAsync()));

    [HttpPut]
    public async Task<IActionResult> Update(SettingsUpdateRequest req)
    {
        if (req.TaxaCorretagem.HasValue)
            await configService.UpdateCommissionRateAsync(req.TaxaCorretagem.Value);

        if (req.SenhaSupervisor is not null)
            await configService.UpdateSupervisorPasswordAsync(req.SenhaSupervisor);

        return Ok(new { message = "Configurações atualizadas com sucesso" });
    }
}

using Microsoft.AspNetCore.Mvc;
using PortalProposta.Models;
using PortalProposta.Services;
using System.Text.Json.Serialization;

namespace PortalProposta.Controllers;

[ApiController]
[Route("api/supervisor")]
public class SupervisorController(SupervisorService supervisorService, ConfiguracaoService configService) : ControllerBase
{
    public record VerifyPasswordRequest([property: JsonPropertyName("password")] string Password);
    public record VerifyPasswordResponse([property: JsonPropertyName("valid")] bool Valid);

    [HttpPost("verify-password")]
    public async Task<ActionResult<VerifyPasswordResponse>> VerifyPassword(VerifyPasswordRequest req)
    {
        try
        {
            await configService.VerifySupervisorPasswordAsync(req.Password);
            return Ok(new VerifyPasswordResponse(true));
        }
        catch (AppBadRequestException)
        {
            return Ok(new VerifyPasswordResponse(false));
        }
    }

    [HttpGet("requests")]
    public async Task<ActionResult<List<PedidoAnalise>>> ListRequests([FromQuery] string? status)
    {
        var requests = status == "Pendente"
            ? await supervisorService.ListPendentesAsync()
            : await supervisorService.ListAllAsync();
        return Ok(requests);
    }

    [HttpPost("requests")]
    public async Task<ActionResult<PedidoAnalise>> CreateRequest(PedidoAnalise request) =>
        CreatedAtAction(nameof(ListRequests), await supervisorService.CreateRequestAsync(request));

    [HttpPost("requests/{id}/approve")]
    public async Task<IActionResult> ApproveRequest(string id)
    {
        await supervisorService.ApproveRequestAsync(id);
        return Ok(new { message = "Solicitação aprovada e executada com sucesso" });
    }

    [HttpPost("requests/{id}/reject")]
    public async Task<IActionResult> RejectRequest(string id)
    {
        await supervisorService.RejectRequestAsync(id);
        return Ok(new { message = "Solicitação rejeitada com sucesso" });
    }
}

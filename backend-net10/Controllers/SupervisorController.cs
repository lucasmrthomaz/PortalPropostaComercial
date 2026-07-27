using Microsoft.AspNetCore.Mvc;
using backend_net10.Models;
using backend_net10.Services;
using System.Text.Json.Serialization;

namespace backend_net10.Controllers;

[ApiController]
[Route("api/supervisor")]
public class SupervisorController : ControllerBase
{
    private readonly SupervisorService _supervisorService;
    private readonly ConfiguracaoService _configService;

    public SupervisorController(SupervisorService supervisorService, ConfiguracaoService configService)
    {
        _supervisorService = supervisorService;
        _configService = configService;
    }

    public class VerifyPasswordRequest
    {
        [JsonPropertyName("password")]
        public string Password { get; set; } = string.Empty;
    }

    public class VerifyPasswordResponse
    {
        [JsonPropertyName("valid")]
        public bool Valid { get; set; }
    }

    [HttpPost("verify-password")]
    public async Task<ActionResult<VerifyPasswordResponse>> VerifyPassword(VerifyPasswordRequest req)
    {
        try
        {
            await _configService.VerifySupervisorPasswordAsync(req.Password);
            return Ok(new VerifyPasswordResponse { Valid = true });
        }
        catch (AppBadRequestException)
        {
            return Ok(new VerifyPasswordResponse { Valid = false });
        }
    }

    [HttpGet("requests")]
    public async Task<ActionResult<List<PedidoAnalise>>> ListRequests([FromQuery] string? status)
    {
        List<PedidoAnalise> requests;
        if (status == "Pendente")
        {
            requests = await _supervisorService.ListPendentesAsync();
        }
        else
        {
            requests = await _supervisorService.ListAllAsync();
        }
        return Ok(requests);
    }

    [HttpPost("requests")]
    public async Task<ActionResult<PedidoAnalise>> CreateRequest(PedidoAnalise request)
    {
        var created = await _supervisorService.CreateRequestAsync(request);
        return CreatedAtAction(nameof(ListRequests), created); // Simple redirect/created mapping
    }

    [HttpPost("requests/{id}/approve")]
    public async Task<IActionResult> ApproveRequest(string id)
    {
        await _supervisorService.ApproveRequestAsync(id);
        return Ok(new { message = "Solicitação aprovada e executada com sucesso" });
    }

    [HttpPost("requests/{id}/reject")]
    public async Task<IActionResult> RejectRequest(string id)
    {
        await _supervisorService.RejectRequestAsync(id);
        return Ok(new { message = "Solicitação rejeitada com sucesso" });
    }
}

using Microsoft.AspNetCore.Mvc;
using backend_net10.Models;
using backend_net10.Services;
using System.Text.Json.Serialization;

namespace backend_net10.Controllers;

[ApiController]
[Route("api/auth")]
public class AuthController : ControllerBase
{
    private readonly UsuarioService _usuarioService;

    public AuthController(UsuarioService usuarioService)
    {
        _usuarioService = usuarioService;
    }

    public class LoginRequest
    {
        [JsonPropertyName("email")]
        public string Email { get; set; } = string.Empty;

        [JsonPropertyName("senha")]
        public string Senha { get; set; } = string.Empty;
    }

    [HttpPost("login")]
    public async Task<ActionResult<UsuarioResponse>> Login(LoginRequest req)
    {
        var user = await _usuarioService.LoginAsync(req.Email, req.Senha);
        return Ok(user.ToResponse());
    }
}

using Microsoft.AspNetCore.Mvc;
using PortalProposta.Models;
using PortalProposta.Services;
using System.Text.Json.Serialization;

namespace PortalProposta.Controllers;

[ApiController]
[Route("api/auth")]
public class AuthController(UsuarioService usuarioService) : ControllerBase
{
    public record LoginRequest(
        [property: JsonPropertyName("email")] string Email,
        [property: JsonPropertyName("senha")] string Senha);

    [HttpPost("login")]
    public async Task<ActionResult<UsuarioResponse>> Login(LoginRequest req) =>
        Ok((await usuarioService.LoginAsync(req.Email, req.Senha)).ToResponse());
}

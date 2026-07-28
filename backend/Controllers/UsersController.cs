using Microsoft.AspNetCore.Mvc;
using PortalProposta.Models;
using PortalProposta.Services;
using System.Text.Json.Serialization;

namespace PortalProposta.Controllers;

[ApiController]
[Route("api/users")]
public class UsersController(UsuarioService usuarioService) : ControllerBase
{
    public record CreateUsuarioRequest(
        [property: JsonPropertyName("nome")] string Nome,
        [property: JsonPropertyName("email")] string Email,
        [property: JsonPropertyName("senha")] string Senha,
        [property: JsonPropertyName("perfil_id")] string PerfilId,
        [property: JsonPropertyName("ativo")] bool Ativo);

    public record UpdateUsuarioRequest(
        [property: JsonPropertyName("nome")] string Nome,
        [property: JsonPropertyName("email")] string Email,
        [property: JsonPropertyName("senha")] string? Senha,
        [property: JsonPropertyName("perfil_id")] string PerfilId,
        [property: JsonPropertyName("ativo")] bool Ativo);

    [HttpGet]
    public async Task<ActionResult<List<UsuarioResponse>>> List()
    {
        var users = await usuarioService.ListAsync();
        return Ok(users.Select(u => u.ToResponse()).ToList());
    }

    [HttpPost]
    public async Task<ActionResult<UsuarioResponse>> Create(CreateUsuarioRequest req)
    {
        var user = new Usuario
        {
            Nome = req.Nome,
            Email = req.Email,
            PerfilId = req.PerfilId,
            Ativo = req.Ativo
        };
        var created = await usuarioService.CreateAsync(user, req.Senha);
        return CreatedAtAction(nameof(Get), new { id = created.Id }, created.ToResponse());
    }

    [HttpGet("{id}")]
    public async Task<ActionResult<UsuarioResponse>> Get(string id) =>
        Ok((await usuarioService.GetByIdAsync(id)).ToResponse());

    [HttpPut("{id}")]
    public async Task<ActionResult<UsuarioResponse>> Update(string id, UpdateUsuarioRequest req)
    {
        var input = new Usuario
        {
            Nome = req.Nome,
            Email = req.Email,
            PerfilId = req.PerfilId,
            Ativo = req.Ativo
        };
        return Ok((await usuarioService.UpdateAsync(id, input, req.Senha)).ToResponse());
    }

    [HttpDelete("{id}")]
    public async Task<IActionResult> Delete(string id)
    {
        await usuarioService.DeleteAsync(id);
        return Ok(new { message = "Usuário excluído com sucesso" });
    }
}

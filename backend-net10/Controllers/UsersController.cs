using Microsoft.AspNetCore.Mvc;
using backend_net10.Models;
using backend_net10.Services;
using System.Text.Json.Serialization;

namespace backend_net10.Controllers;

[ApiController]
[Route("api/users")]
public class UsersController : ControllerBase
{
    private readonly UsuarioService _usuarioService;

    public UsersController(UsuarioService usuarioService)
    {
        _usuarioService = usuarioService;
    }

    public class CreateUsuarioRequest
    {
        [JsonPropertyName("nome")]
        public string Nome { get; set; } = string.Empty;

        [JsonPropertyName("email")]
        public string Email { get; set; } = string.Empty;

        [JsonPropertyName("senha")]
        public string Senha { get; set; } = string.Empty;

        [JsonPropertyName("perfil_id")]
        public string PerfilId { get; set; } = string.Empty;

        [JsonPropertyName("ativo")]
        public bool Ativo { get; set; }
    }

    public class UpdateUsuarioRequest
    {
        [JsonPropertyName("nome")]
        public string Nome { get; set; } = string.Empty;

        [JsonPropertyName("email")]
        public string Email { get; set; } = string.Empty;

        [JsonPropertyName("senha")]
        public string? Senha { get; set; } // optional

        [JsonPropertyName("perfil_id")]
        public string PerfilId { get; set; } = string.Empty;

        [JsonPropertyName("ativo")]
        public bool Ativo { get; set; }
    }

    [HttpGet]
    public async Task<ActionResult<List<UsuarioResponse>>> List()
    {
        var users = await _usuarioService.ListAsync();
        var response = users.Select(u => u.ToResponse()).ToList();
        return Ok(response);
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

        var created = await _usuarioService.CreateAsync(user, req.Senha);
        return CreatedAtAction(nameof(Get), new { id = created.Id }, created.ToResponse());
    }

    [HttpGet("{id}")]
    public async Task<ActionResult<UsuarioResponse>> Get(string id)
    {
        var user = await _usuarioService.GetByIdAsync(id);
        return Ok(user.ToResponse());
    }

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

        var updated = await _usuarioService.UpdateAsync(id, input, req.Senha);
        return Ok(updated.ToResponse());
    }

    [HttpDelete("{id}")]
    public async Task<IActionResult> Delete(string id)
    {
        await _usuarioService.DeleteAsync(id);
        return Ok(new { message = "Usuário excluído com sucesso" });
    }
}

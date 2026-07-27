using Microsoft.AspNetCore.Mvc;
using backend_net10.Models;
using backend_net10.Services;

namespace backend_net10.Controllers;

[ApiController]
[Route("api/profiles")]
public class ProfilesController : ControllerBase
{
    private readonly PerfilService _perfilService;

    public ProfilesController(PerfilService perfilService)
    {
        _perfilService = perfilService;
    }

    [HttpGet]
    public async Task<ActionResult<List<Perfil>>> List()
    {
        var profiles = await _perfilService.ListAsync();
        return Ok(profiles);
    }

    [HttpPost]
    public async Task<ActionResult<Perfil>> Create(Perfil perfil)
    {
        var created = await _perfilService.CreateAsync(perfil);
        return CreatedAtAction(nameof(Get), new { id = created.Id }, created);
    }

    [HttpGet("{id}")]
    public async Task<ActionResult<Perfil>> Get(string id)
    {
        var profile = await _perfilService.GetByIdAsync(id);
        return Ok(profile);
    }

    [HttpPut("{id}")]
    public async Task<ActionResult<Perfil>> Update(string id, Perfil perfil)
    {
        var updated = await _perfilService.UpdateAsync(id, perfil);
        return Ok(updated);
    }

    [HttpDelete("{id}")]
    public async Task<IActionResult> Delete(string id)
    {
        await _perfilService.DeleteAsync(id);
        return Ok(new { message = "Perfil excluído com sucesso" });
    }
}

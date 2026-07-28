using Microsoft.AspNetCore.Mvc;
using PortalProposta.Models;
using PortalProposta.Services;

namespace PortalProposta.Controllers;

[ApiController]
[Route("api/profiles")]
public class ProfilesController(PerfilService perfilService) : ControllerBase
{
    [HttpGet]
    public async Task<ActionResult<List<Perfil>>> List() =>
        Ok(await perfilService.ListAsync());

    [HttpPost]
    public async Task<ActionResult<Perfil>> Create(Perfil perfil) =>
        CreatedAtAction(nameof(Get), new { id = (await perfilService.CreateAsync(perfil)).Id }, perfil);

    [HttpGet("{id}")]
    public async Task<ActionResult<Perfil>> Get(string id) =>
        Ok(await perfilService.GetByIdAsync(id));

    [HttpPut("{id}")]
    public async Task<ActionResult<Perfil>> Update(string id, Perfil perfil) =>
        Ok(await perfilService.UpdateAsync(id, perfil));

    [HttpDelete("{id}")]
    public async Task<IActionResult> Delete(string id)
    {
        await perfilService.DeleteAsync(id);
        return Ok(new { message = "Perfil excluído com sucesso" });
    }
}

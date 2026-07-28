using Microsoft.AspNetCore.Mvc;
using PortalProposta.Models;
using PortalProposta.Services;

namespace PortalProposta.Controllers;

[ApiController]
[Route("api/clients")]
public class ClientsController(ClienteService clienteService) : ControllerBase
{
    [HttpGet]
    public async Task<ActionResult<List<Cliente>>> List() =>
        Ok(await clienteService.ListAsync());

    [HttpPost]
    public async Task<ActionResult<Cliente>> Create(Cliente client) =>
        CreatedAtAction(nameof(Get), new { id = (await clienteService.CreateAsync(client)).Id }, client);

    [HttpGet("{id}")]
    public async Task<ActionResult<Cliente>> Get(string id) =>
        Ok(await clienteService.GetByIdAsync(id));

    [HttpPut("{id}")]
    public async Task<ActionResult<Cliente>> Update(string id, Cliente client) =>
        Ok(await clienteService.UpdateAsync(id, client));

    [HttpDelete("{id}")]
    public async Task<IActionResult> Delete(string id)
    {
        await clienteService.DeleteAsync(id);
        return Ok(new { message = "Cliente deletado com sucesso" });
    }

    [HttpGet("{id}/proposals")]
    public async Task<ActionResult<List<Proposta>>> ListProposals(string id) =>
        Ok((await clienteService.GetByIdAsync(id)).Propostas);
}

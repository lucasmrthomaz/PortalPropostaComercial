using Microsoft.AspNetCore.Mvc;
using backend_net10.Models;
using backend_net10.Services;

namespace backend_net10.Controllers;

[ApiController]
[Route("api/clients")]
public class ClientsController : ControllerBase
{
    private readonly ClienteService _clienteService;

    public ClientsController(ClienteService clienteService)
    {
        _clienteService = clienteService;
    }

    [HttpGet]
    public async Task<ActionResult<List<Cliente>>> List()
    {
        var clients = await _clienteService.ListAsync();
        return Ok(clients);
    }

    [HttpPost]
    public async Task<ActionResult<Cliente>> Create(Cliente client)
    {
        var created = await _clienteService.CreateAsync(client);
        return CreatedAtAction(nameof(Get), new { id = created.Id }, created);
    }

    [HttpGet("{id}")]
    public async Task<ActionResult<Cliente>> Get(string id)
    {
        var client = await _clienteService.GetByIdAsync(id);
        return Ok(client);
    }

    [HttpPut("{id}")]
    public async Task<ActionResult<Cliente>> Update(string id, Cliente client)
    {
        var updated = await _clienteService.UpdateAsync(id, client);
        return Ok(updated);
    }

    [HttpDelete("{id}")]
    public async Task<IActionResult> Delete(string id)
    {
        await _clienteService.DeleteAsync(id);
        return Ok(new { message = "Cliente deletado com sucesso" });
    }

    [HttpGet("{id}/proposals")]
    public async Task<ActionResult<List<Proposta>>> ListProposals(string id)
    {
        var proposals = await _clienteService.GetByIdAsync(id);
        return Ok(proposals.Propostas);
    }
}

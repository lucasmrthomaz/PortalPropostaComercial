using Microsoft.AspNetCore.Mvc;
using backend_net10.Models;
using backend_net10.Services;

namespace backend_net10.Controllers;

[ApiController]
[Route("api/proposals")]
public class ProposalsController : ControllerBase
{
    private readonly PropostaService _propostaService;

    public ProposalsController(PropostaService propostaService)
    {
        _propostaService = propostaService;
    }

    [HttpGet]
    public async Task<ActionResult<List<Proposta>>> List()
    {
        var proposals = await _propostaService.ListAsync();
        return Ok(proposals);
    }

    [HttpPost]
    public async Task<ActionResult<Proposta>> Create(Proposta proposal)
    {
        var created = await _propostaService.CreateAsync(proposal);
        return CreatedAtAction(nameof(Get), new { id = created.Id }, created);
    }

    [HttpGet("{id}")]
    public async Task<ActionResult<Proposta>> Get(string id)
    {
        var proposal = await _propostaService.GetByIdAsync(id);
        return Ok(proposal);
    }

    [HttpPut("{id}")]
    public async Task<ActionResult<Proposta>> Update(string id, Proposta proposal)
    {
        var updated = await _propostaService.UpdateAsync(id, proposal);
        return Ok(updated);
    }

    [HttpDelete("{id}")]
    public async Task<IActionResult> Delete(string id)
    {
        await _propostaService.DeleteAsync(id);
        return Ok(new { message = "Proposta deletada com sucesso" });
    }
}

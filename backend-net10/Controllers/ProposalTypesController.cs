using Microsoft.AspNetCore.Mvc;
using backend_net10.Models;
using backend_net10.Services;

namespace backend_net10.Controllers;

[ApiController]
[Route("api/proposal-types")]
public class ProposalTypesController : ControllerBase
{
    private readonly TipoPropostaService _proposalTypeService;

    public ProposalTypesController(TipoPropostaService proposalTypeService)
    {
        _proposalTypeService = proposalTypeService;
    }

    [HttpGet]
    public async Task<ActionResult<List<TipoProposta>>> List()
    {
        var types = await _proposalTypeService.ListAsync();
        return Ok(types);
    }

    [HttpPost]
    public async Task<ActionResult<TipoProposta>> Create(TipoProposta tipo)
    {
        var created = await _proposalTypeService.CreateAsync(tipo);
        return CreatedAtAction(nameof(Get), new { id = created.Id }, created);
    }

    [HttpGet("{id}")]
    public async Task<ActionResult<TipoProposta>> Get(string id)
    {
        var type = await _proposalTypeService.GetByIdAsync(id);
        return Ok(type);
    }

    [HttpPut("{id}")]
    public async Task<ActionResult<TipoProposta>> Update(string id, TipoProposta tipo)
    {
        var updated = await _proposalTypeService.UpdateAsync(id, tipo);
        return Ok(updated);
    }

    [HttpDelete("{id}")]
    public async Task<IActionResult> Delete(string id)
    {
        await _proposalTypeService.DeleteAsync(id);
        return Ok(new { message = "Tipo de proposta excluído com sucesso" });
    }
}

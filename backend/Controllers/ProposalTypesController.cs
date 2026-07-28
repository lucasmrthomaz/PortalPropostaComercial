using Microsoft.AspNetCore.Mvc;
using PortalProposta.Models;
using PortalProposta.Services;

namespace PortalProposta.Controllers;

[ApiController]
[Route("api/proposal-types")]
public class ProposalTypesController(TipoPropostaService proposalTypeService) : ControllerBase
{
    [HttpGet]
    public async Task<ActionResult<List<TipoProposta>>> List() =>
        Ok(await proposalTypeService.ListAsync());

    [HttpPost]
    public async Task<ActionResult<TipoProposta>> Create(TipoProposta tipo) =>
        CreatedAtAction(nameof(Get), new { id = (await proposalTypeService.CreateAsync(tipo)).Id }, tipo);

    [HttpGet("{id}")]
    public async Task<ActionResult<TipoProposta>> Get(string id) =>
        Ok(await proposalTypeService.GetByIdAsync(id));

    [HttpPut("{id}")]
    public async Task<ActionResult<TipoProposta>> Update(string id, TipoProposta tipo) =>
        Ok(await proposalTypeService.UpdateAsync(id, tipo));

    [HttpDelete("{id}")]
    public async Task<IActionResult> Delete(string id)
    {
        await proposalTypeService.DeleteAsync(id);
        return Ok(new { message = "Tipo de proposta excluído com sucesso" });
    }
}

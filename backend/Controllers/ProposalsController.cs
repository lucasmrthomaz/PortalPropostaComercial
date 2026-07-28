using Microsoft.AspNetCore.Mvc;
using PortalProposta.Models;
using PortalProposta.Services;
using System.Text.Json.Serialization;

namespace PortalProposta.Controllers;

[ApiController]
[Route("api/proposals")]
public class ProposalsController(PropostaService propostaService) : ControllerBase
{
    [HttpGet]
    public async Task<ActionResult<List<Proposta>>> List() =>
        Ok(await propostaService.ListAsync());

    [HttpPost]
    public async Task<ActionResult<Proposta>> Create(Proposta proposal) =>
        CreatedAtAction(nameof(Get), new { id = (await propostaService.CreateAsync(proposal)).Id }, proposal);

    [HttpGet("{id}")]
    public async Task<ActionResult<Proposta>> Get(string id) =>
        Ok(await propostaService.GetByIdAsync(id));

    [HttpPut("{id}")]
    public async Task<ActionResult<Proposta>> Update(string id, Proposta proposal) =>
        Ok(await propostaService.UpdateAsync(id, proposal));

    [HttpDelete("{id}")]
    public async Task<IActionResult> Delete(string id)
    {
        await propostaService.DeleteAsync(id);
        return Ok(new { message = "Proposta deletada com sucesso" });
    }
}

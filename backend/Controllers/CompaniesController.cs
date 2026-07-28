using Microsoft.AspNetCore.Mvc;
using PortalProposta.Models;
using PortalProposta.Services;

namespace PortalProposta.Controllers;

[ApiController]
[Route("api/companies")]
public class CompaniesController(EmpresaService companyService) : ControllerBase
{
    [HttpGet]
    public async Task<ActionResult<List<Empresa>>> List() =>
        Ok(await companyService.ListAsync());

    [HttpPost]
    public async Task<ActionResult<Empresa>> Create(Empresa company) =>
        CreatedAtAction(nameof(Get), new { id = (await companyService.CreateAsync(company)).Id }, company);

    [HttpGet("{id}")]
    public async Task<ActionResult<Empresa>> Get(string id) =>
        Ok(await companyService.GetByIdAsync(id));

    [HttpPut("{id}")]
    public async Task<ActionResult<Empresa>> Update(string id, Empresa company) =>
        Ok(await companyService.UpdateAsync(id, company));

    [HttpDelete("{id}")]
    public async Task<IActionResult> Delete(string id)
    {
        await companyService.DeleteAsync(id);
        return Ok(new { message = "Empresa parceira deletada com sucesso" });
    }
}

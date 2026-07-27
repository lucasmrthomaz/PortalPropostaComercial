using Microsoft.AspNetCore.Mvc;
using backend_net10.Models;
using backend_net10.Services;

namespace backend_net10.Controllers;

[ApiController]
[Route("api/companies")]
public class CompaniesController : ControllerBase
{
    private readonly EmpresaService _companyService;

    public CompaniesController(EmpresaService companyService)
    {
        _companyService = companyService;
    }

    [HttpGet]
    public async Task<ActionResult<List<Empresa>>> List()
    {
        var companies = await _companyService.ListAsync();
        return Ok(companies);
    }

    [HttpPost]
    public async Task<ActionResult<Empresa>> Create(Empresa company)
    {
        var created = await _companyService.CreateAsync(company);
        return CreatedAtAction(nameof(Get), new { id = created.Id }, created);
    }

    [HttpGet("{id}")]
    public async Task<ActionResult<Empresa>> Get(string id)
    {
        var company = await _companyService.GetByIdAsync(id);
        return Ok(company);
    }

    [HttpPut("{id}")]
    public async Task<ActionResult<Empresa>> Update(string id, Empresa company)
    {
        var updated = await _companyService.UpdateAsync(id, company);
        return Ok(updated);
    }

    [HttpDelete("{id}")]
    public async Task<IActionResult> Delete(string id)
    {
        await _companyService.DeleteAsync(id);
        return Ok(new { message = "Empresa parceira deletada com sucesso" });
    }
}

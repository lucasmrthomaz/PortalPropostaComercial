using Microsoft.EntityFrameworkCore;
using PortalProposta.Data;
using PortalProposta.Models;

namespace PortalProposta.Services;

public class EmpresaService(AppDbContext context)
{
    public async Task<List<Empresa>> ListAsync() =>
        await context.Empresas.ToListAsync();

    public async Task<Empresa> GetByIdAsync(string id) =>
        await context.Empresas.FirstOrDefaultAsync(e => e.Id == id)
            ?? throw new AppNotFoundException("empresa parceira não encontrada");

    public async Task<Empresa> CreateAsync(Empresa company)
    {
        Validate.Empresa(company);

        company.CNPJ = Validation.CleanCPFCNPJ(company.CNPJ);
        if (!Validation.IsValidCNPJ(company.CNPJ))
            throw new AppBadRequestException("CNPJ inválido");

        if (await context.Empresas.AnyAsync(e => e.CNPJ == company.CNPJ))
            throw new AppBadRequestException("empresa com este CNPJ já cadastrada");

        company.Id = Guid.NewGuid().ToString();
        company.Ativo = true;
        company.CreatedAt = company.UpdatedAt = DateTime.Now;

        context.Empresas.Add(company);
        await context.SaveChangesAsync();
        return company;
    }

    public async Task<Empresa> UpdateAsync(string id, Empresa input)
    {
        var company = await context.Empresas.FirstOrDefaultAsync(e => e.Id == id)
            ?? throw new AppNotFoundException("empresa parceira não encontrada");

        Validate.Empresa(input);

        var cleanCNPJ = Validation.CleanCPFCNPJ(input.CNPJ);
        if (cleanCNPJ != company.CNPJ)
        {
            if (!Validation.IsValidCNPJ(cleanCNPJ))
                throw new AppBadRequestException("CNPJ inválido");

            if (await context.Empresas.AnyAsync(e => e.CNPJ == cleanCNPJ && e.Id != company.Id))
                throw new AppBadRequestException("empresa com este CNPJ já cadastrada");

            company.CNPJ = cleanCNPJ;
        }

        company.Nome = input.Nome;
        company.Email = input.Email;
        company.Telefone = input.Telefone;
        company.ResponsavelNome = input.ResponsavelNome;
        company.ResponsavelEmail = input.ResponsavelEmail;
        company.ResponsavelTelefone = input.ResponsavelTelefone;
        company.Ativo = input.Ativo;
        company.UpdatedAt = DateTime.Now;

        await context.SaveChangesAsync();
        return company;
    }

    public async Task DeleteAsync(string id)
    {
        var company = await context.Empresas.FirstOrDefaultAsync(e => e.Id == id)
            ?? throw new AppNotFoundException("empresa parceira não encontrada");

        context.Empresas.Remove(company);
        await context.SaveChangesAsync();
    }
}

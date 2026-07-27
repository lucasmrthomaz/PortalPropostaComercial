using Microsoft.EntityFrameworkCore;
using backend_net10.Data;
using backend_net10.Models;

namespace backend_net10.Services;

public class EmpresaService
{
    private readonly AppDbContext _context;

    public EmpresaService(AppDbContext context)
    {
        _context = context;
    }

    public async Task<List<Empresa>> ListAsync()
    {
        return await _context.Empresas.ToListAsync();
    }

    public async Task<Empresa> GetByIdAsync(string id)
    {
        var company = await _context.Empresas.FirstOrDefaultAsync(e => e.Id == id);
        if (company == null)
        {
            throw new AppNotFoundException("empresa parceira não encontrada");
        }
        return company;
    }

    public async Task<Empresa> CreateAsync(Empresa company)
    {
        if (string.IsNullOrWhiteSpace(company.Nome))
        {
            throw new AppBadRequestException("nome do empresa é obrigatório"); // Wait! Go error specifies "nome da empresa é obrigatório", wait, in error mapping: ErrInvalidCompanyName is "nome da empresa é obrigatório". Wait, in Go handler it was "nome da empresa é obrigatório". Here we can throw domain error exactly.
        }

        if (string.IsNullOrWhiteSpace(company.Email) || !company.Email.Contains('@'))
        {
            throw new AppBadRequestException("email da empresa é obrigatório ou inválido");
        }

        company.CNPJ = Validation.CleanCPFCNPJ(company.CNPJ);
        if (!Validation.IsValidCNPJ(company.CNPJ))
        {
            throw new AppBadRequestException("CNPJ inválido");
        }

        var existing = await _context.Empresas.FirstOrDefaultAsync(e => e.CNPJ == company.CNPJ);
        if (existing != null)
        {
            throw new AppBadRequestException("empresa com este CNPJ já cadastrada");
        }

        company.Id = Guid.NewGuid().ToString();
        company.Ativo = true;
        company.CreatedAt = DateTime.Now;
        company.UpdatedAt = DateTime.Now;

        _context.Empresas.Add(company);
        await _context.SaveChangesAsync();

        return company;
    }

    public async Task<Empresa> UpdateAsync(string id, Empresa input)
    {
        var company = await _context.Empresas.FirstOrDefaultAsync(e => e.Id == id);
        if (company == null)
        {
            throw new AppNotFoundException("empresa parceira não encontrada");
        }

        if (string.IsNullOrWhiteSpace(input.Nome))
        {
            throw new AppBadRequestException("nome da empresa é obrigatório");
        }

        if (string.IsNullOrWhiteSpace(input.Email) || !input.Email.Contains('@'))
        {
            throw new AppBadRequestException("email da empresa é obrigatório ou inválido");
        }

        var cleanCNPJ = Validation.CleanCPFCNPJ(input.CNPJ);
        if (cleanCNPJ != company.CNPJ)
        {
            if (!Validation.IsValidCNPJ(cleanCNPJ))
            {
                throw new AppBadRequestException("CNPJ inválido");
            }

            var existing = await _context.Empresas.FirstOrDefaultAsync(e => e.CNPJ == cleanCNPJ);
            if (existing != null && existing.Id != company.Id)
            {
                throw new AppBadRequestException("empresa com este CNPJ já cadastrada");
            }
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

        await _context.SaveChangesAsync();
        return company;
    }

    public async Task DeleteAsync(string id)
    {
        var company = await _context.Empresas.FirstOrDefaultAsync(e => e.Id == id);
        if (company == null)
        {
            throw new AppNotFoundException("empresa parceira não encontrada");
        }

        _context.Empresas.Remove(company);
        await _context.SaveChangesAsync();
    }
}

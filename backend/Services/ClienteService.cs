using Microsoft.EntityFrameworkCore;
using PortalProposta.Data;
using PortalProposta.Models;

namespace PortalProposta.Services;

public class ClienteService(AppDbContext context)
{
    public async Task<List<Cliente>> ListAsync() =>
        await context.Clientes.ToListAsync();

    public async Task<Cliente> GetByIdAsync(string id)
    {
        var client = await context.Clientes
            .Include(c => c.Propostas!)
                .ThenInclude(p => p.Empresa)
            .FirstOrDefaultAsync(c => c.Id == id)
            ?? throw new AppNotFoundException("cliente não encontrado");
        return client;
    }

    public async Task<Cliente> CreateAsync(Cliente client)
    {
        Validate.Cliente(client);

        client.CPFCNPJ = Validation.CleanCPFCNPJ(client.CPFCNPJ);
        if (!Validation.IsValidCPFCNPJ(client.CPFCNPJ))
            throw new AppBadRequestException("CPF ou CNPJ inválido");

        if (await context.Clientes.AnyAsync(c => c.CPFCNPJ == client.CPFCNPJ))
            throw new AppBadRequestException("cliente com este CPF/CNPJ já cadastrado");

        client.Id = Guid.NewGuid().ToString();
        client.CreatedAt = client.UpdatedAt = DateTime.Now;

        context.Clientes.Add(client);
        await context.SaveChangesAsync();
        return client;
    }

    public async Task<Cliente> UpdateAsync(string id, Cliente input)
    {
        var client = await context.Clientes.FirstOrDefaultAsync(c => c.Id == id)
            ?? throw new AppNotFoundException("cliente não encontrado");

        Validate.Cliente(input);

        var cleanCPF = Validation.CleanCPFCNPJ(input.CPFCNPJ);
        if (cleanCPF != client.CPFCNPJ)
        {
            if (!Validation.IsValidCPFCNPJ(cleanCPF))
                throw new AppBadRequestException("CPF ou CNPJ inválido");

            if (await context.Clientes.AnyAsync(c => c.CPFCNPJ == cleanCPF && c.Id != client.Id))
                throw new AppBadRequestException("cliente com este CPF/CNPJ já cadastrado");

            client.CPFCNPJ = cleanCPF;
        }

        client.Nome = input.Nome;
        client.Email = input.Email;
        client.Telefone = input.Telefone;
        client.Endereco = input.Endereco;
        client.UpdatedAt = DateTime.Now;

        await context.SaveChangesAsync();
        return client;
    }

    public async Task DeleteAsync(string id)
    {
        var client = await context.Clientes.FirstOrDefaultAsync(c => c.Id == id)
            ?? throw new AppNotFoundException("cliente não encontrado");

        context.Clientes.Remove(client);
        await context.SaveChangesAsync();
    }
}

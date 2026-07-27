using Microsoft.EntityFrameworkCore;
using backend_net10.Data;
using backend_net10.Models;

namespace backend_net10.Services;

public class ClienteService
{
    private readonly AppDbContext _context;

    public ClienteService(AppDbContext context)
    {
        _context = context;
    }

    public async Task<List<Cliente>> ListAsync()
    {
        return await _context.Clientes.ToListAsync();
    }

    public async Task<Cliente> GetByIdAsync(string id)
    {
        var client = await _context.Clientes
            .Include(c => c.Propostas!)
                .ThenInclude(p => p.Empresa)
            .FirstOrDefaultAsync(c => c.Id == id);

        if (client == null)
        {
            throw new AppNotFoundException("cliente não encontrado");
        }

        return client;
    }

    public async Task<Cliente> CreateAsync(Cliente client)
    {
        if (string.IsNullOrWhiteSpace(client.Nome))
        {
            throw new AppBadRequestException("nome do cliente é obrigatório");
        }

        if (string.IsNullOrWhiteSpace(client.Email) || !client.Email.Contains('@'))
        {
            throw new AppBadRequestException("email do cliente é obrigatório ou inválido");
        }

        client.CPFCNPJ = Validation.CleanCPFCNPJ(client.CPFCNPJ);
        if (!Validation.IsValidCPFCNPJ(client.CPFCNPJ))
        {
            throw new AppBadRequestException("CPF ou CNPJ inválido");
        }

        var existing = await _context.Clientes.FirstOrDefaultAsync(c => c.CPFCNPJ == client.CPFCNPJ);
        if (existing != null)
        {
            throw new AppBadRequestException("cliente com este CPF/CNPJ já cadastrado");
        }

        client.Id = Guid.NewGuid().ToString();
        client.CreatedAt = DateTime.Now;
        client.UpdatedAt = DateTime.Now;

        _context.Clientes.Add(client);
        await _context.SaveChangesAsync();

        return client;
    }

    public async Task<Cliente> UpdateAsync(string id, Cliente input)
    {
        var client = await _context.Clientes.FirstOrDefaultAsync(c => c.Id == id);
        if (client == null)
        {
            throw new AppNotFoundException("cliente não encontrado");
        }

        if (string.IsNullOrWhiteSpace(input.Nome))
        {
            throw new AppBadRequestException("nome do cliente é obrigatório");
        }

        if (string.IsNullOrWhiteSpace(input.Email) || !input.Email.Contains('@'))
        {
            throw new AppBadRequestException("email do cliente é obrigatório ou inválido");
        }

        var cleanCPF = Validation.CleanCPFCNPJ(input.CPFCNPJ);
        if (cleanCPF != client.CPFCNPJ)
        {
            if (!Validation.IsValidCPFCNPJ(cleanCPF))
            {
                throw new AppBadRequestException("CPF ou CNPJ inválido");
            }

            var existing = await _context.Clientes.FirstOrDefaultAsync(c => c.CPFCNPJ == cleanCPF);
            if (existing != null && existing.Id != client.Id)
            {
                throw new AppBadRequestException("cliente com este CPF/CNPJ já cadastrado");
            }
            client.CPFCNPJ = cleanCPF;
        }

        client.Nome = input.Nome;
        client.Email = input.Email;
        client.Telefone = input.Telefone;
        client.Endereco = input.Endereco;
        client.UpdatedAt = DateTime.Now;

        await _context.SaveChangesAsync();
        return client;
    }

    public async Task DeleteAsync(string id)
    {
        var client = await _context.Clientes.FirstOrDefaultAsync(c => c.Id == id);
        if (client == null)
        {
            throw new AppNotFoundException("cliente não encontrado");
        }

        _context.Clientes.Remove(client);
        await _context.SaveChangesAsync();
    }
}

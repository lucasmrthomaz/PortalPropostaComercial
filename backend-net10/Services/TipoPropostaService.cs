using Microsoft.EntityFrameworkCore;
using backend_net10.Data;
using backend_net10.Models;
using System.Text.RegularExpressions;

namespace backend_net10.Services;

public class TipoPropostaService
{
    private readonly AppDbContext _context;

    public TipoPropostaService(AppDbContext context)
    {
        _context = context;
    }

    public async Task<List<TipoProposta>> ListAsync()
    {
        return await _context.TiposProposta.OrderBy(t => t.Nome).ToListAsync();
    }

    public async Task<TipoProposta> GetByIdAsync(string id)
    {
        var type = await _context.TiposProposta.FirstOrDefaultAsync(t => t.Id == id);
        if (type == null)
        {
            throw new AppNotFoundException("tipo de proposta não encontrado");
        }
        return type;
    }

    public async Task<TipoProposta> CreateAsync(TipoProposta tipo)
    {
        if (string.IsNullOrWhiteSpace(tipo.Nome))
        {
            throw new AppBadRequestException("o nome do tipo de proposta é obrigatório");
        }

        if (string.IsNullOrWhiteSpace(tipo.Chave))
        {
            throw new AppBadRequestException("a chave do tipo de proposta é obrigatória");
        }

        tipo.Chave = Regex.Replace(tipo.Chave, @"[^a-zA-Z0-9]", "");
        if (string.IsNullOrEmpty(tipo.Chave))
        {
            throw new AppBadRequestException("a chave do tipo de proposta deve conter caracteres alfanuméricos");
        }

        var existing = await _context.TiposProposta.FirstOrDefaultAsync(t => t.Chave == tipo.Chave);
        if (existing != null)
        {
            throw new AppBadRequestException("já existe um tipo de proposta com esta chave");
        }

        tipo.Id = Guid.NewGuid().ToString();
        tipo.CreatedAt = DateTime.Now;
        tipo.UpdatedAt = DateTime.Now;

        _context.TiposProposta.Add(tipo);
        await _context.SaveChangesAsync();

        return tipo;
    }

    public async Task<TipoProposta> UpdateAsync(string id, TipoProposta input)
    {
        var tipo = await _context.TiposProposta.FirstOrDefaultAsync(t => t.Id == id);
        if (tipo == null)
        {
            throw new AppNotFoundException("tipo de proposta não encontrado");
        }

        if (string.IsNullOrWhiteSpace(input.Nome))
        {
            throw new AppBadRequestException("o nome do tipo de proposta é obrigatório");
        }

        bool isLegacy = tipo.Chave == "Imobiliaria" || tipo.Chave == "Auto" || tipo.Chave == "Comissionados";

        if (!isLegacy && !string.IsNullOrWhiteSpace(input.Chave) && input.Chave != tipo.Chave)
        {
            var newChave = Regex.Replace(input.Chave, @"[^a-zA-Z0-9]", "");
            if (string.IsNullOrEmpty(newChave))
            {
                throw new AppBadRequestException("a chave do tipo de proposta deve conter caracteres alfanuméricos");
            }

            var existing = await _context.TiposProposta.FirstOrDefaultAsync(t => t.Chave == newChave);
            if (existing != null && existing.Id != tipo.Id)
            {
                throw new AppBadRequestException("já existe um tipo de proposta com esta chave");
            }
            tipo.Chave = newChave;
        }

        tipo.Nome = input.Nome;
        tipo.Campos = input.Campos;
        tipo.UpdatedAt = DateTime.Now;

        await _context.SaveChangesAsync();
        return tipo;
    }

    public async Task DeleteAsync(string id)
    {
        var tipo = await _context.TiposProposta.FirstOrDefaultAsync(t => t.Id == id);
        if (tipo == null)
        {
            throw new AppNotFoundException("tipo de proposta não encontrado");
        }

        if (tipo.Chave == "Imobiliaria" || tipo.Chave == "Auto" || tipo.Chave == "Comissionados")
        {
            throw new AppBadRequestException("não é permitido excluir tipos de proposta do sistema");
        }

        var count = await _context.Propostas.CountAsync(p => p.Tipo == tipo.Chave);
        if (count > 0)
        {
            throw new AppBadRequestException($"não é possível excluir este tipo de proposta pois existem {count} proposta(s) associada(s) a ele");
        }

        _context.TiposProposta.Remove(tipo);
        await _context.SaveChangesAsync();
    }
}

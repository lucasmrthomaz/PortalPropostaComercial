using System.Text.RegularExpressions;
using Microsoft.EntityFrameworkCore;
using PortalProposta.Data;
using PortalProposta.Models;

namespace PortalProposta.Services;

public class TipoPropostaService(AppDbContext context)
{
    public async Task<List<TipoProposta>> ListAsync() =>
        await context.TiposProposta.OrderBy(t => t.Nome).ToListAsync();

    public async Task<TipoProposta> GetByIdAsync(string id) =>
        await context.TiposProposta.FirstOrDefaultAsync(t => t.Id == id)
            ?? throw new AppNotFoundException("tipo de proposta não encontrado");

    public async Task<TipoProposta> CreateAsync(TipoProposta tipo)
    {
        Validate.TipoPropostaNome(tipo);

        tipo.Chave = Regex.Replace(tipo.Chave, @"[^a-zA-Z0-9]", "");
        if (string.IsNullOrEmpty(tipo.Chave))
            throw new AppBadRequestException("a chave do tipo de proposta deve conter caracteres alfanuméricos");

        if (await context.TiposProposta.AnyAsync(t => t.Chave == tipo.Chave))
            throw new AppBadRequestException("já existe um tipo de proposta com esta chave");

        tipo.Id = Guid.NewGuid().ToString();
        tipo.CreatedAt = tipo.UpdatedAt = DateTime.Now;

        context.TiposProposta.Add(tipo);
        await context.SaveChangesAsync();
        return tipo;
    }

    public async Task<TipoProposta> UpdateAsync(string id, TipoProposta input)
    {
        var tipo = await context.TiposProposta.FirstOrDefaultAsync(t => t.Id == id)
            ?? throw new AppNotFoundException("tipo de proposta não encontrado");

        Validate.TipoPropostaNome(input);

        var isLegacy = tipo.Chave is "Imobiliaria" or "Auto" or "Comissionados";

        if (!isLegacy && !string.IsNullOrWhiteSpace(input.Chave) && input.Chave != tipo.Chave)
        {
            var newChave = Regex.Replace(input.Chave, @"[^a-zA-Z0-9]", "");
            if (string.IsNullOrEmpty(newChave))
                throw new AppBadRequestException("a chave do tipo de proposta deve conter caracteres alfanuméricos");

            if (await context.TiposProposta.AnyAsync(t => t.Chave == newChave && t.Id != tipo.Id))
                throw new AppBadRequestException("já existe um tipo de proposta com esta chave");

            tipo.Chave = newChave;
        }

        tipo.Nome = input.Nome;
        tipo.Campos = input.Campos;
        tipo.UpdatedAt = DateTime.Now;

        await context.SaveChangesAsync();
        return tipo;
    }

    public async Task DeleteAsync(string id)
    {
        var tipo = await context.TiposProposta.FirstOrDefaultAsync(t => t.Id == id)
            ?? throw new AppNotFoundException("tipo de proposta não encontrado");

        if (tipo.Chave is "Imobiliaria" or "Auto" or "Comissionados")
            throw new AppBadRequestException("não é permitido excluir tipos de proposta do sistema");

        var count = await context.Propostas.CountAsync(p => p.Tipo == tipo.Chave);
        if (count > 0)
            throw new AppBadRequestException($"não é possível excluir este tipo de proposta pois existem {count} proposta(s) associada(s) a ele");

        context.TiposProposta.Remove(tipo);
        await context.SaveChangesAsync();
    }
}

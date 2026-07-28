using System.Globalization;
using System.Text.Json;
using Microsoft.EntityFrameworkCore;
using PortalProposta.Data;
using PortalProposta.Models;

namespace PortalProposta.Services;

public class PropostaService(AppDbContext context)
{
    public async Task<List<Proposta>> ListAsync() =>
        await context.Propostas.Include(p => p.Empresa).ToListAsync();

    public async Task<List<Proposta>> ListByClienteIdAsync(string clienteId)
    {
        if (!await context.Clientes.AnyAsync(c => c.Id == clienteId))
            throw new AppNotFoundException("cliente não encontrado");

        return await context.Propostas
            .Include(p => p.Empresa)
            .Where(p => p.ClienteId == clienteId)
            .ToListAsync();
    }

    public async Task<Proposta> GetByIdAsync(string id) =>
        await context.Propostas.Include(p => p.Empresa).FirstOrDefaultAsync(p => p.Id == id)
            ?? throw new AppNotFoundException("proposta não encontrada");

    public async Task<Proposta> CreateAsync(Proposta proposal)
    {
        if (!await context.Clientes.AnyAsync(c => c.Id == proposal.ClienteId))
            throw new AppNotFoundException("cliente não encontrado");

        var tipoProposta = await context.TiposProposta.FirstOrDefaultAsync(t => t.Chave == proposal.Tipo)
            ?? throw new AppBadRequestException("tipo de proposta inválido (use Imobiliaria, Auto ou Comissionados)");

        if (proposal.Valor <= 0)
            throw new AppBadRequestException("valor da proposta deve ser maior que zero");

        ValidateDynamicFields(tipoProposta, proposal.DadosEspecificos);

        proposal.Id = Guid.NewGuid().ToString();
        if (string.IsNullOrWhiteSpace(proposal.Status))
            proposal.Status = "Pendente";

        await HandleBrokerageCommissionAsync(proposal);
        proposal.CreatedAt = proposal.UpdatedAt = DateTime.Now;

        context.Propostas.Add(proposal);
        await context.SaveChangesAsync();
        return proposal;
    }

    public async Task<Proposta> UpdateAsync(string id, Proposta input)
    {
        var proposal = await context.Propostas.FirstOrDefaultAsync(p => p.Id == id)
            ?? throw new AppNotFoundException("proposta não encontrada");

        if (!string.IsNullOrWhiteSpace(input.Tipo))
        {
            var tipoProposta = await context.TiposProposta.FirstOrDefaultAsync(t => t.Chave == input.Tipo)
                ?? throw new AppBadRequestException("tipo de proposta inválido");

            ValidateDynamicFields(tipoProposta, input.DadosEspecificos);
            proposal.Tipo = input.Tipo;
        }

        if (input.Valor <= 0)
            throw new AppBadRequestException("valor da proposta deve ser maior que zero");

        proposal.Valor = input.Valor;
        proposal.Status = input.Status;
        proposal.Descricao = input.Descricao;
        proposal.DadosEspecificos = input.DadosEspecificos;
        proposal.EmpresaId = input.EmpresaId;
        proposal.StatusCorretagem = input.StatusCorretagem;

        await HandleBrokerageCommissionAsync(proposal);
        proposal.UpdatedAt = DateTime.Now;

        await context.SaveChangesAsync();

        // Reload empresa association
        proposal.Empresa = proposal.EmpresaId is not null
            ? await context.Empresas.FirstOrDefaultAsync(e => e.Id == proposal.EmpresaId)
            : null;

        return proposal;
    }

    public async Task DeleteAsync(string id)
    {
        var proposal = await context.Propostas.FirstOrDefaultAsync(p => p.Id == id)
            ?? throw new AppNotFoundException("proposta não encontrada");

        context.Propostas.Remove(proposal);
        await context.SaveChangesAsync();
    }

    public async Task HandleBrokerageCommissionAsync(Proposta p)
    {
        if (p.EmpresaId is not null && (p.StatusCorretagem == "FechadaComSucesso" || p.Status == "Aprovada"))
        {
            p.StatusCorretagem = "FechadaComSucesso";
            var taxa = await GetCommissionRateAsync();
            p.ValorComissao = Math.Round(p.Valor * (taxa / 100.0), 2);
        }
        else if (p.EmpresaId is not null)
        {
            p.StatusCorretagem = "Encaminhada";
            p.ValorComissao = 0;
        }
        else
        {
            p.StatusCorretagem = "Pendente";
            p.ValorComissao = 0;
        }
    }

    private async Task<double> GetCommissionRateAsync()
    {
        var conf = await context.Configuracoes.FirstOrDefaultAsync(c => c.Chave == "taxa_corretagem");
        return conf is not null && double.TryParse(conf.Valor, NumberStyles.Any, CultureInfo.InvariantCulture, out var rate)
            ? rate
            : 5.0;
    }

    private static void ValidateDynamicFields(TipoProposta tipo, JsonElement dadosEspecificos)
    {
        if (tipo.Chave is "Imobiliaria" or "Auto" or "Comissionados")
            return;

        var hasData = dadosEspecificos.ValueKind == JsonValueKind.Object;

        foreach (var campo in tipo.Campos)
        {
            if (!hasData)
            {
                if (campo.Obrigatorio)
                    throw new AppBadRequestException($"o campo '{campo.Nome}' é obrigatório");
                continue;
            }

            var exists = dadosEspecificos.TryGetProperty(campo.Chave, out var propValue);

            if (campo.Obrigatorio)
            {
                if (!exists || propValue.ValueKind is JsonValueKind.Null or JsonValueKind.Undefined)
                    throw new AppBadRequestException($"o campo '{campo.Nome}' é obrigatório");

                if (propValue.ValueKind == JsonValueKind.String && string.IsNullOrWhiteSpace(propValue.GetString()))
                    throw new AppBadRequestException($"o campo '{campo.Nome}' é obrigatório");
            }

            if (!exists || propValue.ValueKind is JsonValueKind.Null or JsonValueKind.Undefined)
                continue;

            switch (campo.Tipo)
            {
                case "number" when propValue.ValueKind != JsonValueKind.Number:
                {
                    if (propValue.ValueKind == JsonValueKind.String &&
                        double.TryParse(propValue.GetString(), NumberStyles.Any, CultureInfo.InvariantCulture, out _))
                        break;
                    throw new AppBadRequestException($"o campo '{campo.Nome}' deve ser um número");
                }
                case "boolean" when propValue.ValueKind is not JsonValueKind.True and not JsonValueKind.False:
                {
                    if (propValue.ValueKind == JsonValueKind.String)
                    {
                        var strVal = propValue.GetString();
                        if (strVal is "true" or "false") break;
                    }
                    throw new AppBadRequestException($"o campo '{campo.Nome}' deve ser verdadeiro ou falso");
                }
            }
        }
    }
}

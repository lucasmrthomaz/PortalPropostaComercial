using Microsoft.EntityFrameworkCore;
using backend_net10.Data;
using backend_net10.Models;
using System.Text.Json;
using System.Globalization;

namespace backend_net10.Services;

public class PropostaService
{
    private readonly AppDbContext _context;

    public PropostaService(AppDbContext context)
    {
        _context = context;
    }

    public async Task<List<Proposta>> ListAsync()
    {
        return await _context.Propostas
            .Include(p => p.Empresa)
            .ToListAsync();
    }

    public async Task<List<Proposta>> ListByClienteIdAsync(string clienteId)
    {
        var clientExists = await _context.Clientes.AnyAsync(c => c.Id == clienteId);
        if (!clientExists)
        {
            throw new AppNotFoundException("cliente não encontrado");
        }

        return await _context.Propostas
            .Include(p => p.Empresa)
            .Where(p => p.ClienteId == clienteId)
            .ToListAsync();
    }

    public async Task<Proposta> GetByIdAsync(string id)
    {
        var proposal = await _context.Propostas
            .Include(p => p.Empresa)
            .FirstOrDefaultAsync(p => p.Id == id);

        if (proposal == null)
        {
            throw new AppNotFoundException("proposta não encontrada");
        }

        return proposal;
    }

    public async Task<Proposta> CreateAsync(Proposta proposal)
    {
        var clientExists = await _context.Clientes.AnyAsync(c => c.Id == proposal.ClienteId);
        if (!clientExists)
        {
            throw new AppNotFoundException("cliente não encontrado");
        }

        var tipoProposta = await _context.TiposProposta.FirstOrDefaultAsync(t => t.Chave == proposal.Tipo);
        if (tipoProposta == null)
        {
            throw new AppBadRequestException("tipo de proposta inválido (use Imobiliaria, Auto ou Comissionados)");
        }

        if (proposal.Valor <= 0)
        {
            throw new AppBadRequestException("valor da proposta deve ser maior que zero");
        }

        ValidateDynamicFields(tipoProposta, proposal.DadosEspecificos);

        proposal.Id = Guid.NewGuid().ToString();
        if (string.IsNullOrWhiteSpace(proposal.Status))
        {
            proposal.Status = "Pendente";
        }

        await HandleBrokerageCommissionAsync(proposal);

        proposal.CreatedAt = DateTime.Now;
        proposal.UpdatedAt = DateTime.Now;

        _context.Propostas.Add(proposal);
        await _context.SaveChangesAsync();

        return proposal;
    }

    public async Task<Proposta> UpdateAsync(string id, Proposta input)
    {
        var proposal = await _context.Propostas.FirstOrDefaultAsync(p => p.Id == id);
        if (proposal == null)
        {
            throw new AppNotFoundException("proposta não encontrada");
        }

        if (!string.IsNullOrWhiteSpace(input.Tipo))
        {
            var tipoProposta = await _context.TiposProposta.FirstOrDefaultAsync(t => t.Chave == input.Tipo);
            if (tipoProposta == null)
            {
                throw new AppBadRequestException("tipo de proposta inválido (use Imobiliaria, Auto ou Comissionados)");
            }

            ValidateDynamicFields(tipoProposta, input.DadosEspecificos);
            proposal.Tipo = input.Tipo;
        }

        if (input.Valor <= 0)
        {
            throw new AppBadRequestException("valor da proposta deve ser maior que zero");
        }

        proposal.Valor = input.Valor;
        proposal.Status = input.Status;
        proposal.Descricao = input.Descricao;
        proposal.DadosEspecificos = input.DadosEspecificos;
        proposal.EmpresaId = input.EmpresaId;
        proposal.StatusCorretagem = input.StatusCorretagem;

        await HandleBrokerageCommissionAsync(proposal);

        proposal.UpdatedAt = DateTime.Now;

        await _context.SaveChangesAsync();

        // Load Empresa association if populated
        if (proposal.EmpresaId != null)
        {
            proposal.Empresa = await _context.Empresas.FirstOrDefaultAsync(e => e.Id == proposal.EmpresaId);
        }
        else
        {
            proposal.Empresa = null;
        }

        return proposal;
    }

    public async Task DeleteAsync(string id)
    {
        var proposal = await _context.Propostas.FirstOrDefaultAsync(p => p.Id == id);
        if (proposal == null)
        {
            throw new AppNotFoundException("proposta não encontrada");
        }

        _context.Propostas.Remove(proposal);
        await _context.SaveChangesAsync();
    }

    public async Task HandleBrokerageCommissionAsync(Proposta p)
    {
        if (p.EmpresaId != null && (p.StatusCorretagem == "FechadaComSucesso" || p.Status == "Aprovada"))
        {
            p.StatusCorretagem = "FechadaComSucesso";

            var conf = await _context.Configuracoes.FirstOrDefaultAsync(c => c.Chave == "taxa_corretagem");
            double taxa = 5.0;
            if (conf != null && double.TryParse(conf.Valor, NumberStyles.Any, CultureInfo.InvariantCulture, out double parsedTaxa))
            {
                taxa = parsedTaxa;
            }

            p.ValorComissao = Math.Round(p.Valor * (taxa / 100.0), 2);
        }
        else if (p.EmpresaId != null)
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

    private void ValidateDynamicFields(TipoProposta tipo, JsonElement dadosEspecificos)
    {
        if (tipo.Chave == "Imobiliaria" || tipo.Chave == "Auto" || tipo.Chave == "Comissionados")
        {
            return;
        }

        bool hasData = dadosEspecificos.ValueKind == JsonValueKind.Object;

        foreach (var campo in tipo.Campos)
        {
            bool exists = false;
            JsonElement propValue = default;

            if (hasData)
            {
                exists = dadosEspecificos.TryGetProperty(campo.Chave, out propValue);
            }

            if (campo.Obrigatorio)
            {
                if (!exists || propValue.ValueKind == JsonValueKind.Null || propValue.ValueKind == JsonValueKind.Undefined)
                {
                    throw new AppBadRequestException($"o campo '{campo.Nome}' é obrigatório");
                }

                if (propValue.ValueKind == JsonValueKind.String && string.IsNullOrWhiteSpace(propValue.GetString()))
                {
                    throw new AppBadRequestException($"o campo '{campo.Nome}' é obrigatório");
                }
            }

            if (exists && propValue.ValueKind != JsonValueKind.Null && propValue.ValueKind != JsonValueKind.Undefined)
            {
                switch (campo.Tipo)
                {
                    case "number":
                        if (propValue.ValueKind != JsonValueKind.Number)
                        {
                            if (propValue.ValueKind == JsonValueKind.String)
                            {
                                var strVal = propValue.GetString();
                                if (!double.TryParse(strVal, NumberStyles.Any, CultureInfo.InvariantCulture, out _))
                                {
                                    throw new AppBadRequestException($"o campo '{campo.Nome}' deve ser um número");
                                }
                            }
                            else
                            {
                                throw new AppBadRequestException($"o campo '{campo.Nome}' deve ser um número");
                            }
                        }
                        break;

                    case "boolean":
                        if (propValue.ValueKind != JsonValueKind.True && propValue.ValueKind != JsonValueKind.False)
                        {
                            if (propValue.ValueKind == JsonValueKind.String)
                            {
                                var strVal = propValue.GetString();
                                if (strVal != "true" && strVal != "false")
                                {
                                    throw new AppBadRequestException($"o campo '{campo.Nome}' deve ser verdadeiro ou falso");
                                }
                            }
                            else
                            {
                                throw new AppBadRequestException($"o campo '{campo.Nome}' deve ser verdadeiro ou falso");
                            }
                        }
                        break;
                }
            }
        }
    }
}

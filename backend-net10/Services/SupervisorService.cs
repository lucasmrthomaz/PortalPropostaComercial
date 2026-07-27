using Microsoft.EntityFrameworkCore;
using backend_net10.Data;
using backend_net10.Models;
using System.Text.Json;
using System.Text.Json.Serialization;

namespace backend_net10.Services;

public class SupervisorService
{
    private readonly AppDbContext _context;
    private readonly ClienteService _clienteService;
    private readonly PropostaService _propostaService;

    public SupervisorService(AppDbContext context, ClienteService clienteService, PropostaService propostaService)
    {
        _context = context;
        _clienteService = clienteService;
        _propostaService = propostaService;
    }

    public async Task<List<PedidoAnalise>> ListAllAsync()
    {
        return await _context.PedidosAnalise
            .OrderByDescending(p => p.CreatedAt)
            .ToListAsync();
    }

    public async Task<List<PedidoAnalise>> ListPendentesAsync()
    {
        return await _context.PedidosAnalise
            .Where(p => p.Status == "Pendente")
            .OrderByDescending(p => p.CreatedAt)
            .ToListAsync();
    }

    public async Task<PedidoAnalise> CreateRequestAsync(PedidoAnalise request)
    {
        request.Id = Guid.NewGuid().ToString();
        request.Status = "Pendente";
        request.CreatedAt = DateTime.Now;
        request.UpdatedAt = DateTime.Now;

        _context.PedidosAnalise.Add(request);
        await _context.SaveChangesAsync();

        return request;
    }

    private class ActionPropostaReq
    {
        [JsonPropertyName("proposta_id")]
        public string PropostaId { get; set; } = string.Empty;
    }

    private class ActionEncaminharReq
    {
        [JsonPropertyName("proposta_id")]
        public string PropostaId { get; set; } = string.Empty;

        [JsonPropertyName("empresa_id")]
        public string EmpresaId { get; set; } = string.Empty;
    }

    private class ActionClienteReq
    {
        [JsonPropertyName("cliente_id")]
        public string ClienteId { get; set; } = string.Empty;
    }

    public async Task ApproveRequestAsync(string id)
    {
        var pedido = await _context.PedidosAnalise.FirstOrDefaultAsync(p => p.Id == id);
        if (pedido == null)
        {
            throw new AppNotFoundException("pedido de análise não encontrado");
        }

        if (pedido.Status != "Pendente")
        {
            throw new AppBadRequestException("este pedido de análise já foi processado");
        }

        var dadosJson = pedido.DadosAcao ?? "{}";

        switch (pedido.TipoAcao)
        {
            case "AprovarProposta":
                var aprovarReq = JsonSerializer.Deserialize<ActionPropostaReq>(dadosJson);
                if (aprovarReq == null || string.IsNullOrEmpty(aprovarReq.PropostaId))
                {
                    throw new AppBadRequestException("dados da ação inválidos para aprovar proposta");
                }

                var prop = await _propostaService.GetByIdAsync(aprovarReq.PropostaId);
                prop.Status = "Aprovada";
                await _propostaService.HandleBrokerageCommissionAsync(prop);
                await _propostaService.UpdateAsync(prop.Id, prop);
                break;

            case "EncaminharEmpresa":
                var encaminharReq = JsonSerializer.Deserialize<ActionEncaminharReq>(dadosJson);
                if (encaminharReq == null || string.IsNullOrEmpty(encaminharReq.PropostaId) || string.IsNullOrEmpty(encaminharReq.EmpresaId))
                {
                    throw new AppBadRequestException("dados da ação inválidos para encaminhar empresa");
                }

                var propEnc = await _propostaService.GetByIdAsync(encaminharReq.PropostaId);
                propEnc.EmpresaId = encaminharReq.EmpresaId;
                propEnc.StatusCorretagem = "Encaminhada";
                await _propostaService.HandleBrokerageCommissionAsync(propEnc);
                await _propostaService.UpdateAsync(propEnc.Id, propEnc);
                break;

            case "DeletarCliente":
                var deletarCliReq = JsonSerializer.Deserialize<ActionClienteReq>(dadosJson);
                if (deletarCliReq == null || string.IsNullOrEmpty(deletarCliReq.ClienteId))
                {
                    throw new AppBadRequestException("dados da ação inválidos para deletar cliente");
                }

                await _clienteService.DeleteAsync(deletarCliReq.ClienteId);
                break;

            case "DeletarProposta":
                var deletarPropReq = JsonSerializer.Deserialize<ActionPropostaReq>(dadosJson);
                if (deletarPropReq == null || string.IsNullOrEmpty(deletarPropReq.PropostaId))
                {
                    throw new AppBadRequestException("dados da ação inválidos para deletar proposta");
                }

                await _propostaService.DeleteAsync(deletarPropReq.PropostaId);
                break;

            default:
                throw new AppBadRequestException("tipo de ação do supervisor não suportado");
        }

        pedido.Status = "Aprovado";
        pedido.UpdatedAt = DateTime.Now;
        await _context.SaveChangesAsync();
    }

    public async Task RejectRequestAsync(string id)
    {
        var pedido = await _context.PedidosAnalise.FirstOrDefaultAsync(p => p.Id == id);
        if (pedido == null)
        {
            throw new AppNotFoundException("pedido de análise não encontrado");
        }

        if (pedido.Status != "Pendente")
        {
            throw new AppBadRequestException("este pedido de análise já foi processado");
        }

        pedido.Status = "Recusado";
        pedido.UpdatedAt = DateTime.Now;
        await _context.SaveChangesAsync();
    }
}

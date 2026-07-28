using System.Text.Json;
using System.Text.Json.Serialization;
using Microsoft.EntityFrameworkCore;
using PortalProposta.Data;
using PortalProposta.Models;

namespace PortalProposta.Services;

public class SupervisorService(AppDbContext context, ClienteService clienteService, PropostaService propostaService)
{
    public async Task<List<PedidoAnalise>> ListAllAsync() =>
        await context.PedidosAnalise.OrderByDescending(p => p.CreatedAt).ToListAsync();

    public async Task<List<PedidoAnalise>> ListPendentesAsync() =>
        await context.PedidosAnalise
            .Where(p => p.Status == "Pendente")
            .OrderByDescending(p => p.CreatedAt)
            .ToListAsync();

    public async Task<PedidoAnalise> CreateRequestAsync(PedidoAnalise request)
    {
        request.Id = Guid.NewGuid().ToString();
        request.Status = "Pendente";
        request.CreatedAt = request.UpdatedAt = DateTime.Now;

        context.PedidosAnalise.Add(request);
        await context.SaveChangesAsync();
        return request;
    }

    public async Task ApproveRequestAsync(string id)
    {
        var pedido = await context.PedidosAnalise.FirstOrDefaultAsync(p => p.Id == id)
            ?? throw new AppNotFoundException("pedido de análise não encontrado");

        if (pedido.Status != "Pendente")
            throw new AppBadRequestException("este pedido de análise já foi processado");

        var dadosJson = pedido.DadosAcao ?? "{}";

        switch (pedido.TipoAcao)
        {
            case "AprovarProposta":
            {
                var req = JsonSerializer.Deserialize<ActionPropostaReq>(dadosJson)
                    ?? throw new AppBadRequestException("dados da ação inválidos");
                var prop = await propostaService.GetByIdAsync(req.PropostaId);
                prop.Status = "Aprovada";
                await propostaService.HandleBrokerageCommissionAsync(prop);
                await propostaService.UpdateAsync(prop.Id, prop);
                break;
            }
            case "EncaminharEmpresa":
            {
                var req = JsonSerializer.Deserialize<ActionEncaminharReq>(dadosJson)
                    ?? throw new AppBadRequestException("dados da ação inválidos");
                var prop = await propostaService.GetByIdAsync(req.PropostaId);
                prop.EmpresaId = req.EmpresaId;
                prop.StatusCorretagem = "Encaminhada";
                await propostaService.HandleBrokerageCommissionAsync(prop);
                await propostaService.UpdateAsync(prop.Id, prop);
                break;
            }
            case "DeletarCliente":
            {
                var req = JsonSerializer.Deserialize<ActionClienteReq>(dadosJson)
                    ?? throw new AppBadRequestException("dados da ação inválidos");
                await clienteService.DeleteAsync(req.ClienteId);
                break;
            }
            case "DeletarProposta":
            {
                var req = JsonSerializer.Deserialize<ActionPropostaReq>(dadosJson)
                    ?? throw new AppBadRequestException("dados da ação inválidos");
                await propostaService.DeleteAsync(req.PropostaId);
                break;
            }
            default:
                throw new AppBadRequestException("tipo de ação do supervisor não suportado");
        }

        pedido.Status = "Aprovado";
        pedido.UpdatedAt = DateTime.Now;
        await context.SaveChangesAsync();
    }

    public async Task RejectRequestAsync(string id)
    {
        var pedido = await context.PedidosAnalise.FirstOrDefaultAsync(p => p.Id == id)
            ?? throw new AppNotFoundException("pedido de análise não encontrado");

        if (pedido.Status != "Pendente")
            throw new AppBadRequestException("este pedido de análise já foi processado");

        pedido.Status = "Recusado";
        pedido.UpdatedAt = DateTime.Now;
        await context.SaveChangesAsync();
    }

    // Private DTOs for action payloads
    private record ActionPropostaReq([property: JsonPropertyName("proposta_id")] string PropostaId);
    private record ActionEncaminharReq(
        [property: JsonPropertyName("proposta_id")] string PropostaId,
        [property: JsonPropertyName("empresa_id")] string EmpresaId);
    private record ActionClienteReq([property: JsonPropertyName("cliente_id")] string ClienteId);
}

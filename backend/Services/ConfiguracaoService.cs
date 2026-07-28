using Microsoft.EntityFrameworkCore;
using PortalProposta.Data;
using PortalProposta.Models;
using System.Globalization;

namespace PortalProposta.Services;

public class ConfiguracaoService(AppDbContext context)
{
    public async Task<double> GetCommissionRateAsync()
    {
        var conf = await context.Configuracoes.FirstOrDefaultAsync(c => c.Chave == "taxa_corretagem");
        return conf is not null && double.TryParse(conf.Valor, NumberStyles.Any, CultureInfo.InvariantCulture, out var rate)
            ? rate
            : 5.0;
    }

    public async Task UpdateCommissionRateAsync(double rate)
    {
        if (rate < 0 || rate > 100)
            throw new AppBadRequestException("taxa de corretagem inválida (deve ser entre 0% e 100%)");

        await SetSettingAsync("taxa_corretagem", rate.ToString("F2", CultureInfo.InvariantCulture));
    }

    public async Task VerifySupervisorPasswordAsync(string inputPassword)
    {
        var conf = await context.Configuracoes.FirstOrDefaultAsync(c => c.Chave == "senha_supervisor");
        var actualPassword = conf?.Valor ?? "admin123";

        if (actualPassword != inputPassword)
            throw new AppBadRequestException("senha do supervisor incorreta");
    }

    public async Task UpdateSupervisorPasswordAsync(string newPassword)
    {
        if (string.IsNullOrWhiteSpace(newPassword) || newPassword.Trim().Length < 4)
            throw new AppBadRequestException("a senha do supervisor deve ter no mínimo 4 caracteres");

        await SetSettingAsync("senha_supervisor", newPassword.Trim());
    }

    private async Task SetSettingAsync(string chave, string valor)
    {
        var conf = await context.Configuracoes.FirstOrDefaultAsync(c => c.Chave == chave);
        if (conf is null)
        {
            context.Configuracoes.Add(new() { Chave = chave, Valor = valor });
        }
        else
        {
            conf.Valor = valor;
        }
        await context.SaveChangesAsync();
    }
}

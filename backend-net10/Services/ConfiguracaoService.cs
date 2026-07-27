using Microsoft.EntityFrameworkCore;
using backend_net10.Data;
using backend_net10.Models;
using System.Globalization;

namespace backend_net10.Services;

public class ConfiguracaoService
{
    private readonly AppDbContext _context;

    public ConfiguracaoService(AppDbContext context)
    {
        _context = context;
    }

    public async Task<double> GetCommissionRateAsync()
    {
        var conf = await _context.Configuracoes.FirstOrDefaultAsync(c => c.Chave == "taxa_corretagem");
        if (conf == null)
        {
            return 5.0;
        }

        if (double.TryParse(conf.Valor, NumberStyles.Any, CultureInfo.InvariantCulture, out double rate))
        {
            return rate;
        }

        return 5.0;
    }

    public async Task UpdateCommissionRateAsync(double rate)
    {
        if (rate < 0 || rate > 100)
        {
            throw new AppBadRequestException("taxa de corretagem inválida (deve ser entre 0% e 100%)");
        }

        var val = rate.ToString("F2", CultureInfo.InvariantCulture);
        await SetSettingAsync("taxa_corretagem", val);
    }

    public async Task VerifySupervisorPasswordAsync(string inputPassword)
    {
        var conf = await _context.Configuracoes.FirstOrDefaultAsync(c => c.Chave == "senha_supervisor");
        if (conf == null)
        {
            if (inputPassword == "admin123")
            {
                return;
            }
            throw new AppBadRequestException("senha do supervisor incorreta");
        }

        if (conf.Valor != inputPassword)
        {
            throw new AppBadRequestException("senha do supervisor incorreta");
        }
    }

    public async Task UpdateSupervisorPasswordAsync(string newPassword)
    {
        if (string.IsNullOrWhiteSpace(newPassword) || newPassword.Trim().Length < 4)
        {
            throw new AppBadRequestException("a senha do supervisor deve ter no mínimo 4 caracteres");
        }

        await SetSettingAsync("senha_supervisor", newPassword.Trim());
    }

    private async Task SetSettingAsync(string chave, string valor)
    {
        var conf = await _context.Configuracoes.FirstOrDefaultAsync(c => c.Chave == chave);
        if (conf == null)
        {
            conf = new Configuracao { Chave = chave, Valor = valor };
            _context.Configuracoes.Add(conf);
        }
        else
        {
            conf.Valor = valor;
        }
        await _context.SaveChangesAsync();
    }
}

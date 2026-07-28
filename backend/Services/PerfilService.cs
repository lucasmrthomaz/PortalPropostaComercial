using Microsoft.EntityFrameworkCore;
using PortalProposta.Data;
using PortalProposta.Models;

namespace PortalProposta.Services;

public class PerfilService(AppDbContext context)
{
    public async Task<List<Perfil>> ListAsync() =>
        await context.Perfis.OrderBy(p => p.Nome).ToListAsync();

    public async Task<Perfil> GetByIdAsync(string id) =>
        await context.Perfis.FirstOrDefaultAsync(p => p.Id == id)
            ?? throw new AppNotFoundException("perfil de acesso não encontrado");

    public async Task<Perfil> CreateAsync(Perfil perfil)
    {
        Validate.Perfil(perfil);

        if (await context.Perfis.AnyAsync(p => p.Nome == perfil.Nome))
            throw new AppBadRequestException("já existe um perfil com este nome");

        perfil.Id = Guid.NewGuid().ToString();
        perfil.CreatedAt = perfil.UpdatedAt = DateTime.Now;

        context.Perfis.Add(perfil);
        await context.SaveChangesAsync();
        return perfil;
    }

    public async Task<Perfil> UpdateAsync(string id, Perfil input)
    {
        var perfil = await context.Perfis.FirstOrDefaultAsync(p => p.Id == id)
            ?? throw new AppNotFoundException("perfil de acesso não encontrado");

        Validate.Perfil(input);

        if (input.Nome != perfil.Nome &&
            await context.Perfis.AnyAsync(p => p.Nome == input.Nome && p.Id != perfil.Id))
            throw new AppBadRequestException("já existe um perfil com este nome");

        if (!perfil.IsSistema)
            perfil.Nome = input.Nome;

        perfil.Descricao = input.Descricao;
        perfil.Permissoes = input.Permissoes;
        perfil.UpdatedAt = DateTime.Now;

        await context.SaveChangesAsync();
        return perfil;
    }

    public async Task DeleteAsync(string id)
    {
        var perfil = await context.Perfis.FirstOrDefaultAsync(p => p.Id == id)
            ?? throw new AppNotFoundException("perfil de acesso não encontrado");

        if (perfil.IsSistema)
            throw new AppBadRequestException("não é permitido excluir perfis do sistema");

        var count = await context.Usuarios.CountAsync(u => u.PerfilId == id);
        if (count > 0)
            throw new AppBadRequestException($"não é possível excluir este perfil pois existem {count} usuário(s) associado(s) a ele");

        context.Perfis.Remove(perfil);
        await context.SaveChangesAsync();
    }
}

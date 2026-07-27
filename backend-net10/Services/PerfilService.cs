using Microsoft.EntityFrameworkCore;
using backend_net10.Data;
using backend_net10.Models;

namespace backend_net10.Services;

public class PerfilService
{
    private readonly AppDbContext _context;

    public PerfilService(AppDbContext context)
    {
        _context = context;
    }

    public async Task<List<Perfil>> ListAsync()
    {
        return await _context.Perfis.OrderBy(p => p.Nome).ToListAsync();
    }

    public async Task<Perfil> GetByIdAsync(string id)
    {
        var perfil = await _context.Perfis.FirstOrDefaultAsync(p => p.Id == id);
        if (perfil == null)
        {
            throw new AppNotFoundException("perfil de acesso não encontrado");
        }
        return perfil;
    }

    public async Task<Perfil> CreateAsync(Perfil perfil)
    {
        if (string.IsNullOrWhiteSpace(perfil.Nome))
        {
            throw new AppBadRequestException("nome do perfil é obrigatório");
        }

        var existing = await _context.Perfis.FirstOrDefaultAsync(p => p.Nome == perfil.Nome);
        if (existing != null)
        {
            throw new AppBadRequestException("já existe um perfil com este nome");
        }

        perfil.Id = Guid.NewGuid().ToString();
        perfil.CreatedAt = DateTime.Now;
        perfil.UpdatedAt = DateTime.Now;

        _context.Perfis.Add(perfil);
        await _context.SaveChangesAsync();

        return perfil;
    }

    public async Task<Perfil> UpdateAsync(string id, Perfil input)
    {
        var perfil = await _context.Perfis.FirstOrDefaultAsync(p => p.Id == id);
        if (perfil == null)
        {
            throw new AppNotFoundException("perfil de acesso não encontrado");
        }

        if (string.IsNullOrWhiteSpace(input.Nome))
        {
            throw new AppBadRequestException("nome do perfil é obrigatório");
        }

        if (input.Nome != perfil.Nome)
        {
            var existing = await _context.Perfis.FirstOrDefaultAsync(p => p.Nome == input.Nome);
            if (existing != null && existing.Id != perfil.Id)
            {
                throw new AppBadRequestException("já existe um perfil com este nome");
            }
        }

        if (!perfil.IsSistema)
        {
            perfil.Nome = input.Nome;
        }

        perfil.Descricao = input.Descricao;
        perfil.Permissoes = input.Permissoes;
        perfil.UpdatedAt = DateTime.Now;

        await _context.SaveChangesAsync();
        return perfil;
    }

    public async Task DeleteAsync(string id)
    {
        var perfil = await _context.Perfis.FirstOrDefaultAsync(p => p.Id == id);
        if (perfil == null)
        {
            throw new AppNotFoundException("perfil de acesso não encontrado");
        }

        if (perfil.IsSistema)
        {
            throw new AppBadRequestException("não é permitido excluir perfis do sistema");
        }

        var count = await _context.Usuarios.CountAsync(u => u.PerfilId == id);
        if (count > 0)
        {
            throw new AppBadRequestException($"não é possível excluir este perfil pois existem {count} usuário(s) associado(s) a ele");
        }

        _context.Perfis.Remove(perfil);
        await _context.SaveChangesAsync();
    }
}

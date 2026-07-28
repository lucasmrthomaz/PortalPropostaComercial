using Microsoft.EntityFrameworkCore;
using PortalProposta.Data;
using PortalProposta.Infrastructure;
using PortalProposta.Models;

namespace PortalProposta.Services;

public class UsuarioService(AppDbContext context)
{
    public async Task<List<Usuario>> ListAsync() =>
        await context.Usuarios.Include(u => u.Perfil).OrderBy(u => u.Nome).ToListAsync();

    public async Task<Usuario> GetByIdAsync(string id) =>
        await context.Usuarios.Include(u => u.Perfil).FirstOrDefaultAsync(u => u.Id == id)
            ?? throw new AppNotFoundException("usuário não encontrado");

    public async Task<Usuario> CreateAsync(Usuario user, string password)
    {
        Validate.Usuario(user);

        if (!await context.Perfis.AnyAsync(p => p.Id == user.PerfilId))
            throw new AppNotFoundException("perfil de acesso não encontrado");

        if (await context.Usuarios.AnyAsync(u => u.Email == user.Email))
            throw new AppBadRequestException("já existe um usuário com este email");

        if (string.IsNullOrWhiteSpace(password))
            throw new AppBadRequestException("a senha é obrigatória");

        user.Id = Guid.NewGuid().ToString();
        user.SenhaHash = PasswordHasher.Hash(password);
        user.CreatedAt = user.UpdatedAt = DateTime.Now;

        context.Usuarios.Add(user);
        await context.SaveChangesAsync();

        user.Perfil = await context.Perfis.FirstOrDefaultAsync(p => p.Id == user.PerfilId);
        return user;
    }

    public async Task<Usuario> UpdateAsync(string id, Usuario input, string? newPassword)
    {
        var user = await context.Usuarios.Include(u => u.Perfil).FirstOrDefaultAsync(u => u.Id == id)
            ?? throw new AppNotFoundException("usuário não encontrado");

        Validate.Usuario(input);

        if (input.Email != user.Email &&
            await context.Usuarios.AnyAsync(u => u.Email == input.Email && u.Id != user.Id))
            throw new AppBadRequestException("já existe um usuário com este email");

        if (!string.IsNullOrEmpty(input.PerfilId) && input.PerfilId != user.PerfilId)
        {
            if (!await context.Perfis.AnyAsync(p => p.Id == input.PerfilId))
                throw new AppNotFoundException("perfil de acesso não encontrado");
            user.PerfilId = input.PerfilId;
        }

        user.Nome = input.Nome;
        user.Email = input.Email;
        user.Ativo = input.Ativo;

        if (!string.IsNullOrWhiteSpace(newPassword))
            user.SenhaHash = PasswordHasher.Hash(newPassword);

        user.UpdatedAt = DateTime.Now;
        await context.SaveChangesAsync();

        user.Perfil = await context.Perfis.FirstOrDefaultAsync(p => p.Id == user.PerfilId);
        return user;
    }

    public async Task DeleteAsync(string id)
    {
        var user = await context.Usuarios.Include(u => u.Perfil).FirstOrDefaultAsync(u => u.Id == id)
            ?? throw new AppNotFoundException("usuário não encontrado");

        if (user.Perfil?.Nome == "Super Admin")
        {
            var count = await context.Usuarios
                .Include(u => u.Perfil)
                .CountAsync(u => u.Perfil!.Nome == "Super Admin" && u.Ativo);

            if (count <= 1)
                throw new AppBadRequestException("não é possível excluir o último usuário super admin");
        }

        context.Usuarios.Remove(user);
        await context.SaveChangesAsync();
    }

    public async Task<Usuario> LoginAsync(string email, string password)
    {
        var user = await context.Usuarios
            .Include(u => u.Perfil)
            .FirstOrDefaultAsync(u => u.Email == email);

        if (user is null || !user.Ativo || user.SenhaHash != PasswordHasher.Hash(password))
            throw new AppUnauthorizedException("email ou senha inválidos");

        return user;
    }
}

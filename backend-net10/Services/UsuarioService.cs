using Microsoft.EntityFrameworkCore;
using backend_net10.Data;
using backend_net10.Models;
using backend_net10.Infrastructure;

namespace backend_net10.Services;

public class UsuarioService
{
    private readonly AppDbContext _context;

    public UsuarioService(AppDbContext context)
    {
        _context = context;
    }

    public async Task<List<Usuario>> ListAsync()
    {
        return await _context.Usuarios
            .Include(u => u.Perfil)
            .OrderBy(u => u.Nome)
            .ToListAsync();
    }

    public async Task<Usuario> GetByIdAsync(string id)
    {
        var user = await _context.Usuarios
            .Include(u => u.Perfil)
            .FirstOrDefaultAsync(u => u.Id == id);
            
        if (user == null)
        {
            throw new AppNotFoundException("usuário não encontrado");
        }
        return user;
    }

    public async Task<Usuario> CreateAsync(Usuario user, string password)
    {
        if (string.IsNullOrWhiteSpace(user.Nome))
        {
            throw new AppBadRequestException("nome do usuário é obrigatório");
        }

        if (string.IsNullOrWhiteSpace(user.Email) || !user.Email.Contains('@'))
        {
            throw new AppBadRequestException("email do usuário é obrigatório ou inválido");
        }

        var perfilExists = await _context.Perfis.AnyAsync(p => p.Id == user.PerfilId);
        if (!perfilExists)
        {
            throw new AppNotFoundException("perfil de acesso não encontrado"); // In Go it compiles as ErrPerfilNotFound -> 404
        }

        var existing = await _context.Usuarios.FirstOrDefaultAsync(u => u.Email == user.Email);
        if (existing != null)
        {
            throw new AppBadRequestException("já existe um usuário com este email");
        }

        if (string.IsNullOrWhiteSpace(password))
        {
            throw new AppBadRequestException("a senha é obrigatória");
        }

        user.Id = Guid.NewGuid().ToString();
        user.SenhaHash = PasswordHasher.HashPassword(password);
        user.CreatedAt = DateTime.Now;
        user.UpdatedAt = DateTime.Now;

        _context.Usuarios.Add(user);
        await _context.SaveChangesAsync();

        // Load perfil for response
        user.Perfil = await _context.Perfis.FirstOrDefaultAsync(p => p.Id == user.PerfilId);

        return user;
    }

    public async Task<Usuario> UpdateAsync(string id, Usuario input, string? newPassword)
    {
        var user = await _context.Usuarios
            .Include(u => u.Perfil)
            .FirstOrDefaultAsync(u => u.Id == id);

        if (user == null)
        {
            throw new AppNotFoundException("usuário não encontrado");
        }

        if (string.IsNullOrWhiteSpace(input.Nome))
        {
            throw new AppBadRequestException("nome do usuário é obrigatório");
        }

        if (string.IsNullOrWhiteSpace(input.Email) || !input.Email.Contains('@'))
        {
            throw new AppBadRequestException("email do usuário é obrigatório ou inválido");
        }

        if (input.Email != user.Email)
        {
            var existing = await _context.Usuarios.FirstOrDefaultAsync(u => u.Email == input.Email);
            if (existing != null && existing.Id != user.Id)
            {
                throw new AppBadRequestException("já existe um usuário com este email");
            }
            user.Email = input.Email;
        }

        if (!string.IsNullOrEmpty(input.PerfilId) && input.PerfilId != user.PerfilId)
        {
            var perfilExists = await _context.Perfis.AnyAsync(p => p.Id == input.PerfilId);
            if (!perfilExists)
            {
                throw new AppNotFoundException("perfil de acesso não encontrado");
            }
            user.PerfilId = input.PerfilId;
        }

        user.Nome = input.Nome;
        user.Ativo = input.Ativo;

        if (!string.IsNullOrWhiteSpace(newPassword))
        {
            user.SenhaHash = PasswordHasher.HashPassword(newPassword);
        }

        user.UpdatedAt = DateTime.Now;

        await _context.SaveChangesAsync();

        // Reload Perfil association if changed
        user.Perfil = await _context.Perfis.FirstOrDefaultAsync(p => p.Id == user.PerfilId);

        return user;
    }

    public async Task DeleteAsync(string id)
    {
        var user = await _context.Usuarios
            .Include(u => u.Perfil)
            .FirstOrDefaultAsync(u => u.Id == id);

        if (user == null)
        {
            throw new AppNotFoundException("usuário não encontrado");
        }

        if (user.Perfil != null && user.Perfil.Nome == "Super Admin")
        {
            // Count super admins
            var count = await _context.Usuarios
                .Include(u => u.Perfil)
                .CountAsync(u => u.Perfil!.Nome == "Super Admin" && u.Ativo);

            if (count <= 1)
            {
                throw new AppBadRequestException("não é possível excluir o último usuário super admin");
            }
        }

        _context.Usuarios.Remove(user);
        await _context.SaveChangesAsync();
    }

    public async Task<Usuario> LoginAsync(string email, string password)
    {
        var user = await _context.Usuarios
            .Include(u => u.Perfil)
            .FirstOrDefaultAsync(u => u.Email == email);

        if (user == null || !user.Ativo)
        {
            throw new AppUnauthorizedException("email ou senha inválidos");
        }

        var hashedInput = PasswordHasher.HashPassword(password);
        if (user.SenhaHash != hashedInput)
        {
            throw new AppUnauthorizedException("email ou senha inválidos");
        }

        return user;
    }
}

using System.Text.Json;
using Microsoft.EntityFrameworkCore;
using PortalProposta.Models;

namespace PortalProposta.Data;

public class AppDbContext(DbContextOptions<AppDbContext> options) : DbContext(options)
{
    public DbSet<Cliente> Clientes => Set<Cliente>();
    public DbSet<Proposta> Propostas => Set<Proposta>();
    public DbSet<Empresa> Empresas => Set<Empresa>();
    public DbSet<Configuracao> Configuracoes => Set<Configuracao>();
    public DbSet<PedidoAnalise> PedidosAnalise => Set<PedidoAnalise>();
    public DbSet<TipoProposta> TiposProposta => Set<TipoProposta>();
    public DbSet<Perfil> Perfis => Set<Perfil>();
    public DbSet<Usuario> Usuarios => Set<Usuario>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        // Most mappings are handled via [Table], [Column], [Key], [Required] attributes.
        // Only relationships and indexes that can't be expressed with attributes go here.

        // Cliente
        modelBuilder.Entity<Cliente>(entity =>
        {
            entity.HasIndex(c => c.CPFCNPJ).IsUnique();
            entity.HasMany(c => c.Propostas)
                  .WithOne()
                  .HasForeignKey(p => p.ClienteId)
                  .OnDelete(DeleteBehavior.Cascade);
        });

        // Empresa
        modelBuilder.Entity<Empresa>(entity =>
        {
            entity.HasIndex(e => e.CNPJ).IsUnique();
        });

        // Proposta
        modelBuilder.Entity<Proposta>(entity =>
        {
            entity.HasIndex(p => p.ClienteId);
            entity.Property(p => p.Status).HasDefaultValue("Pendente");
            entity.Property(p => p.ValorComissao).HasDefaultValue(0.0);
            entity.Property(p => p.StatusCorretagem).HasDefaultValue("Pendente");

            entity.HasOne(p => p.Empresa)
                  .WithMany()
                  .HasForeignKey(p => p.EmpresaId)
                  .OnDelete(DeleteBehavior.SetNull);

            // JSON serialization for DadosEspecificos
            entity.Property(p => p.DadosEspecificos)
                  .HasConversion(
                      v => v.ValueKind == JsonValueKind.Undefined ? "{}" : JsonSerializer.Serialize(v, JsonSerializerOptions.Default),
                      v => string.IsNullOrEmpty(v) ? JsonDocument.Parse("{}").RootElement.Clone() : JsonDocument.Parse(v).RootElement.Clone()
                  );
        });

        // TipoProposta
        modelBuilder.Entity<TipoProposta>(entity =>
        {
            entity.HasIndex(t => t.Nome).IsUnique();
            entity.HasIndex(t => t.Chave).IsUnique();

            // JSON serialization for Campos
            entity.Property(t => t.Campos)
                  .HasConversion(
                      v => JsonSerializer.Serialize(v, JsonSerializerOptions.Default),
                      v => string.IsNullOrEmpty(v) ? new() : JsonSerializer.Deserialize<List<CampoTipoProposta>>(v, JsonSerializerOptions.Default) ?? new()
                  );
        });

        // Perfil
        modelBuilder.Entity<Perfil>(entity =>
        {
            entity.HasIndex(p => p.Nome).IsUnique();
            entity.Property(p => p.IsSistema).HasDefaultValue(false);

            // JSON serialization for Permissoes
            entity.Property(p => p.Permissoes)
                  .HasConversion(
                      v => JsonSerializer.Serialize(v, JsonSerializerOptions.Default),
                      v => string.IsNullOrEmpty(v) ? new() : JsonSerializer.Deserialize<List<string>>(v, JsonSerializerOptions.Default) ?? new()
                  );
        });

        // Usuario
        modelBuilder.Entity<Usuario>(entity =>
        {
            entity.HasIndex(u => u.Email).IsUnique();
            entity.Property(u => u.Ativo).HasDefaultValue(true);

            entity.HasOne(u => u.Perfil)
                  .WithMany()
                  .HasForeignKey(u => u.PerfilId)
                  .OnDelete(DeleteBehavior.Restrict);
        });

        // PedidoAnalise
        modelBuilder.Entity<PedidoAnalise>(entity =>
        {
            entity.Property(p => p.Status).HasDefaultValue("Pendente");
        });

        // Configuracao - simple key-value, no extra config needed
    }
}

using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using backend_net10.Models;
using System.Text.Json;

namespace backend_net10.Data;

public class AppDbContext : DbContext
{
    public AppDbContext(DbContextOptions<AppDbContext> options) : base(options)
    {
    }

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

        // Clientes Table mapping
        modelBuilder.Entity<Cliente>(entity =>
        {
            entity.ToTable("clientes");
            entity.HasKey(c => c.Id);
            entity.Property(c => c.Nome).IsRequired();
            entity.Property(c => c.CPFCNPJ).IsRequired().HasColumnName("cpf_cnpj");
            entity.HasIndex(c => c.CPFCNPJ).IsUnique();
            entity.Property(c => c.Email).IsRequired();

            entity.HasMany(c => c.Propostas)
                  .WithOne()
                  .HasForeignKey(p => p.ClienteId)
                  .OnDelete(DeleteBehavior.Cascade);
        });

        // Empresas Table mapping
        modelBuilder.Entity<Empresa>(entity =>
        {
            entity.ToTable("empresas");
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Nome).IsRequired();
            entity.Property(e => e.CNPJ).IsRequired();
            entity.HasIndex(e => e.CNPJ).IsUnique();
            entity.Property(e => e.Email).IsRequired();
        });

        // Propostas Table mapping
        modelBuilder.Entity<Proposta>(entity =>
        {
            entity.ToTable("proposta");
            entity.HasKey(p => p.Id);
            entity.Property(p => p.ClienteId).IsRequired();
            entity.HasIndex(p => p.ClienteId);
            entity.Property(p => p.Tipo).IsRequired();
            entity.Property(p => p.Valor).IsRequired();
            entity.Property(p => p.Status).IsRequired().HasDefaultValue("Pendente");
            entity.Property(p => p.ValorComissao).HasDefaultValue(0.0);
            entity.Property(p => p.StatusCorretagem).HasDefaultValue("Pendente");

            entity.HasOne(p => p.Empresa)
                  .WithMany()
                  .HasForeignKey(p => p.EmpresaId)
                  .OnDelete(DeleteBehavior.SetNull);

            entity.Property(p => p.DadosEspecificos)
                  .HasConversion(
                      v => v.ValueKind == JsonValueKind.Undefined ? "{}" : JsonSerializer.Serialize(v, (JsonSerializerOptions?)null),
                      v => string.IsNullOrEmpty(v) ? JsonDocument.Parse("{}").RootElement.Clone() : JsonDocument.Parse(v).RootElement.Clone()
                  );
        });

        // Configuracoes Table mapping
        modelBuilder.Entity<Configuracao>(entity =>
        {
            entity.ToTable("configuracaos");
            entity.HasKey(c => c.Chave);
            entity.Property(c => c.Valor).IsRequired();
        });

        // PedidosAnalise Table mapping
        modelBuilder.Entity<PedidoAnalise>(entity =>
        {
            entity.ToTable("pedido_analises");
            entity.HasKey(p => p.Id);
            entity.Property(p => p.TipoAcao).IsRequired();
            entity.Property(p => p.EntidadeId).IsRequired();
            entity.Property(p => p.EntidadeTipo).IsRequired();
            entity.Property(p => p.Status).HasDefaultValue("Pendente");
        });

        // TiposProposta Table mapping
        modelBuilder.Entity<TipoProposta>(entity =>
        {
            entity.ToTable("tipo_proposta");
            entity.HasKey(t => t.Id);
            entity.Property(t => t.Nome).IsRequired();
            entity.HasIndex(t => t.Nome).IsUnique();
            entity.Property(t => t.Chave).IsRequired();
            entity.HasIndex(t => t.Chave).IsUnique();

            entity.Property(t => t.Campos)
                  .HasConversion(
                      v => JsonSerializer.Serialize(v, (JsonSerializerOptions?)null),
                      v => string.IsNullOrEmpty(v) ? new List<CampoTipoProposta>() : JsonSerializer.Deserialize<List<CampoTipoProposta>>(v, (JsonSerializerOptions?)null) ?? new List<CampoTipoProposta>()
                  );
        });

        // Perfis Table mapping
        modelBuilder.Entity<Perfil>(entity =>
        {
            entity.ToTable("perfils");
            entity.HasKey(p => p.Id);
            entity.Property(p => p.Nome).IsRequired();
            entity.HasIndex(p => p.Nome).IsUnique();
            entity.Property(p => p.IsSistema).HasDefaultValue(false);

            entity.Property(p => p.Permissoes)
                  .HasConversion(
                      v => JsonSerializer.Serialize(v, (JsonSerializerOptions?)null),
                      v => string.IsNullOrEmpty(v) ? new List<string>() : JsonSerializer.Deserialize<List<string>>(v, (JsonSerializerOptions?)null) ?? new List<string>()
                  );
        });

        // Usuarios Table mapping
        modelBuilder.Entity<Usuario>(entity =>
        {
            entity.ToTable("usuarios");
            entity.HasKey(u => u.Id);
            entity.Property(u => u.Nome).IsRequired();
            entity.Property(u => u.Email).IsRequired();
            entity.HasIndex(u => u.Email).IsUnique();
            entity.Property(u => u.SenhaHash).IsRequired().HasColumnName("senha_hash");
            entity.Property(u => u.PerfilId).IsRequired();
            entity.Property(u => u.Ativo).HasDefaultValue(true);

            entity.HasOne(u => u.Perfil)
                  .WithMany()
                  .HasForeignKey(u => u.PerfilId)
                  .OnDelete(DeleteBehavior.Restrict);
        });

        // Convert remaining Column Names to snake_case matching Go's GORM convention
        foreach (var entity in modelBuilder.Model.GetEntityTypes())
        {
            foreach (var property in entity.GetProperties())
            {
                var storeObjectIdentifier = Microsoft.EntityFrameworkCore.Metadata.StoreObjectIdentifier.Table(entity.GetTableName()!, entity.GetSchema());
                var currentColumnName = property.GetColumnName(storeObjectIdentifier);
                if (currentColumnName != null)
                {
                    property.SetColumnName(ToSnakeCase(currentColumnName));
                }
            }
        }
    }

    private static string ToSnakeCase(string input)
    {
        if (string.IsNullOrEmpty(input)) return input;

        // Custom mappings for casing edge cases
        if (input.Equals("CPFCNPJ", StringComparison.OrdinalIgnoreCase) || input.Equals("CpfCnpj", StringComparison.OrdinalIgnoreCase))
            return "cpf_cnpj";
        if (input.Equals("PerfilId", StringComparison.OrdinalIgnoreCase))
            return "perfil_id";
        if (input.Equals("ClienteId", StringComparison.OrdinalIgnoreCase))
            return "cliente_id";
        if (input.Equals("EmpresaId", StringComparison.OrdinalIgnoreCase))
            return "empresa_id";
        if (input.Equals("EntidadeId", StringComparison.OrdinalIgnoreCase))
            return "entidade_id";
        if (input.Equals("SenhaHash", StringComparison.OrdinalIgnoreCase))
            return "senha_hash";

        var startUnderscore = input.StartsWith("_");
        var result = System.Text.RegularExpressions.Regex.Replace(input, @"([a-z0-9])([A-Z])", "$1_$2").ToLower();
        return startUnderscore ? "_" + result : result;
    }
}

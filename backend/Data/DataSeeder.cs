using Microsoft.EntityFrameworkCore;
using PortalProposta.Models;

namespace PortalProposta.Data;

public static class DataSeeder
{
    public static async Task SeedAsync(AppDbContext db)
    {
        db.Database.EnsureCreated();
        db.Database.ExecuteSqlRaw("PRAGMA foreign_keys = ON;");

        await MigrateLegacyTypesAsync(db);
        await SeedSettingsAsync(db);
        await SeedProposalTypesAsync(db);
        await SeedProfilesAsync(db);
        await SeedDefaultAdminAsync(db);
    }

    private static async Task MigrateLegacyTypesAsync(AppDbContext db)
    {
        // 'CompraVenda' → 'Comissionados' migration
        var legacyType = await db.TiposProposta.FirstOrDefaultAsync(t => t.Chave == "CompraVenda");
        if (legacyType != null)
        {
            legacyType.Nome = "Comissionados (PVA)";
            legacyType.Chave = "Comissionados";
        }

        var legacyProposals = db.Propostas.Where(p => p.Tipo == "CompraVenda");
        foreach (var p in legacyProposals)
            p.Tipo = "Comissionados";

        var comissionadosType = await db.TiposProposta.FirstOrDefaultAsync(t => t.Chave == "Comissionados");
        if (comissionadosType != null)
            comissionadosType.Nome = "Comissionados (PVA)";

        await db.SaveChangesAsync();
    }

    private static async Task SeedSettingsAsync(AppDbContext db)
    {
        if (!await db.Configuracoes.AnyAsync(c => c.Chave == "taxa_corretagem"))
            db.Configuracoes.Add(new() { Chave = "taxa_corretagem", Valor = "5.00" });

        if (!await db.Configuracoes.AnyAsync(c => c.Chave == "senha_supervisor"))
            db.Configuracoes.Add(new() { Chave = "senha_supervisor", Valor = "123" });

        await db.SaveChangesAsync();
    }

    private static async Task SeedProposalTypesAsync(AppDbContext db)
    {
        if (await db.TiposProposta.AnyAsync()) return;

        db.TiposProposta.AddRange(
            new TipoProposta
            {
                Id = "1",
                Nome = "Imobiliária",
                Chave = "Imobiliaria",
                Campos =
                [
                    new() { Nome = "Endereço Completo do Imóvel", Chave = "endereco_imovel", Tipo = "text", Obrigatorio = true },
                    new() { Nome = "Tipo do Imóvel", Chave = "tipo_imovel", Tipo = "text", Obrigatorio = true },
                    new() { Nome = "Área Privativa (m²)", Chave = "area_m2", Tipo = "number", Obrigatorio = true }
                ],
                CreatedAt = DateTime.Now,
                UpdatedAt = DateTime.Now
            },
            new TipoProposta
            {
                Id = "2",
                Nome = "Automotiva",
                Chave = "Auto",
                Campos =
                [
                    new() { Nome = "Marca", Chave = "marca", Tipo = "text", Obrigatorio = true },
                    new() { Nome = "Modelo", Chave = "modelo", Tipo = "text", Obrigatorio = true },
                    new() { Nome = "Ano de Fabricação", Chave = "ano", Tipo = "number", Obrigatorio = true },
                    new() { Nome = "Placa do Veículo", Chave = "placa", Tipo = "text", Obrigatorio = true }
                ],
                CreatedAt = DateTime.Now,
                UpdatedAt = DateTime.Now
            },
            new TipoProposta
            {
                Id = "3",
                Nome = "Comissionados (PVA)",
                Chave = "Comissionados",
                Campos =
                [
                    new() { Nome = "Descrição dos Itens / Serviços", Chave = "itens", Tipo = "text", Obrigatorio = true },
                    new() { Nome = "Condições de Pagamento", Chave = "condicoes_pagamento", Tipo = "text", Obrigatorio = true }
                ],
                CreatedAt = DateTime.Now,
                UpdatedAt = DateTime.Now
            }
        );

        await db.SaveChangesAsync();
    }

    private static async Task SeedProfilesAsync(AppDbContext db)
    {
        if (await db.Perfis.AnyAsync()) return;

        db.Perfis.AddRange(
            new Perfil
            {
                Id = "perfil-super-admin",
                Nome = "Super Admin",
                Descricao = "Acesso total ao sistema sem restrições",
                Permissoes = ["*"],
                IsSistema = true,
                CreatedAt = DateTime.Now,
                UpdatedAt = DateTime.Now
            },
            new Perfil
            {
                Id = "perfil-admin",
                Nome = "Administrador",
                Descricao = "Acesso administrativo completo ao sistema",
                Permissoes = ["clients.read", "clients.write", "proposals.read", "proposals.write",
                              "companies.read", "companies.write", "dashboard.read", "settings.read"],
                IsSistema = true,
                CreatedAt = DateTime.Now,
                UpdatedAt = DateTime.Now
            },
            new Perfil
            {
                Id = "perfil-operator",
                Nome = "Operador",
                Descricao = "Acesso de leitura e operações básicas",
                Permissoes = ["clients.read", "proposals.read", "companies.read", "dashboard.read"],
                IsSistema = false,
                CreatedAt = DateTime.Now,
                UpdatedAt = DateTime.Now
            }
        );

        await db.SaveChangesAsync();
    }

    private static async Task SeedDefaultAdminAsync(AppDbContext db)
    {
        if (await db.Usuarios.AnyAsync()) return;

        db.Usuarios.Add(new Usuario
        {
            Id = "usuario-super-admin",
            Nome = "Administrador",
            Email = "admin@sistema.com",
            SenhaHash = "240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9",
            PerfilId = "perfil-super-admin",
            Ativo = true,
            CreatedAt = DateTime.Now,
            UpdatedAt = DateTime.Now
        });

        await db.SaveChangesAsync();
    }
}

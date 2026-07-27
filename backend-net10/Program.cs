using System.Text.Json;
using Microsoft.EntityFrameworkCore;
using backend_net10.Data;
using backend_net10.Models;
using backend_net10.Services;
using backend_net10.Infrastructure;

var builder = WebApplication.CreateBuilder(args);

// Ensure correct port configuration
var port = Environment.GetEnvironmentVariable("PORT") ?? "8080";
builder.WebHost.UseUrls($"http://*:{port}");

// Add services to the container.
builder.Services.AddControllers();

// Configure OpenAPI
builder.Services.AddOpenApi();

// SQLite Path Configuration
var dbPath = Environment.GetEnvironmentVariable("DB_PATH") ?? "propostas.db";
var connectionString = $"Data Source={dbPath}";
builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseSqlite(connectionString));

// Register application services
builder.Services.AddScoped<ClienteService>();
builder.Services.AddScoped<EmpresaService>();
builder.Services.AddScoped<ConfiguracaoService>();
builder.Services.AddScoped<TipoPropostaService>();
builder.Services.AddScoped<PerfilService>();
builder.Services.AddScoped<UsuarioService>();
builder.Services.AddScoped<SupervisorService>();
builder.Services.AddScoped<PropostaService>();

// Global Exception Handler
builder.Services.AddExceptionHandler<GlobalExceptionHandler>();
builder.Services.AddProblemDetails();

// CORS Settings
// Max preflight age 300s, specific allowed methods, headers and origins
builder.Services.AddCors(options =>
{
    options.AddPolicy("CorsPolicy", policy =>
    {
        policy.WithOrigins("http://localhost:4200")
              .WithMethods("GET", "POST", "PUT", "DELETE", "OPTIONS")
              .WithHeaders("Accept", "Authorization", "Content-Type", "X-CSRF-Token", "X-User-ID")
              .AllowCredentials()
              .SetPreflightMaxAge(TimeSpan.FromSeconds(300));
    });
});

var app = builder.Build();

// Run Database Creation, Migrations and Seeding
using (var scope = app.Services.CreateScope())
{
    var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
    
    // Ensure database file and schema is created
    db.Database.EnsureCreated();

    // Enable SQLite foreign keys manually just to be safe
    db.Database.ExecuteSqlRaw("PRAGMA foreign_keys = ON;");

    // Perform Legacies Migration
    var legacyType = db.TiposProposta.FirstOrDefault(t => t.Chave == "CompraVenda");
    if (legacyType != null)
    {
        legacyType.Nome = "Comissionados (PVA)";
        legacyType.Chave = "Comissionados";
    }

    var legacyProposals = db.Propostas.Where(p => p.Tipo == "CompraVenda").ToList();
    foreach (var p in legacyProposals)
    {
        p.Tipo = "Comissionados";
    }

    var comissionadosType = db.TiposProposta.FirstOrDefault(t => t.Chave == "Comissionados");
    if (comissionadosType != null)
    {
        comissionadosType.Nome = "Comissionados (PVA)";
    }
    db.SaveChanges();

    // Settings seed
    if (!db.Configuracoes.Any(c => c.Chave == "taxa_corretagem"))
    {
        db.Configuracoes.Add(new Configuracao { Chave = "taxa_corretagem", Valor = "5.00" });
    }
    if (!db.Configuracoes.Any(c => c.Chave == "senha_supervisor"))
    {
        db.Configuracoes.Add(new Configuracao { Chave = "senha_supervisor", Valor = "123" });
    }
    db.SaveChanges();

    // Proposal types seeds
    if (!db.TiposProposta.Any())
    {
        db.TiposProposta.Add(new TipoProposta
        {
            Id = "1",
            Nome = "Imobiliária",
            Chave = "Imobiliaria",
            Campos = JsonSerializer.Deserialize<List<CampoTipoProposta>>(@"[
                {""nome"":""Endereço Completo do Imóvel"",""chave"":""endereco_imovel"",""tipo"":""text"",""obrigatorio"":true},
                {""nome"":""Tipo do Imóvel"",""chave"":""tipo_imovel"",""tipo"":""text"",""obrigatorio"":true},
                {""nome"":""Área Privativa (m²)"",""chave"":""area_m2"",""tipo"":""number"",""obrigatorio"":true}
            ]")!,
            CreatedAt = DateTime.Now,
            UpdatedAt = DateTime.Now
        });

        db.TiposProposta.Add(new TipoProposta
        {
            Id = "2",
            Nome = "Automotiva",
            Chave = "Auto",
            Campos = JsonSerializer.Deserialize<List<CampoTipoProposta>>(@"[
                {""nome"":""Marca"",""chave"":""marca"",""tipo"":""text"",""obrigatorio"":true},
                {""nome"":""Modelo"",""chave"":""modelo"",""tipo"":""text"",""obrigatorio"":true},
                {""nome"":""Ano de Fabricação"",""chave"":""ano"",""tipo"":""number"",""obrigatorio"":true},
                {""nome"":""Placa do Veículo"",""chave"":""placa"",""tipo"":""text"",""obrigatorio"":true}
            ]")!,
            CreatedAt = DateTime.Now,
            UpdatedAt = DateTime.Now
        });

        db.TiposProposta.Add(new TipoProposta
        {
            Id = "3",
            Nome = "Comissionados (PVA)",
            Chave = "Comissionados",
            Campos = JsonSerializer.Deserialize<List<CampoTipoProposta>>(@"[
                {""nome"":""Descrição dos Itens / Serviços"",""chave"":""itens"",""tipo"":""text"",""obrigatorio"":true},
                {""nome"":""Condições de Pagamento"",""chave"":""condicoes_pagamento"",""tipo"":""text"",""obrigatorio"":true}
            ]")!,
            CreatedAt = DateTime.Now,
            UpdatedAt = DateTime.Now
        });
        db.SaveChanges();
    }

    // Profiles seeds
    if (!db.Perfis.Any())
    {
        db.Perfis.Add(new Perfil
        {
            Id = "perfil-super-admin",
            Nome = "Super Admin",
            Descricao = "Acesso total ao sistema sem restrições",
            Permissoes = new List<string> { "*" },
            IsSistema = true,
            CreatedAt = DateTime.Now,
            UpdatedAt = DateTime.Now
        });

        db.Perfis.Add(new Perfil
        {
            Id = "perfil-admin",
            Nome = "Administrador",
            Descricao = "Acesso administrativo completo ao sistema",
            Permissoes = new List<string> { "clients.read", "clients.write", "proposals.read", "proposals.write", "companies.read", "companies.write", "dashboard.read", "settings.read" },
            IsSistema = true,
            CreatedAt = DateTime.Now,
            UpdatedAt = DateTime.Now
        });

        db.Perfis.Add(new Perfil
        {
            Id = "perfil-operator",
            Nome = "Operador",
            Descricao = "Acesso de leitura e operações básicas",
            Permissoes = new List<string> { "clients.read", "proposals.read", "companies.read", "dashboard.read" },
            IsSistema = false,
            CreatedAt = DateTime.Now,
            UpdatedAt = DateTime.Now
        });
        db.SaveChanges();
    }

    // Default admin user seed
    if (!db.Usuarios.Any())
    {
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
        db.SaveChanges();
    }
}

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.MapOpenApi();
}

app.UseExceptionHandler();

app.UseCors("CorsPolicy");

app.UseAuthorization();

app.MapControllers();

app.Run();

using Microsoft.EntityFrameworkCore;
using PortalProposta.Data;
using PortalProposta.Services;
using PortalProposta.Infrastructure;

var builder = WebApplication.CreateBuilder(args);

// Port configuration
var port = Environment.GetEnvironmentVariable("PORT") ?? "8080";
builder.WebHost.UseUrls($"http://*:{port}");

// Services
builder.Services.AddControllers();
builder.Services.AddOpenApi();

// SQLite
var dbPath = Environment.GetEnvironmentVariable("DB_PATH") ?? "propostas.db";
builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseSqlite($"Data Source={dbPath}"));

// Domain services
builder.Services.AddScoped<ClienteService>();
builder.Services.AddScoped<EmpresaService>();
builder.Services.AddScoped<ConfiguracaoService>();
builder.Services.AddScoped<TipoPropostaService>();
builder.Services.AddScoped<PerfilService>();
builder.Services.AddScoped<UsuarioService>();
builder.Services.AddScoped<SupervisorService>();
builder.Services.AddScoped<PropostaService>();

// Exception handling
builder.Services.AddExceptionHandler<GlobalExceptionHandler>();
builder.Services.AddProblemDetails();

// CORS
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

// Database seeding
using (var scope = app.Services.CreateScope())
{
    var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
    await DataSeeder.SeedAsync(db);
}

// Pipeline
if (app.Environment.IsDevelopment())
    app.MapOpenApi();

app.UseExceptionHandler();
app.UseCors("CorsPolicy");
app.UseAuthorization();
app.MapControllers();

Console.WriteLine($"🚀 Backend rodando em http://localhost:{port}");
app.Run();

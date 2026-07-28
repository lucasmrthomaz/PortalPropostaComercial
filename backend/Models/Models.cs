using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Text.Json;
using System.Text.Json.Serialization;

namespace PortalProposta.Models;

[Table("clientes")]
public class Cliente
{
    [Key]
    public string Id { get; set; } = string.Empty;

    [Required]
    public string Nome { get; set; } = string.Empty;

    [Required]
    [Column("cpf_cnpj")]
    public string CPFCNPJ { get; set; } = string.Empty;

    [Required]
    public string Email { get; set; } = string.Empty;

    public string? Telefone { get; set; }
    public string? Endereco { get; set; }

    [Column("created_at")]
    public DateTime CreatedAt { get; set; }

    [Column("updated_at")]
    public DateTime UpdatedAt { get; set; }

    [JsonIgnore(Condition = JsonIgnoreCondition.WhenWritingNull)]
    public List<Proposta>? Propostas { get; set; }
}

[Table("proposta")]
public class Proposta
{
    [Key]
    public string Id { get; set; } = string.Empty;

    [Required]
    [Column("cliente_id")]
    public string ClienteId { get; set; } = string.Empty;

    [Required]
    public string Tipo { get; set; } = string.Empty;

    [Required]
    public double Valor { get; set; }

    [Required]
    public string Status { get; set; } = "Pendente";

    public string? Descricao { get; set; }

    [Column("dados_especificos")]
    public JsonElement DadosEspecificos { get; set; }

    [Column("empresa_id")]
    public string? EmpresaId { get; set; }

    public Empresa? Empresa { get; set; }

    [Column("status_corretagem")]
    public string StatusCorretagem { get; set; } = "Pendente";

    [Column("valor_comissao")]
    public double ValorComissao { get; set; }

    [Column("created_at")]
    public DateTime CreatedAt { get; set; }

    [Column("updated_at")]
    public DateTime UpdatedAt { get; set; }
}

[Table("empresas")]
public class Empresa
{
    [Key]
    public string Id { get; set; } = string.Empty;

    [Required]
    public string Nome { get; set; } = string.Empty;

    [Required]
    public string CNPJ { get; set; } = string.Empty;

    [Required]
    public string Email { get; set; } = string.Empty;

    public string? Telefone { get; set; }

    [Column("responsavel_nome")]
    public string? ResponsavelNome { get; set; }

    [Column("responsavel_email")]
    public string? ResponsavelEmail { get; set; }

    [Column("responsavel_telefone")]
    public string? ResponsavelTelefone { get; set; }

    public bool Ativo { get; set; } = true;

    [Column("created_at")]
    public DateTime CreatedAt { get; set; }

    [Column("updated_at")]
    public DateTime UpdatedAt { get; set; }
}

[Table("configuracaos")]
public class Configuracao
{
    [Key]
    public string Chave { get; set; } = string.Empty;

    [Required]
    public string Valor { get; set; } = string.Empty;
}

[Table("tipo_proposta")]
public class TipoProposta
{
    [Key]
    public string Id { get; set; } = string.Empty;

    [Required]
    public string Nome { get; set; } = string.Empty;

    [Required]
    public string Chave { get; set; } = string.Empty;

    [JsonConverter(typeof(CamposTipoPropostaConverter))]
    public List<CampoTipoProposta> Campos { get; set; } = new();

    [Column("created_at")]
    public DateTime CreatedAt { get; set; }

    [Column("updated_at")]
    public DateTime UpdatedAt { get; set; }
}

[Table("pedido_analises")]
public class PedidoAnalise
{
    [Key]
    public string Id { get; set; } = string.Empty;

    [Required]
    [Column("tipo_acao")]
    public string TipoAcao { get; set; } = string.Empty;

    [Required]
    [Column("entidade_id")]
    public string EntidadeId { get; set; } = string.Empty;

    [Required]
    [Column("entidade_tipo")]
    public string EntidadeTipo { get; set; } = string.Empty;

    public string? Descricao { get; set; }

    public string Status { get; set; } = "Pendente";

    [Column("solicitado_por")]
    public string? SolicitadoPor { get; set; }

    [Column("dados_acao")]
    public string? DadosAcao { get; set; }

    [Column("created_at")]
    public DateTime CreatedAt { get; set; }

    [Column("updated_at")]
    public DateTime UpdatedAt { get; set; }
}

[Table("perfils")]
public class Perfil
{
    [Key]
    public string Id { get; set; } = string.Empty;

    [Required]
    public string Nome { get; set; } = string.Empty;

    public string? Descricao { get; set; }

    [JsonConverter(typeof(PermissoesConverter))]
    public List<string> Permissoes { get; set; } = new();

    [Column("is_sistema")]
    public bool IsSistema { get; set; }

    [Column("created_at")]
    public DateTime CreatedAt { get; set; }

    [Column("updated_at")]
    public DateTime UpdatedAt { get; set; }
}

[Table("usuarios")]
public class Usuario
{
    [Key]
    public string Id { get; set; } = string.Empty;

    [Required]
    public string Nome { get; set; } = string.Empty;

    [Required]
    public string Email { get; set; } = string.Empty;

    [JsonIgnore]
    [Column("senha_hash")]
    public string SenhaHash { get; set; } = string.Empty;

    [Required]
    [Column("perfil_id")]
    public string PerfilId { get; set; } = string.Empty;

    public Perfil? Perfil { get; set; }

    public bool Ativo { get; set; } = true;

    [Column("created_at")]
    public DateTime CreatedAt { get; set; }

    [Column("updated_at")]
    public DateTime UpdatedAt { get; set; }

    public UsuarioResponse ToResponse() => new()
    {
        Id = Id,
        Nome = Nome,
        Email = Email,
        PerfilId = PerfilId,
        Perfil = Perfil,
        Ativo = Ativo,
        CreatedAt = CreatedAt,
        UpdatedAt = UpdatedAt
    };
}

public class UsuarioResponse
{
    public string Id { get; set; } = string.Empty;
    public string Nome { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;

    [JsonPropertyName("perfil_id")]
    public string PerfilId { get; set; } = string.Empty;

    public Perfil? Perfil { get; set; }
    public bool Ativo { get; set; }

    [JsonPropertyName("created_at")]
    public DateTime CreatedAt { get; set; }

    [JsonPropertyName("updated_at")]
    public DateTime UpdatedAt { get; set; }
}

public class CampoTipoProposta
{
    [JsonPropertyName("nome")]
    public string Nome { get; set; } = string.Empty;
    
    [JsonPropertyName("chave")]
    public string Chave { get; set; } = string.Empty;
    
    [JsonPropertyName("tipo")]
    public string Tipo { get; set; } = string.Empty;
    
    [JsonPropertyName("obrigatorio")]
    public bool Obrigatorio { get; set; }
}

// ==========================================
// JSON Converters for EF Core
// ==========================================

public class CamposTipoPropostaConverter : JsonConverter<List<CampoTipoProposta>>
{
    public override List<CampoTipoProposta> Read(ref Utf8JsonReader reader, Type typeToConvert, JsonSerializerOptions options)
    {
        if (reader.TokenType == JsonTokenType.Null)
            return new List<CampoTipoProposta>();
        return JsonSerializer.Deserialize<List<CampoTipoProposta>>(ref reader, options) ?? new();
    }

    public override void Write(Utf8JsonWriter writer, List<CampoTipoProposta> value, JsonSerializerOptions options)
        => JsonSerializer.Serialize(writer, value, options);
}

public class PermissoesConverter : JsonConverter<List<string>>
{
    public override List<string> Read(ref Utf8JsonReader reader, Type typeToConvert, JsonSerializerOptions options)
    {
        if (reader.TokenType == JsonTokenType.Null)
            return new List<string>();
        return JsonSerializer.Deserialize<List<string>>(ref reader, options) ?? new();
    }

    public override void Write(Utf8JsonWriter writer, List<string> value, JsonSerializerOptions options)
        => JsonSerializer.Serialize(writer, value, options);
}

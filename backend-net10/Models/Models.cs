using System.Text.Json;
using System.Text.Json.Serialization;

namespace backend_net10.Models;

public class Cliente
{
    public string Id { get; set; } = string.Empty;
    public string Nome { get; set; } = string.Empty;
    
    [JsonPropertyName("cpf_cnpj")]
    public string CPFCNPJ { get; set; } = string.Empty;
    
    public string Email { get; set; } = string.Empty;
    public string? Telefone { get; set; }
    public string? Endereco { get; set; }
    
    [JsonPropertyName("created_at")]
    public DateTime CreatedAt { get; set; }
    
    [JsonPropertyName("updated_at")]
    public DateTime UpdatedAt { get; set; }

    [JsonIgnore(Condition = JsonIgnoreCondition.WhenWritingNull)]
    public List<Proposta>? Propostas { get; set; }
}

public class Proposta
{
    public string Id { get; set; } = string.Empty;

    [JsonPropertyName("cliente_id")]
    public string ClienteId { get; set; } = string.Empty;
    
    public string Tipo { get; set; } = string.Empty; // "Imobiliaria", "Auto", "Comissionados", etc.
    public double Valor { get; set; }
    public string Status { get; set; } = "Pendente"; // "Pendente", "Aprovada", "Recusada", "Em Analise"
    public string? Descricao { get; set; }
    
    [JsonPropertyName("dados_especificos")]
    public JsonElement DadosEspecificos { get; set; }
    
    [JsonPropertyName("empresa_id")]
    public string? EmpresaId { get; set; }
    
    public Empresa? Empresa { get; set; }
    
    [JsonPropertyName("status_corretagem")]
    public string StatusCorretagem { get; set; } = "Pendente";
    
    [JsonPropertyName("valor_comissao")]
    public double ValorComissao { get; set; }
    
    [JsonPropertyName("created_at")]
    public DateTime CreatedAt { get; set; }
    
    [JsonPropertyName("updated_at")]
    public DateTime UpdatedAt { get; set; }
}

public class Empresa
{
    public string Id { get; set; } = string.Empty;
    public string Nome { get; set; } = string.Empty;
    public string CNPJ { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public string? Telefone { get; set; }
    
    [JsonPropertyName("responsavel_nome")]
    public string? ResponsavelNome { get; set; }
    
    [JsonPropertyName("responsavel_email")]
    public string? ResponsavelEmail { get; set; }
    
    [JsonPropertyName("responsavel_telefone")]
    public string? ResponsavelTelefone { get; set; }
    
    public bool Ativo { get; set; } = true;
    
    [JsonPropertyName("created_at")]
    public DateTime CreatedAt { get; set; }
    
    [JsonPropertyName("updated_at")]
    public DateTime UpdatedAt { get; set; }
}

public class Configuracao
{
    public string Chave { get; set; } = string.Empty;
    public string Valor { get; set; } = string.Empty;
}

public class CampoTipoProposta
{
    [JsonPropertyName("nome")]
    public string Nome { get; set; } = string.Empty;
    
    [JsonPropertyName("chave")]
    public string Chave { get; set; } = string.Empty;
    
    [JsonPropertyName("tipo")]
    public string Tipo { get; set; } = string.Empty; // "text", "number", "boolean"
    
    [JsonPropertyName("obrigatorio")]
    public bool Obrigatorio { get; set; }
}

public class TipoProposta
{
    public string Id { get; set; } = string.Empty;
    public string Nome { get; set; } = string.Empty;
    public string Chave { get; set; } = string.Empty;
    
    [JsonPropertyName("campos")]
    public List<CampoTipoProposta> Campos { get; set; } = new();
    
    [JsonPropertyName("created_at")]
    public DateTime CreatedAt { get; set; }
    
    [JsonPropertyName("updated_at")]
    public DateTime UpdatedAt { get; set; }
}

public class PedidoAnalise
{
    public string Id { get; set; } = string.Empty;
    
    [JsonPropertyName("tipo_acao")]
    public string TipoAcao { get; set; } = string.Empty;
    
    [JsonPropertyName("entidade_id")]
    public string EntidadeId { get; set; } = string.Empty;
    
    [JsonPropertyName("entidade_tipo")]
    public string EntidadeTipo { get; set; } = string.Empty;
    
    public string? Descricao { get; set; }
    public string Status { get; set; } = "Pendente";
    
    [JsonPropertyName("solicitado_por")]
    public string? SolicitadoPor { get; set; }
    
    [JsonPropertyName("dados_acao")]
    public string? DadosAcao { get; set; }
    
    [JsonPropertyName("created_at")]
    public DateTime CreatedAt { get; set; }
    
    [JsonPropertyName("updated_at")]
    public DateTime UpdatedAt { get; set; }
}

public class Perfil
{
    public string Id { get; set; } = string.Empty;
    public string Nome { get; set; } = string.Empty;
    public string? Descricao { get; set; }
    
    [JsonPropertyName("permissoes")]
    public List<string> Permissoes { get; set; } = new();
    
    [JsonPropertyName("is_sistema")]
    public bool IsSistema { get; set; }
    
    [JsonPropertyName("created_at")]
    public DateTime CreatedAt { get; set; }
    
    [JsonPropertyName("updated_at")]
    public DateTime UpdatedAt { get; set; }
}

public class Usuario
{
    public string Id { get; set; } = string.Empty;
    public string Nome { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    
    [JsonIgnore]
    public string SenhaHash { get; set; } = string.Empty;
    
    [JsonPropertyName("perfil_id")]
    public string PerfilId { get; set; } = string.Empty;
    
    public Perfil? Perfil { get; set; }
    public bool Ativo { get; set; } = true;
    
    [JsonPropertyName("created_at")]
    public DateTime CreatedAt { get; set; }
    
    [JsonPropertyName("updated_at")]
    public DateTime UpdatedAt { get; set; }

    public UsuarioResponse ToResponse()
    {
        return new UsuarioResponse
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

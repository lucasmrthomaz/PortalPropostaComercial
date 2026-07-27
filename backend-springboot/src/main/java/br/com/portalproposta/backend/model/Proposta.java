package br.com.portalproposta.backend.model;

import br.com.portalproposta.backend.model.converter.JsonNodeConverter;
import com.fasterxml.jackson.annotation.JsonProperty;
import tools.jackson.databind.JsonNode;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Entity
@Table(name = "proposta")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Proposta {

    @Id
    private String id;

    @Column(name = "cliente_id", nullable = false)
    @JsonProperty("cliente_id")
    private String clienteId;

    @Column(nullable = false)
    private String tipo;

    @Column(nullable = false)
    private double valor;

    @Column(nullable = false)
    private String status = "Pendente";

    private String descricao;

    @Column(name = "dados_especificos")
    @Convert(converter = JsonNodeConverter.class)
    @JsonProperty("dados_especificos")
    private JsonNode dadosEspecificos;

    @Column(name = "empresa_id")
    @JsonProperty("empresa_id")
    private String empresaId;

    @ManyToOne
    @JoinColumn(name = "empresa_id", insertable = false, updatable = false)
    private Empresa empresa;

    @Column(name = "status_corretagem", nullable = false)
    @JsonProperty("status_corretagem")
    private String statusCorretagem = "Pendente";

    @Column(name = "valor_comissao", nullable = false)
    @JsonProperty("valor_comissao")
    private double valorComissao = 0.0;

    @Column(name = "created_at")
    @JsonProperty("created_at")
    private LocalDateTime createdAt;

    @Column(name = "updated_at")
    @JsonProperty("updated_at")
    private LocalDateTime updatedAt;
}

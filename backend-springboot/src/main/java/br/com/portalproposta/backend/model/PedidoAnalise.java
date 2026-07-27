package br.com.portalproposta.backend.model;

import com.fasterxml.jackson.annotation.JsonProperty;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Entity
@Table(name = "pedido_analises")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PedidoAnalise {

    @Id
    private String id;

    @Column(name = "tipo_acao", nullable = false)
    @JsonProperty("tipo_acao")
    private String tipoAcao;

    @Column(name = "entidade_id", nullable = false)
    @JsonProperty("entidade_id")
    private String entidadeId;

    @Column(name = "entidade_tipo", nullable = false)
    @JsonProperty("entidade_tipo")
    private String entidadeTipo;

    private String descricao;

    @Column(nullable = false)
    private String status = "Pendente";

    @Column(name = "solicitado_por")
    @JsonProperty("solicitado_por")
    private String solicitadoPor;

    @Column(name = "dados_acao")
    @JsonProperty("dados_acao")
    private String dadosAcao;

    @Column(name = "created_at")
    @JsonProperty("created_at")
    private LocalDateTime createdAt;

    @Column(name = "updated_at")
    @JsonProperty("updated_at")
    private LocalDateTime updatedAt;
}

package br.com.portalproposta.backend.model;

import br.com.portalproposta.backend.model.converter.CampoTipoPropostaListConverter;
import com.fasterxml.jackson.annotation.JsonProperty;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "tipo_proposta")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class TipoProposta {

    @Id
    private String id;

    @Column(nullable = false, unique = true)
    private String nome;

    @Column(nullable = false, unique = true)
    private String chave;

    @Column(nullable = false)
    @Convert(converter = CampoTipoPropostaListConverter.class)
    private List<CampoTipoProposta> campos = new ArrayList<>();

    @Column(name = "created_at")
    @JsonProperty("created_at")
    private LocalDateTime createdAt;

    @Column(name = "updated_at")
    @JsonProperty("updated_at")
    private LocalDateTime updatedAt;
}

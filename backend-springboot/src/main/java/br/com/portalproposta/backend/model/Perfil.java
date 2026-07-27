package br.com.portalproposta.backend.model;

import br.com.portalproposta.backend.model.converter.StringListConverter;
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
@Table(name = "perfils")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Perfil {

    @Id
    private String id;

    @Column(nullable = false, unique = true)
    private String nome;

    private String descricao;

    @Column(nullable = false)
    @Convert(converter = StringListConverter.class)
    private List<String> permissoes = new ArrayList<>();

    @Column(name = "is_sistema", nullable = false)
    @JsonProperty("is_sistema")
    private boolean isSistema = false;

    @Column(name = "created_at")
    @JsonProperty("created_at")
    private LocalDateTime createdAt;

    @Column(name = "updated_at")
    @JsonProperty("updated_at")
    private LocalDateTime updatedAt;
}

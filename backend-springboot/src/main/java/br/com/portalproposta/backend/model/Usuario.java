package br.com.portalproposta.backend.model;

import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonProperty;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Entity
@Table(name = "usuarios")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Usuario {

    @Id
    private String id;

    @Column(nullable = false)
    private String nome;

    @Column(nullable = false, unique = true)
    private String email;

    @Column(name = "senha_hash", nullable = false)
    @JsonIgnore
    private String senhaHash;

    @Column(name = "perfil_id", nullable = false)
    @JsonProperty("perfil_id")
    private String perfilId;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "perfil_id", insertable = false, updatable = false)
    private Perfil perfil;

    @Column(nullable = false)
    private boolean ativo = true;

    @Column(name = "created_at")
    @JsonProperty("created_at")
    private LocalDateTime createdAt;

    @Column(name = "updated_at")
    @JsonProperty("updated_at")
    private LocalDateTime updatedAt;

    public UsuarioResponse toResponse() {
        return UsuarioResponse.builder()
                .id(this.id)
                .nome(this.nome)
                .email(this.email)
                .perfilId(this.perfilId)
                .perfil(this.perfil)
                .ativo(this.ativo)
                .createdAt(this.createdAt)
                .updatedAt(this.updatedAt)
                .build();
    }
}

package br.com.portalproposta.backend.model;

import com.fasterxml.jackson.annotation.JsonProperty;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Entity
@Table(name = "empresas")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Empresa {

    @Id
    private String id;

    @Column(nullable = false)
    private String nome;

    @Column(nullable = false, unique = true)
    private String cnpj;

    @Column(nullable = false)
    private String email;

    private String telefone;

    @Column(name = "responsavel_nome")
    @JsonProperty("responsavel_nome")
    private String responsavelNome;

    @Column(name = "responsavel_email")
    @JsonProperty("responsavel_email")
    private String responsavelEmail;

    @Column(name = "responsavel_telefone")
    @JsonProperty("responsavel_telefone")
    private String responsavelTelefone;

    @Column(nullable = false)
    private boolean ativo = true;

    @Column(name = "created_at")
    @JsonProperty("created_at")
    private LocalDateTime createdAt;

    @Column(name = "updated_at")
    @JsonProperty("updated_at")
    private LocalDateTime updatedAt;
}

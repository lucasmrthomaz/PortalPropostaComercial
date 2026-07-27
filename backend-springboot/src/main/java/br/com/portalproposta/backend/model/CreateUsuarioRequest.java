package br.com.portalproposta.backend.model;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;

@Data
public class CreateUsuarioRequest {
    private String nome;
    private String email;
    @JsonProperty("senha")
    private String senha;
    @JsonProperty("perfil_id")
    private String perfilId;
    private boolean ativo;
}

package br.com.portalproposta.backend.model;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;

@Data
public class LoginRequest {
    private String email;
    @JsonProperty("senha")
    private String senha;
}

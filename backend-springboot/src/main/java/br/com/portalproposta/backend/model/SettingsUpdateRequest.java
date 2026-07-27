package br.com.portalproposta.backend.model;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;

@Data
public class SettingsUpdateRequest {
    @JsonProperty("taxa_corretagem")
    private Double taxaCorretagem;

    @JsonProperty("senha_supervisor")
    private String senhaSupervisor;
}

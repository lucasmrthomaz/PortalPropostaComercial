package br.com.portalproposta.backend.model;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class CampoTipoProposta {
    private String nome;
    private String chave;
    private String tipo; // "text", "number", "boolean"
    private boolean obrigatorio;
}

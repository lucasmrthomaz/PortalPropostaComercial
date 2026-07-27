package br.com.portalproposta.backend.model;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Entity
@Table(name = "configuracaos")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Configuracao {

    @Id
    private String chave;

    @Column(nullable = false)
    private String valor;
}

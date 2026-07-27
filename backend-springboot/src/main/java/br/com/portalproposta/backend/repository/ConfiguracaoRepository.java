package br.com.portalproposta.backend.repository;

import br.com.portalproposta.backend.model.Configuracao;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface ConfiguracaoRepository extends JpaRepository<Configuracao, String> {
}

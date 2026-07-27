package br.com.portalproposta.backend.repository;

import br.com.portalproposta.backend.model.TipoProposta;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface TipoPropostaRepository extends JpaRepository<TipoProposta, String> {
    Optional<TipoProposta> findByChave(String chave);

    Optional<TipoProposta> findByNome(String nome);

    List<TipoProposta> findAllByOrderByNomeAsc();
}

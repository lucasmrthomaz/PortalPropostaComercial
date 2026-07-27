package br.com.portalproposta.backend.repository;

import br.com.portalproposta.backend.model.Proposta;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface PropostaRepository extends JpaRepository<Proposta, String> {
    List<Proposta> findByClienteId(String clienteId);

    boolean existsByClienteId(String clienteId);

    long countByTipo(String tipo);
}

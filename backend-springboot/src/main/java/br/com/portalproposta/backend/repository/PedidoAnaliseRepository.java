package br.com.portalproposta.backend.repository;

import br.com.portalproposta.backend.model.PedidoAnalise;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface PedidoAnaliseRepository extends JpaRepository<PedidoAnalise, String> {
    List<PedidoAnalise> findByStatusOrderByCreatedAtDesc(String status);

    List<PedidoAnalise> findAllByOrderByCreatedAtDesc();
}

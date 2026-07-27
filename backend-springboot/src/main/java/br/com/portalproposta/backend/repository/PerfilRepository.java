package br.com.portalproposta.backend.repository;

import br.com.portalproposta.backend.model.Perfil;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface PerfilRepository extends JpaRepository<Perfil, String> {
    Optional<Perfil> findByNome(String nome);

    List<Perfil> findAllByOrderByNomeAsc();
}

package br.com.portalproposta.backend.repository;

import br.com.portalproposta.backend.model.Usuario;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface UsuarioRepository extends JpaRepository<Usuario, String> {
    Optional<Usuario> findByEmail(String email);

    List<Usuario> findAllByOrderByNomeAsc();

    @Query("SELECT COUNT(u) FROM Usuario u JOIN u.perfil p WHERE p.nome = :perfilNome AND u.ativo = :ativo")
    long countByPerfilNomeAndAtivo(@Param("perfilNome") String perfilNome, @Param("ativo") boolean ativo);

    boolean existsByPerfilId(String perfilId);
}

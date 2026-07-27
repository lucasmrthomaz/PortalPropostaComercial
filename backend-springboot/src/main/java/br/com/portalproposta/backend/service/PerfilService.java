package br.com.portalproposta.backend.service;

import br.com.portalproposta.backend.exception.AppBadRequestException;
import br.com.portalproposta.backend.exception.AppNotFoundException;
import br.com.portalproposta.backend.model.Perfil;
import br.com.portalproposta.backend.repository.PerfilRepository;
import br.com.portalproposta.backend.repository.UsuarioRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

@Service
public class PerfilService {

    private final PerfilRepository perfilRepository;
    private final UsuarioRepository usuarioRepository;

    @Autowired
    public PerfilService(PerfilRepository perfilRepository, UsuarioRepository usuarioRepository) {
        this.perfilRepository = perfilRepository;
        this.usuarioRepository = usuarioRepository;
    }

    public List<Perfil> list() {
        return perfilRepository.findAllByOrderByNomeAsc();
    }

    public Perfil getById(String id) {
        return perfilRepository.findById(id)
                .orElseThrow(() -> new AppNotFoundException("perfil de acesso não encontrado"));
    }

    @Transactional
    public Perfil create(Perfil perfil) {
        if (perfil.getNome() == null || perfil.getNome().trim().isEmpty()) {
            throw new AppBadRequestException("nome do perfil é obrigatório");
        }

        perfilRepository.findByNome(perfil.getNome()).ifPresent(existing -> {
            throw new AppBadRequestException("já existe um perfil com este nome");
        });

        perfil.setId(UUID.randomUUID().toString());
        perfil.setCreatedAt(LocalDateTime.now());
        perfil.setUpdatedAt(LocalDateTime.now());

        return perfilRepository.save(perfil);
    }

    @Transactional
    public Perfil update(String id, Perfil input) {
        Perfil perfil = getById(id);

        if (input.getNome() == null || input.getNome().trim().isEmpty()) {
            throw new AppBadRequestException("nome do perfil é obrigatório");
        }

        if (!input.getNome().equals(perfil.getNome())) {
            perfilRepository.findByNome(input.getNome()).ifPresent(existing -> {
                if (!existing.getId().equals(perfil.getId())) {
                    throw new AppBadRequestException("já existe um perfil com este nome");
                }
            });
        }

        if (!perfil.isSistema()) {
            perfil.setNome(input.getNome());
        }

        perfil.setDescricao(input.getDescricao());
        perfil.setPermissoes(input.getPermissoes());
        perfil.setUpdatedAt(LocalDateTime.now());

        return perfilRepository.save(perfil);
    }

    @Transactional
    public void delete(String id) {
        Perfil perfil = getById(id);

        if (perfil.isSistema()) {
            throw new AppBadRequestException("não é permitido excluir perfis do sistema");
        }

        if (usuarioRepository.existsByPerfilId(id)) {
            // Count matching users
            long count = usuarioRepository.findAll().stream().filter(u -> u.getPerfilId().equals(id)).count();
            throw new AppBadRequestException(String
                    .format("não é possível excluir este perfil pois existem %d usuário(s) associado(s) a ele", count));
        }

        perfilRepository.delete(perfil);
    }
}

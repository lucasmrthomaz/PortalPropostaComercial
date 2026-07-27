package br.com.portalproposta.backend.service;

import br.com.portalproposta.backend.exception.AppBadRequestException;
import br.com.portalproposta.backend.exception.AppNotFoundException;
import br.com.portalproposta.backend.exception.AppUnauthorizedException;
import br.com.portalproposta.backend.infrastructure.PasswordHasher;
import br.com.portalproposta.backend.model.Perfil;
import br.com.portalproposta.backend.model.Usuario;
import br.com.portalproposta.backend.repository.PerfilRepository;
import br.com.portalproposta.backend.repository.UsuarioRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

@Service
public class UsuarioService {

    private final UsuarioRepository usuarioRepository;
    private final PerfilRepository perfilRepository;

    @Autowired
    public UsuarioService(UsuarioRepository usuarioRepository, PerfilRepository perfilRepository) {
        this.usuarioRepository = usuarioRepository;
        this.perfilRepository = perfilRepository;
    }

    public List<Usuario> list() {
        return usuarioRepository.findAllByOrderByNomeAsc();
    }

    public Usuario getById(String id) {
        return usuarioRepository.findById(id)
                .orElseThrow(() -> new AppNotFoundException("usuário não encontrado"));
    }

    @Transactional
    public Usuario create(Usuario user, String password) {
        if (user.getNome() == null || user.getNome().trim().isEmpty()) {
            throw new AppBadRequestException("nome do usuário é obrigatório");
        }

        if (user.getEmail() == null || user.getEmail().trim().isEmpty() || !user.getEmail().contains("@")) {
            throw new AppBadRequestException("email do usuário é obrigatório ou inválido");
        }

        Perfil perfilObj = perfilRepository.findById(user.getPerfilId())
                .orElseThrow(() -> new AppNotFoundException("perfil de acesso não encontrado"));

        usuarioRepository.findByEmail(user.getEmail()).ifPresent(existing -> {
            throw new AppBadRequestException("já existe um usuário com este email");
        });

        if (password == null || password.trim().isEmpty()) {
            throw new AppBadRequestException("a senha é obrigatória");
        }

        user.setId(UUID.randomUUID().toString());
        user.setSenhaHash(PasswordHasher.hashPassword(password));
        user.setCreatedAt(LocalDateTime.now());
        user.setUpdatedAt(LocalDateTime.now());

        Usuario saved = usuarioRepository.save(user);
        saved.setPerfil(perfilObj);
        return saved;
    }

    @Transactional
    public Usuario update(String id, Usuario input, String newPassword) {
        Usuario user = getById(id);

        if (input.getNome() == null || input.getNome().trim().isEmpty()) {
            throw new AppBadRequestException("nome do usuário é obrigatório");
        }

        if (input.getEmail() == null || input.getEmail().trim().isEmpty() || !input.getEmail().contains("@")) {
            throw new AppBadRequestException("email do usuário é obrigatório ou inválido");
        }

        if (!input.getEmail().equals(user.getEmail())) {
            usuarioRepository.findByEmail(input.getEmail()).ifPresent(existing -> {
                if (!existing.getId().equals(user.getId())) {
                    throw new AppBadRequestException("já existe um usuário com este email");
                }
            });
            user.setEmail(input.getEmail());
        }

        if (input.getPerfilId() != null && !input.getPerfilId().isEmpty()
                && !input.getPerfilId().equals(user.getPerfilId())) {
            Perfil perfilObj = perfilRepository.findById(input.getPerfilId())
                    .orElseThrow(() -> new AppNotFoundException("perfil de acesso não encontrado"));
            user.setPerfilId(input.getPerfilId());
            user.setPerfil(perfilObj);
        }

        user.setNome(input.getNome());
        user.setAtivo(input.isAtivo());

        if (newPassword != null && !newPassword.trim().isEmpty()) {
            user.setSenhaHash(PasswordHasher.hashPassword(newPassword));
        }

        user.setUpdatedAt(LocalDateTime.now());

        Usuario saved = usuarioRepository.save(user);
        if (saved.getPerfil() == null) {
            saved.setPerfil(perfilRepository.findById(saved.getPerfilId()).orElse(null));
        }
        return saved;
    }

    @Transactional
    public void delete(String id) {
        Usuario user = getById(id);

        if (user.getPerfil() != null && "Super Admin".equals(user.getPerfil().getNome())) {
            long count = usuarioRepository.countByPerfilNomeAndAtivo("Super Admin", true);
            if (count <= 1) {
                throw new AppBadRequestException("não é possível excluir o último usuário super admin");
            }
        }

        usuarioRepository.delete(user);
    }

    public Usuario login(String email, String password) {
        Usuario user = usuarioRepository.findByEmail(email)
                .orElseThrow(() -> new AppUnauthorizedException("email ou senha inválidos"));

        if (!user.isAtivo()) {
            throw new AppUnauthorizedException("email ou senha inválidos");
        }

        String hashedInput = PasswordHasher.hashPassword(password);
        if (!user.getSenhaHash().equals(hashedInput)) {
            throw new AppUnauthorizedException("email ou senha inválidos");
        }

        return user;
    }
}

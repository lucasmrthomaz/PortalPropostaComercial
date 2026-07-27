package br.com.portalproposta.backend.controller;

import br.com.portalproposta.backend.model.CreateUsuarioRequest;
import br.com.portalproposta.backend.model.UpdateUsuarioRequest;
import br.com.portalproposta.backend.model.Usuario;
import br.com.portalproposta.backend.model.UsuarioResponse;
import br.com.portalproposta.backend.service.UsuarioService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.support.ServletUriComponentsBuilder;

import java.net.URI;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/users")
public class UsersController {

    private final UsuarioService usuarioService;

    @Autowired
    public UsersController(UsuarioService usuarioService) {
        this.usuarioService = usuarioService;
    }

    @GetMapping
    public ResponseEntity<List<UsuarioResponse>> list() {
        List<Usuario> users = usuarioService.list();
        List<UsuarioResponse> response = users.stream().map(Usuario::toResponse).toList();
        return ResponseEntity.ok(response);
    }

    @PostMapping
    public ResponseEntity<UsuarioResponse> create(@RequestBody CreateUsuarioRequest req) {
        Usuario user = Usuario.builder()
                .nome(req.getNome())
                .email(req.getEmail())
                .perfilId(req.getPerfilId())
                .ativo(req.isAtivo())
                .build();

        Usuario created = usuarioService.create(user, req.getSenha());
        URI uri = ServletUriComponentsBuilder.fromCurrentRequest()
                .path("/{id}")
                .buildAndExpand(created.getId())
                .toUri();
        return ResponseEntity.created(uri).body(created.toResponse());
    }

    @GetMapping("/{id}")
    public ResponseEntity<UsuarioResponse> get(@PathVariable String id) {
        Usuario user = usuarioService.getById(id);
        return ResponseEntity.ok(user.toResponse());
    }

    @PutMapping("/{id}")
    public ResponseEntity<UsuarioResponse> update(@PathVariable String id, @RequestBody UpdateUsuarioRequest req) {
        Usuario input = Usuario.builder()
                .nome(req.getNome())
                .email(req.getEmail())
                .perfilId(req.getPerfilId())
                .ativo(req.isAtivo())
                .build();

        Usuario updated = usuarioService.update(id, input, req.getSenha());
        return ResponseEntity.ok(updated.toResponse());
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Map<String, String>> delete(@PathVariable String id) {
        usuarioService.delete(id);
        Map<String, String> response = new HashMap<>();
        response.put("message", "Usuário excluído com sucesso");
        return ResponseEntity.ok(response);
    }
}

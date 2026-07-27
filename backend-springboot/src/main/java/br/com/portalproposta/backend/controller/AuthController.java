package br.com.portalproposta.backend.controller;

import br.com.portalproposta.backend.model.LoginRequest;
import br.com.portalproposta.backend.model.Usuario;
import br.com.portalproposta.backend.model.UsuarioResponse;
import br.com.portalproposta.backend.service.UsuarioService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/auth")
public class AuthController {

    private final UsuarioService usuarioService;

    @Autowired
    public AuthController(UsuarioService usuarioService) {
        this.usuarioService = usuarioService;
    }

    @PostMapping("/login")
    public ResponseEntity<UsuarioResponse> login(@RequestBody LoginRequest req) {
        Usuario user = usuarioService.login(req.getEmail(), req.getSenha());
        return ResponseEntity.ok(user.toResponse());
    }
}

package br.com.portalproposta.backend.controller;

import br.com.portalproposta.backend.model.Perfil;
import br.com.portalproposta.backend.service.PerfilService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.support.ServletUriComponentsBuilder;

import java.net.URI;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/profiles")
public class ProfilesController {

    private final PerfilService perfilService;

    @Autowired
    public ProfilesController(PerfilService perfilService) {
        this.perfilService = perfilService;
    }

    @GetMapping
    public ResponseEntity<List<Perfil>> list() {
        return ResponseEntity.ok(perfilService.list());
    }

    @PostMapping
    public ResponseEntity<Perfil> create(@RequestBody Perfil perfil) {
        Perfil created = perfilService.create(perfil);
        URI uri = ServletUriComponentsBuilder.fromCurrentRequest()
                .path("/{id}")
                .buildAndExpand(created.getId())
                .toUri();
        return ResponseEntity.created(uri).body(created);
    }

    @GetMapping("/{id}")
    public ResponseEntity<Perfil> get(@PathVariable String id) {
        return ResponseEntity.ok(perfilService.getById(id));
    }

    @PutMapping("/{id}")
    public ResponseEntity<Perfil> update(@PathVariable String id, @RequestBody Perfil perfil) {
        Perfil updated = perfilService.update(id, perfil);
        return ResponseEntity.ok(updated);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Map<String, String>> delete(@PathVariable String id) {
        perfilService.delete(id);
        Map<String, String> response = new HashMap<>();
        response.put("message", "Perfil excluído com sucesso");
        return ResponseEntity.ok(response);
    }
}

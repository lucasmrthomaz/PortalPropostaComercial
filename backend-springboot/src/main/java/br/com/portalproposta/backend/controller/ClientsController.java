package br.com.portalproposta.backend.controller;

import br.com.portalproposta.backend.model.Cliente;
import br.com.portalproposta.backend.model.Proposta;
import br.com.portalproposta.backend.service.ClienteService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.support.ServletUriComponentsBuilder;

import java.net.URI;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/clients")
public class ClientsController {

    private final ClienteService clienteService;

    @Autowired
    public ClientsController(ClienteService clienteService) {
        this.clienteService = clienteService;
    }

    @GetMapping
    public ResponseEntity<List<Cliente>> list() {
        return ResponseEntity.ok(clienteService.list());
    }

    @PostMapping
    public ResponseEntity<Cliente> create(@RequestBody Cliente client) {
        Cliente created = clienteService.create(client);
        URI uri = ServletUriComponentsBuilder.fromCurrentRequest()
                .path("/{id}")
                .buildAndExpand(created.getId())
                .toUri();
        return ResponseEntity.created(uri).body(created);
    }

    @GetMapping("/{id}")
    public ResponseEntity<Cliente> get(@PathVariable String id) {
        return ResponseEntity.ok(clienteService.getById(id));
    }

    @PutMapping("/{id}")
    public ResponseEntity<Cliente> update(@PathVariable String id, @RequestBody Cliente client) {
        Cliente updated = clienteService.update(id, client);
        return ResponseEntity.ok(updated);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Map<String, String>> delete(@PathVariable String id) {
        clienteService.delete(id);
        Map<String, String> response = new HashMap<>();
        response.put("message", "Cliente deletado com sucesso");
        return ResponseEntity.ok(response);
    }

    @GetMapping("/{id}/proposals")
    public ResponseEntity<List<Proposta>> listProposals(@PathVariable String id) {
        Cliente client = clienteService.getById(id);
        return ResponseEntity.ok(client.getPropostas());
    }
}

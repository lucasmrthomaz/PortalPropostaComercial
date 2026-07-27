package br.com.portalproposta.backend.controller;

import br.com.portalproposta.backend.model.Proposta;
import br.com.portalproposta.backend.service.PropostaService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.support.ServletUriComponentsBuilder;

import java.net.URI;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/proposals")
public class ProposalsController {

    private final PropostaService propostaService;

    @Autowired
    public ProposalsController(PropostaService propostaService) {
        this.propostaService = propostaService;
    }

    @GetMapping
    public ResponseEntity<List<Proposta>> list() {
        return ResponseEntity.ok(propostaService.list());
    }

    @PostMapping
    public ResponseEntity<Proposta> create(@RequestBody Proposta proposal) {
        Proposta created = propostaService.create(proposal);
        URI uri = ServletUriComponentsBuilder.fromCurrentRequest()
                .path("/{id}")
                .buildAndExpand(created.getId())
                .toUri();
        return ResponseEntity.created(uri).body(created);
    }

    @GetMapping("/{id}")
    public ResponseEntity<Proposta> get(@PathVariable String id) {
        return ResponseEntity.ok(propostaService.getById(id));
    }

    @PutMapping("/{id}")
    public ResponseEntity<Proposta> update(@PathVariable String id, @RequestBody Proposta proposal) {
        Proposta updated = propostaService.update(id, proposal);
        return ResponseEntity.ok(updated);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Map<String, String>> delete(@PathVariable String id) {
        propostaService.delete(id);
        Map<String, String> response = new HashMap<>();
        response.put("message", "Proposta deletada com sucesso");
        return ResponseEntity.ok(response);
    }
}

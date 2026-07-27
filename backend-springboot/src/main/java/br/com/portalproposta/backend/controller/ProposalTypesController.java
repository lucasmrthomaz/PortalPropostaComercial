package br.com.portalproposta.backend.controller;

import br.com.portalproposta.backend.model.TipoProposta;
import br.com.portalproposta.backend.service.TipoPropostaService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.support.ServletUriComponentsBuilder;

import java.net.URI;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/proposal-types")
public class ProposalTypesController {

    private final TipoPropostaService proposalTypeService;

    @Autowired
    public ProposalTypesController(TipoPropostaService proposalTypeService) {
        this.proposalTypeService = proposalTypeService;
    }

    @GetMapping
    public ResponseEntity<List<TipoProposta>> list() {
        return ResponseEntity.ok(proposalTypeService.list());
    }

    @PostMapping
    public ResponseEntity<TipoProposta> create(@RequestBody TipoProposta tipo) {
        TipoProposta created = proposalTypeService.create(tipo);
        URI uri = ServletUriComponentsBuilder.fromCurrentRequest()
                .path("/{id}")
                .buildAndExpand(created.getId())
                .toUri();
        return ResponseEntity.created(uri).body(created);
    }

    @GetMapping("/{id}")
    public ResponseEntity<TipoProposta> get(@PathVariable String id) {
        return ResponseEntity.ok(proposalTypeService.getById(id));
    }

    @PutMapping("/{id}")
    public ResponseEntity<TipoProposta> update(@PathVariable String id, @RequestBody TipoProposta tipo) {
        TipoProposta updated = proposalTypeService.update(id, tipo);
        return ResponseEntity.ok(updated);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Map<String, String>> delete(@PathVariable String id) {
        proposalTypeService.delete(id);
        Map<String, String> response = new HashMap<>();
        response.put("message", "Tipo de proposta excluído com sucesso");
        return ResponseEntity.ok(response);
    }
}

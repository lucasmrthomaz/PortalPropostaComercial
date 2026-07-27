package br.com.portalproposta.backend.controller;

import br.com.portalproposta.backend.model.Empresa;
import br.com.portalproposta.backend.service.EmpresaService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.support.ServletUriComponentsBuilder;

import java.net.URI;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/companies")
public class CompaniesController {

    private final EmpresaService empresaService;

    @Autowired
    public CompaniesController(EmpresaService empresaService) {
        this.empresaService = empresaService;
    }

    @GetMapping
    public ResponseEntity<List<Empresa>> list() {
        return ResponseEntity.ok(empresaService.list());
    }

    @PostMapping
    public ResponseEntity<Empresa> create(@RequestBody Empresa company) {
        Empresa created = empresaService.create(company);
        URI uri = ServletUriComponentsBuilder.fromCurrentRequest()
                .path("/{id}")
                .buildAndExpand(created.getId())
                .toUri();
        return ResponseEntity.created(uri).body(created);
    }

    @GetMapping("/{id}")
    public ResponseEntity<Empresa> get(@PathVariable String id) {
        return ResponseEntity.ok(empresaService.getById(id));
    }

    @PutMapping("/{id}")
    public ResponseEntity<Empresa> update(@PathVariable String id, @RequestBody Empresa company) {
        Empresa updated = empresaService.update(id, company);
        return ResponseEntity.ok(updated);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Map<String, String>> delete(@PathVariable String id) {
        empresaService.delete(id);
        Map<String, String> response = new HashMap<>();
        response.put("message", "Empresa parceira deletada com sucesso");
        return ResponseEntity.ok(response);
    }
}

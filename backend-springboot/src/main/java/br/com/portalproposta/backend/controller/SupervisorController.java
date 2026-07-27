package br.com.portalproposta.backend.controller;

import br.com.portalproposta.backend.exception.AppBadRequestException;
import br.com.portalproposta.backend.model.PedidoAnalise;
import br.com.portalproposta.backend.model.VerifyPasswordRequest;
import br.com.portalproposta.backend.model.VerifyPasswordResponse;
import br.com.portalproposta.backend.service.ConfiguracaoService;
import br.com.portalproposta.backend.service.SupervisorService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.support.ServletUriComponentsBuilder;

import java.net.URI;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/supervisor")
public class SupervisorController {

    private final SupervisorService supervisorService;
    private final ConfiguracaoService configuracaoService;

    @Autowired
    public SupervisorController(SupervisorService supervisorService, ConfiguracaoService configuracaoService) {
        this.supervisorService = supervisorService;
        this.configuracaoService = configuracaoService;
    }

    @PostMapping("/verify-password")
    public ResponseEntity<VerifyPasswordResponse> verifyPassword(@RequestBody VerifyPasswordRequest req) {
        try {
            configuracaoService.verifySupervisorPassword(req.getPassword());
            return ResponseEntity.ok(new VerifyPasswordResponse(true));
        } catch (AppBadRequestException e) {
            return ResponseEntity.ok(new VerifyPasswordResponse(false));
        }
    }

    @GetMapping("/requests")
    public ResponseEntity<List<PedidoAnalise>> listRequests(@RequestParam(required = false) String status) {
        List<PedidoAnalise> requests;
        if ("Pendente".equals(status)) {
            requests = supervisorService.listPendentes();
        } else {
            requests = supervisorService.listAll();
        }
        return ResponseEntity.ok(requests);
    }

    @PostMapping("/requests")
    public ResponseEntity<PedidoAnalise> createRequest(@RequestBody PedidoAnalise request) {
        PedidoAnalise created = supervisorService.createRequest(request);
        URI uri = ServletUriComponentsBuilder.fromCurrentRequest()
                .path("/{id}")
                .buildAndExpand(created.getId())
                .toUri();
        return ResponseEntity.created(uri).body(created);
    }

    @PostMapping("/requests/{id}/approve")
    public ResponseEntity<Map<String, String>> approveRequest(@PathVariable String id) {
        supervisorService.approveRequest(id);
        Map<String, String> response = new HashMap<>();
        response.put("message", "Solicitação aprovada e executada com sucesso");
        return ResponseEntity.ok(response);
    }

    @PostMapping("/requests/{id}/reject")
    public ResponseEntity<Map<String, String>> rejectRequest(@PathVariable String id) {
        supervisorService.rejectRequest(id);
        Map<String, String> response = new HashMap<>();
        response.put("message", "Solicitação rejeitada com sucesso");
        return ResponseEntity.ok(response);
    }
}

package br.com.portalproposta.backend.controller;

import br.com.portalproposta.backend.model.SettingsResponse;
import br.com.portalproposta.backend.model.SettingsUpdateRequest;
import br.com.portalproposta.backend.service.ConfiguracaoService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/settings")
public class SettingsController {

    private final ConfiguracaoService configuracaoService;

    @Autowired
    public SettingsController(ConfiguracaoService configuracaoService) {
        this.configuracaoService = configuracaoService;
    }

    @GetMapping
    public ResponseEntity<SettingsResponse> get() {
        double rate = configuracaoService.getCommissionRate();
        return ResponseEntity.ok(SettingsResponse.builder().taxaCorretagem(rate).build());
    }

    @PutMapping
    public ResponseEntity<Map<String, String>> update(@RequestBody SettingsUpdateRequest req) {
        if (req.getTaxaCorretagem() != null) {
            configuracaoService.updateCommissionRate(req.getTaxaCorretagem());
        }

        if (req.getSenhaSupervisor() != null) {
            configuracaoService.updateSupervisorPassword(req.getSenhaSupervisor());
        }

        Map<String, String> response = new HashMap<>();
        response.put("message", "Configurações atualizadas com sucesso");
        return ResponseEntity.ok(response);
    }
}

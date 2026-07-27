package br.com.portalproposta.backend.service;

import br.com.portalproposta.backend.exception.AppBadRequestException;
import br.com.portalproposta.backend.model.Configuracao;
import br.com.portalproposta.backend.repository.ConfiguracaoRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Locale;

@Service
public class ConfiguracaoService {

    private final ConfiguracaoRepository configuracaoRepository;

    @Autowired
    public ConfiguracaoService(ConfiguracaoRepository configuracaoRepository) {
        this.configuracaoRepository = configuracaoRepository;
    }

    public double getCommissionRate() {
        return configuracaoRepository.findById("taxa_corretagem")
                .map(conf -> {
                    try {
                        return Double.parseDouble(conf.getValor());
                    } catch (NumberFormatException e) {
                        return 5.0;
                    }
                })
                .orElse(5.0);
    }

    @Transactional
    public void updateCommissionRate(double rate) {
        if (rate < 0 || rate > 100) {
            throw new AppBadRequestException("taxa de corretagem inválida (deve ser entre 0% e 100%)");
        }
        String val = String.format(Locale.US, "%.2f", rate);
        setSetting("taxa_corretagem", val);
    }

    public void verifySupervisorPassword(String inputPassword) {
        String supervisorPassword = configuracaoRepository.findById("senha_supervisor")
                .map(Configuracao::getValor)
                .orElse("admin123");

        if (!supervisorPassword.equals(inputPassword)) {
            throw new AppBadRequestException("senha do supervisor incorreta");
        }
    }

    @Transactional
    public void updateSupervisorPassword(String newPassword) {
        if (newPassword == null || newPassword.trim().length() < 4) {
            throw new AppBadRequestException("a senha do supervisor deve ter no mínimo 4 caracteres");
        }
        setSetting("senha_supervisor", newPassword.trim());
    }

    @Transactional
    public void setSetting(String chave, String valor) {
        Configuracao conf = configuracaoRepository.findById(chave)
                .orElseGet(() -> Configuracao.builder().chave(chave).build());
        conf.setValor(valor);
        configuracaoRepository.save(conf);
    }
}

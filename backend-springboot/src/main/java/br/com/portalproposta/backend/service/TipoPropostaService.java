package br.com.portalproposta.backend.service;

import br.com.portalproposta.backend.exception.AppBadRequestException;
import br.com.portalproposta.backend.exception.AppNotFoundException;
import br.com.portalproposta.backend.model.TipoProposta;
import br.com.portalproposta.backend.repository.PropostaRepository;
import br.com.portalproposta.backend.repository.TipoPropostaRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

@Service
public class TipoPropostaService {

    private final TipoPropostaRepository tipoPropostaRepository;
    private final PropostaRepository propostaRepository;

    @Autowired
    public TipoPropostaService(TipoPropostaRepository tipoPropostaRepository, PropostaRepository propostaRepository) {
        this.tipoPropostaRepository = tipoPropostaRepository;
        this.propostaRepository = propostaRepository;
    }

    public List<TipoProposta> list() {
        return tipoPropostaRepository.findAllByOrderByNomeAsc();
    }

    public TipoProposta getById(String id) {
        return tipoPropostaRepository.findById(id)
                .orElseThrow(() -> new AppNotFoundException("tipo de proposta não encontrado"));
    }

    @Transactional
    public TipoProposta create(TipoProposta tipo) {
        if (tipo.getNome() == null || tipo.getNome().trim().isEmpty()) {
            throw new AppBadRequestException("o nome do tipo de proposta é obrigatório");
        }

        if (tipo.getChave() == null || tipo.getChave().trim().isEmpty()) {
            throw new AppBadRequestException("a chave do tipo de proposta é obrigatória");
        }

        String cleanedChave = tipo.getChave().replaceAll("[^a-zA-Z0-9]", "");
        if (cleanedChave.isEmpty()) {
            throw new AppBadRequestException("a chave do tipo de proposta deve conter caracteres alfanuméricos");
        }
        tipo.setChave(cleanedChave);

        tipoPropostaRepository.findByChave(tipo.getChave()).ifPresent(existing -> {
            throw new AppBadRequestException("já existe um tipo de proposta com esta chave");
        });

        tipo.setId(UUID.randomUUID().toString());
        tipo.setCreatedAt(LocalDateTime.now());
        tipo.setUpdatedAt(LocalDateTime.now());

        return tipoPropostaRepository.save(tipo);
    }

    @Transactional
    public TipoProposta update(String id, TipoProposta input) {
        TipoProposta tipo = getById(id);

        if (input.getNome() == null || input.getNome().trim().isEmpty()) {
            throw new AppBadRequestException("o nome do tipo de proposta é obrigatório");
        }

        boolean isLegacy = tipo.getChave().equals("Imobiliaria")
                || tipo.getChave().equals("Auto")
                || tipo.getChave().equals("Comissionados");

        if (!isLegacy && input.getChave() != null && !input.getChave().trim().isEmpty()
                && !input.getChave().equals(tipo.getChave())) {
            String newChave = input.getChave().replaceAll("[^a-zA-Z0-9]", "");
            if (newChave.isEmpty()) {
                throw new AppBadRequestException("a chave do tipo de proposta deve conter caracteres alfanuméricos");
            }

            tipoPropostaRepository.findByChave(newChave).ifPresent(existing -> {
                if (!existing.getId().equals(tipo.getId())) {
                    throw new AppBadRequestException("já existe um tipo de proposta com esta chave");
                }
            });
            tipo.setChave(newChave);
        }

        tipo.setNome(input.getNome());
        tipo.setCampos(input.getCampos());
        tipo.setUpdatedAt(LocalDateTime.now());

        return tipoPropostaRepository.save(tipo);
    }

    @Transactional
    public void delete(String id) {
        TipoProposta tipo = getById(id);

        boolean isLegacy = tipo.getChave().equals("Imobiliaria")
                || tipo.getChave().equals("Auto")
                || tipo.getChave().equals("Comissionados");

        if (isLegacy) {
            throw new AppBadRequestException("não é permitido excluir tipos de proposta do sistema");
        }

        long count = propostaRepository.countByTipo(tipo.getChave());
        if (count > 0) {
            throw new AppBadRequestException(String.format(
                    "não é possível excluir este tipo de proposta pois existem %d proposta(s) associada(s) a ele",
                    count));
        }

        tipoPropostaRepository.delete(tipo);
    }
}

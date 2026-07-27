package br.com.portalproposta.backend.service;

import br.com.portalproposta.backend.exception.AppBadRequestException;
import br.com.portalproposta.backend.exception.AppNotFoundException;
import br.com.portalproposta.backend.model.Empresa;
import br.com.portalproposta.backend.model.Validation;
import br.com.portalproposta.backend.repository.EmpresaRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

@Service
public class EmpresaService {

    private final EmpresaRepository empresaRepository;

    @Autowired
    public EmpresaService(EmpresaRepository empresaRepository) {
        this.empresaRepository = empresaRepository;
    }

    public List<Empresa> list() {
        return empresaRepository.findAll();
    }

    public Empresa getById(String id) {
        return empresaRepository.findById(id)
                .orElseThrow(() -> new AppNotFoundException("empresa parceira não encontrada"));
    }

    @Transactional
    public Empresa create(Empresa company) {
        if (company.getNome() == null || company.getNome().trim().isEmpty()) {
            throw new AppBadRequestException("nome do empresa é obrigatório");
        }

        if (company.getEmail() == null || company.getEmail().trim().isEmpty() || !company.getEmail().contains("@")) {
            throw new AppBadRequestException("email da empresa é obrigatório ou inválido");
        }

        company.setCnpj(Validation.cleanCPFCNPJ(company.getCnpj()));
        if (!Validation.isValidCNPJ(company.getCnpj())) {
            throw new AppBadRequestException("CNPJ inválido");
        }

        empresaRepository.findByCnpj(company.getCnpj()).ifPresent(existing -> {
            throw new AppBadRequestException("empresa com este CNPJ já cadastrada");
        });

        company.setId(UUID.randomUUID().toString());
        company.setAtivo(true);
        company.setCreatedAt(LocalDateTime.now());
        company.setUpdatedAt(LocalDateTime.now());

        return empresaRepository.save(company);
    }

    @Transactional
    public Empresa update(String id, Empresa input) {
        Empresa company = getById(id);

        if (input.getNome() == null || input.getNome().trim().isEmpty()) {
            throw new AppBadRequestException("nome da empresa é obrigatório");
        }

        if (input.getEmail() == null || input.getEmail().trim().isEmpty() || !input.getEmail().contains("@")) {
            throw new AppBadRequestException("email da empresa é obrigatório ou inválido");
        }

        String cleanCNPJ = Validation.cleanCPFCNPJ(input.getCnpj());
        if (!cleanCNPJ.equals(company.getCnpj())) {
            if (!Validation.isValidCNPJ(cleanCNPJ)) {
                throw new AppBadRequestException("CNPJ inválido");
            }

            empresaRepository.findByCnpj(cleanCNPJ).ifPresent(existing -> {
                if (!existing.getId().equals(company.getId())) {
                    throw new AppBadRequestException("empresa com este CNPJ já cadastrada");
                }
            });
            company.setCnpj(cleanCNPJ);
        }

        company.setNome(input.getNome());
        company.setEmail(input.getEmail());
        company.setTelefone(input.getTelefone());
        company.setResponsavelNome(input.getResponsavelNome());
        company.setResponsavelEmail(input.getResponsavelEmail());
        company.setResponsavelTelefone(input.getResponsavelTelefone());
        company.setAtivo(input.isAtivo());
        company.setUpdatedAt(LocalDateTime.now());

        return empresaRepository.save(company);
    }

    @Transactional
    public void delete(String id) {
        Empresa company = getById(id);
        empresaRepository.delete(company);
    }
}

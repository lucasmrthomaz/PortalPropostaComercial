package br.com.portalproposta.backend.service;

import br.com.portalproposta.backend.exception.AppBadRequestException;
import br.com.portalproposta.backend.exception.AppNotFoundException;
import br.com.portalproposta.backend.model.Cliente;
import br.com.portalproposta.backend.model.Validation;
import br.com.portalproposta.backend.repository.ClienteRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

@Service
public class ClienteService {

    private final ClienteRepository clienteRepository;

    @Autowired
    public ClienteService(ClienteRepository clienteRepository) {
        this.clienteRepository = clienteRepository;
    }

    public List<Cliente> list() {
        return clienteRepository.findAll();
    }

    public Cliente getById(String id) {
        return clienteRepository.findById(id)
                .orElseThrow(() -> new AppNotFoundException("cliente não encontrado"));
    }

    @Transactional
    public Cliente create(Cliente client) {
        if (client.getNome() == null || client.getNome().trim().isEmpty()) {
            throw new AppBadRequestException("nome do cliente é obrigatório");
        }

        if (client.getEmail() == null || client.getEmail().trim().isEmpty() || !client.getEmail().contains("@")) {
            throw new AppBadRequestException("email do cliente é obrigatório ou inválido");
        }

        client.setCpfCnpj(Validation.cleanCPFCNPJ(client.getCpfCnpj()));
        if (!Validation.isValidCPFCNPJ(client.getCpfCnpj())) {
            throw new AppBadRequestException("CPF ou CNPJ inválido");
        }

        clienteRepository.findByCpfCnpj(client.getCpfCnpj()).ifPresent(existing -> {
            throw new AppBadRequestException("cliente com este CPF/CNPJ já cadastrado");
        });

        client.setId(UUID.randomUUID().toString());
        client.setCreatedAt(LocalDateTime.now());
        client.setUpdatedAt(LocalDateTime.now());

        return clienteRepository.save(client);
    }

    @Transactional
    public Cliente update(String id, Cliente input) {
        Cliente client = getById(id);

        if (input.getNome() == null || input.getNome().trim().isEmpty()) {
            throw new AppBadRequestException("nome do cliente é obrigatório");
        }

        if (input.getEmail() == null || input.getEmail().trim().isEmpty() || !input.getEmail().contains("@")) {
            throw new AppBadRequestException("email do cliente é obrigatório ou inválido");
        }

        String cleanCPF = Validation.cleanCPFCNPJ(input.getCpfCnpj());
        if (!cleanCPF.equals(client.getCpfCnpj())) {
            if (!Validation.isValidCPFCNPJ(cleanCPF)) {
                throw new AppBadRequestException("CPF ou CNPJ inválido");
            }

            clienteRepository.findByCpfCnpj(cleanCPF).ifPresent(existing -> {
                if (!existing.getId().equals(client.getId())) {
                    throw new AppBadRequestException("cliente com este CPF/CNPJ já cadastrado");
                }
            });
            client.setCpfCnpj(cleanCPF);
        }

        client.setNome(input.getNome());
        client.setEmail(input.getEmail());
        client.setTelefone(input.getTelefone());
        client.setEndereco(input.getEndereco());
        client.setUpdatedAt(LocalDateTime.now());

        return clienteRepository.save(client);
    }

    @Transactional
    public void delete(String id) {
        Cliente client = getById(id);
        clienteRepository.delete(client);
    }
}

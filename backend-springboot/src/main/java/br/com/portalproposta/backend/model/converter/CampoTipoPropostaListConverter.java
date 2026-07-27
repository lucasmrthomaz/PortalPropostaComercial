package br.com.portalproposta.backend.model.converter;

import br.com.portalproposta.backend.model.CampoTipoProposta;
import tools.jackson.core.JacksonException;
import tools.jackson.core.type.TypeReference;
import tools.jackson.databind.ObjectMapper;
import jakarta.persistence.AttributeConverter;
import jakarta.persistence.Converter;

import java.util.ArrayList;
import java.util.List;

@Converter
public class CampoTipoPropostaListConverter implements AttributeConverter<List<CampoTipoProposta>, String> {

    private static final ObjectMapper objectMapper = new ObjectMapper();

    @Override
    public String convertToDatabaseColumn(List<CampoTipoProposta> attribute) {
        if (attribute == null) {
            return "[]";
        }
        try {
            return objectMapper.writeValueAsString(attribute);
        } catch (JacksonException e) {
            return "[]";
        }
    }

    @Override
    public List<CampoTipoProposta> convertToEntityAttribute(String dbData) {
        if (dbData == null || dbData.trim().isEmpty()) {
            return new ArrayList<>();
        }
        try {
            return objectMapper.readValue(dbData, new TypeReference<List<CampoTipoProposta>>() {
            });
        } catch (JacksonException e) {
            return new ArrayList<>();
        }
    }
}

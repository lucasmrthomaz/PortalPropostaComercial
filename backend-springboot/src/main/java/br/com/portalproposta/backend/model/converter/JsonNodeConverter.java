package br.com.portalproposta.backend.model.converter;

import tools.jackson.core.JacksonException;
import tools.jackson.databind.JsonNode;
import tools.jackson.databind.ObjectMapper;
import jakarta.persistence.AttributeConverter;
import jakarta.persistence.Converter;

@Converter(autoApply = true)
public class JsonNodeConverter implements AttributeConverter<JsonNode, String> {

    private static final ObjectMapper objectMapper = new ObjectMapper();

    @Override
    public String convertToDatabaseColumn(JsonNode jsonNode) {
        if (jsonNode == null) {
            return "{}";
        }
        try {
            return objectMapper.writeValueAsString(jsonNode);
        } catch (JacksonException e) {
            return "{}";
        }
    }

    @Override
    public JsonNode convertToEntityAttribute(String s) {
        if (s == null || s.trim().isEmpty()) {
            try {
                return objectMapper.readTree("{}");
            } catch (JacksonException e) {
                return null;
            }
        }
        try {
            return objectMapper.readTree(s);
        } catch (JacksonException e) {
            try {
                return objectMapper.readTree("{}");
            } catch (JacksonException ex) {
                return null;
            }
        }
    }
}

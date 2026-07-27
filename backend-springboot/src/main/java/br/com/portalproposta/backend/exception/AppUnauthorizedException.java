package br.com.portalproposta.backend.exception;

public class AppUnauthorizedException extends RuntimeException {
    public AppUnauthorizedException(String message) {
        super(message);
    }
}

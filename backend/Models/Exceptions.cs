namespace PortalProposta.Models;

public class AppNotFoundException(string message) : Exception(message);

public class AppBadRequestException(string message) : Exception(message);

public class AppUnauthorizedException(string message) : Exception(message);

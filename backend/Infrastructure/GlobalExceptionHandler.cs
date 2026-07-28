using Microsoft.AspNetCore.Diagnostics;
using PortalProposta.Models;

namespace PortalProposta.Infrastructure;

public class GlobalExceptionHandler : IExceptionHandler
{
    public async ValueTask<bool> TryHandleAsync(
        HttpContext httpContext,
        Exception exception,
        CancellationToken cancellationToken)
    {
        var (statusCode, message) = exception switch
        {
            AppNotFoundException notFoundEx => (StatusCodes.Status404NotFound, notFoundEx.Message),
            AppBadRequestException badRequestEx => (StatusCodes.Status400BadRequest, badRequestEx.Message),
            AppUnauthorizedException unauthorizedEx => (StatusCodes.Status401Unauthorized, unauthorizedEx.Message),
            _ => (StatusCodes.Status500InternalServerError, "Erro interno no servidor: " + exception.Message)
        };

        httpContext.Response.StatusCode = statusCode;
        httpContext.Response.ContentType = "application/json";
        await httpContext.Response.WriteAsJsonAsync(new { error = message }, cancellationToken);

        return true;
    }
}

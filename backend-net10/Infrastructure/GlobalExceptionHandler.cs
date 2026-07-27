using Microsoft.AspNetCore.Diagnostics;
using Microsoft.AspNetCore.Http;
using backend_net10.Models;
using System.Threading;
using System.Threading.Tasks;

namespace backend_net10.Infrastructure;

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

        var response = new { error = message };
        await httpContext.Response.WriteAsJsonAsync(response, cancellationToken);

        return true;
    }
}

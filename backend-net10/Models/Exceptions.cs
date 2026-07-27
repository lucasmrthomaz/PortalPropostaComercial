using System;

namespace backend_net10.Models;

public class AppNotFoundException : Exception
{
    public AppNotFoundException(string message) : base(message)
    {
    }
}

public class AppBadRequestException : Exception
{
    public AppBadRequestException(string message) : base(message)
    {
    }
}

public class AppUnauthorizedException : Exception
{
    public AppUnauthorizedException(string message) : base(message)
    {
    }
}

using System.Security.Cryptography;
using System.Text;

namespace backend_net10.Infrastructure;

public static class PasswordHasher
{
    public static string HashPassword(string password)
    {
        byte[] bytes = SHA256.HashData(Encoding.UTF8.GetBytes(password));
        return Convert.ToHexString(bytes).ToLowerInvariant();
    }
}

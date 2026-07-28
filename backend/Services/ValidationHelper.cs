using PortalProposta.Models;

namespace PortalProposta.Services;

internal static class Validate
{
    public static void Cliente(Cliente c)
    {
        if (string.IsNullOrWhiteSpace(c.Nome))
            throw new AppBadRequestException("nome do cliente é obrigatório");
        if (string.IsNullOrWhiteSpace(c.Email) || !c.Email.Contains('@'))
            throw new AppBadRequestException("email do cliente é obrigatório ou inválido");
    }

    public static void Empresa(Empresa e)
    {
        if (string.IsNullOrWhiteSpace(e.Nome))
            throw new AppBadRequestException("nome da empresa é obrigatório");
        if (string.IsNullOrWhiteSpace(e.Email) || !e.Email.Contains('@'))
            throw new AppBadRequestException("email da empresa é obrigatório ou inválido");
    }

    public static void Usuario(Usuario u)
    {
        if (string.IsNullOrWhiteSpace(u.Nome))
            throw new AppBadRequestException("nome do usuário é obrigatório");
        if (string.IsNullOrWhiteSpace(u.Email) || !u.Email.Contains('@'))
            throw new AppBadRequestException("email do usuário é obrigatório ou inválido");
    }

    public static void Perfil(Perfil p)
    {
        if (string.IsNullOrWhiteSpace(p.Nome))
            throw new AppBadRequestException("nome do perfil é obrigatório");
    }

    public static void TipoPropostaNome(TipoProposta t)
    {
        if (string.IsNullOrWhiteSpace(t.Nome))
            throw new AppBadRequestException("o nome do tipo de proposta é obrigatório");
        if (string.IsNullOrWhiteSpace(t.Chave))
            throw new AppBadRequestException("a chave do tipo de proposta é obrigatória");
    }
}

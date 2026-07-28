using System.Text.RegularExpressions;

namespace PortalProposta.Models;

public static class Validation
{
    public static string CleanCPFCNPJ(string? s) =>
        s == null ? string.Empty : Regex.Replace(s, @"[^0-9]", "");

    public static bool IsValidCPFCNPJ(string s)
    {
        s = CleanCPFCNPJ(s);
        return s.Length switch
        {
            11 => IsValidCPF(s),
            14 => IsValidCNPJ(s),
            _ => false
        };
    }

    public static bool IsValidCPF(string cpf)
    {
        if (cpf.Length != 11) return false;
        if (cpf.Distinct().Count() == 1) return false;

        var sum = 0;
        for (var i = 0; i < 9; i++) sum += (cpf[i] - '0') * (10 - i);
        var d1 = sum % 11 >= 2 ? 11 - sum % 11 : 0;
        if ((cpf[9] - '0') != d1) return false;

        sum = 0;
        for (var i = 0; i < 10; i++) sum += (cpf[i] - '0') * (11 - i);
        var d2 = sum % 11 >= 2 ? 11 - sum % 11 : 0;
        return (cpf[10] - '0') == d2;
    }

    public static bool IsValidCNPJ(string cnpj)
    {
        if (cnpj.Length != 14) return false;
        if (cnpj.Distinct().Count() == 1) return false;

        var w1 = new[] { 5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2 };
        var w2 = new[] { 6, 5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2 };

        var sum = 0;
        for (var i = 0; i < 12; i++) sum += (cnpj[i] - '0') * w1[i];
        var d1 = sum % 11 >= 2 ? 11 - sum % 11 : 0;
        if ((cnpj[12] - '0') != d1) return false;

        sum = 0;
        for (var i = 0; i < 13; i++) sum += (cnpj[i] - '0') * w2[i];
        var d2 = sum % 11 >= 2 ? 11 - sum % 11 : 0;
        return (cnpj[13] - '0') == d2;
    }
}

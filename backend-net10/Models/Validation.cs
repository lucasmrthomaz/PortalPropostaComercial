using System.Text.RegularExpressions;

namespace backend_net10.Models;

public static class Validation
{
    public static string CleanCPFCNPJ(string? s)
    {
        if (s == null) return string.Empty;
        return Regex.Replace(s, @"[^0-9]", "");
    }

    public static bool IsValidCPFCNPJ(string s)
    {
        s = CleanCPFCNPJ(s);
        if (s.Length == 11)
        {
            return IsValidCPF(s);
        }
        else if (s.Length == 14)
        {
            return IsValidCNPJ(s);
        }
        return false;
    }

    public static bool IsValidCPF(string cpf)
    {
        if (cpf.Length != 11) return false;

        bool allSame = true;
        for (int i = 1; i < 11; i++)
        {
            if (cpf[i] != cpf[0])
            {
                allSame = false;
                break;
            }
        }
        if (allSame) return false;

        int sum = 0;
        for (int i = 0; i < 9; i++)
        {
            sum += (cpf[i] - '0') * (10 - i);
        }
        int rem = sum % 11;
        int d1 = rem >= 2 ? 11 - rem : 0;
        if ((cpf[9] - '0') != d1) return false;

        sum = 0;
        for (int i = 0; i < 10; i++)
        {
            sum += (cpf[i] - '0') * (11 - i);
        }
        rem = sum % 11;
        int d2 = rem >= 2 ? 11 - rem : 0;
        return (cpf[10] - '0') == d2;
    }

    public static bool IsValidCNPJ(string cnpj)
    {
        if (cnpj.Length != 14) return false;

        bool allSame = true;
        for (int i = 1; i < 14; i++)
        {
            if (cnpj[i] != cnpj[0])
            {
                allSame = false;
                break;
            }
        }
        if (allSame) return false;

        int[] w1 = { 5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2 };
        int[] w2 = { 6, 5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2 };

        int sum = 0;
        for (int i = 0; i < 12; i++)
        {
            sum += (cnpj[i] - '0') * w1[i];
        }
        int rem = sum % 11;
        int d1 = rem >= 2 ? 11 - rem : 0;
        if ((cnpj[12] - '0') != d1) return false;

        sum = 0;
        for (int i = 0; i < 13; i++)
        {
            sum += (cnpj[i] - '0') * w2[i];
        }
        rem = sum % 11;
        int d2 = rem >= 2 ? 11 - rem : 0;
        return (cnpj[13] - '0') == d2;
    }
}

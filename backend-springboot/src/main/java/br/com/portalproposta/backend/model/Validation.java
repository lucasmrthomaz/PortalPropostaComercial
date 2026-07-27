package br.com.portalproposta.backend.model;

public class Validation {
    public static String cleanCPFCNPJ(String s) {
        if (s == null)
            return "";
        return s.replaceAll("[^0-9]", "");
    }

    public static boolean isValidCPFCNPJ(String s) {
        s = cleanCPFCNPJ(s);
        if (s.length() == 11) {
            return isValidCPF(s);
        } else if (s.length() == 14) {
            return isValidCNPJ(s);
        }
        return false;
    }

    public static boolean isValidCPF(String cpf) {
        if (cpf == null || cpf.length() != 11)
            return false;

        boolean allSame = true;
        for (int i = 1; i < 11; i++) {
            if (cpf.charAt(i) != cpf.charAt(0)) {
                allSame = false;
                break;
            }
        }
        if (allSame)
            return false;

        int sum = 0;
        for (int i = 0; i < 9; i++) {
            sum += (cpf.charAt(i) - '0') * (10 - i);
        }
        int rem = sum % 11;
        int d1 = rem >= 2 ? 11 - rem : 0;
        if ((cpf.charAt(9) - '0') != d1)
            return false;

        sum = 0;
        for (int i = 0; i < 10; i++) {
            sum += (cpf.charAt(i) - '0') * (11 - i);
        }
        rem = sum % 11;
        int d2 = rem >= 2 ? 11 - rem : 0;
        return (cpf.charAt(10) - '0') == d2;
    }

    public static boolean isValidCNPJ(String cnpj) {
        if (cnpj == null || cnpj.length() != 14)
            return false;

        boolean allSame = true;
        for (int i = 1; i < 14; i++) {
            if (cnpj.charAt(i) != cnpj.charAt(0)) {
                allSame = false;
                break;
            }
        }
        if (allSame)
            return false;

        int[] w1 = { 5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2 };
        int[] w2 = { 6, 5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2 };

        int sum = 0;
        for (int i = 0; i < 12; i++) {
            sum += (cnpj.charAt(i) - '0') * w1[i];
        }
        int rem = sum % 11;
        int d1 = rem >= 2 ? 11 - rem : 0;
        if ((cnpj.charAt(12) - '0') != d1)
            return false;

        sum = 0;
        for (int i = 0; i < 13; i++) {
            sum += (cnpj.charAt(i) - '0') * w2[i];
        }
        rem = sum % 11;
        int d2 = rem >= 2 ? 11 - rem : 0;
        return (cnpj.charAt(13) - '0') == d2;
    }
}

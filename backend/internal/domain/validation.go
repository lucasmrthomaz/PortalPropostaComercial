package domain

import (
	"regexp"
)

func CleanCPFCNPJ(s string) string {
	reg := regexp.MustCompile(`[^0-9]`)
	return reg.ReplaceAllString(s, "")
}

func IsValidCPFCNPJ(s string) bool {
	s = CleanCPFCNPJ(s)
	if len(s) == 11 {
		return IsValidCPF(s)
	} else if len(s) == 14 {
		return IsValidCNPJ(s)
	}
	return false
}

func IsValidCPF(cpf string) bool {
	if len(cpf) != 11 {
		return false
	}

	allSame := true
	for i := 1; i < 11; i++ {
		if cpf[i] != cpf[0] {
			allSame = false
			break
		}
	}
	if allSame {
		return false
	}

	sum := 0
	for i := 0; i < 9; i++ {
		sum += int(cpf[i]-'0') * (10 - i)
	}
	rem := sum % 11
	d1 := 0
	if rem >= 2 {
		d1 = 11 - rem
	}
	if int(cpf[9]-'0') != d1 {
		return false
	}

	sum = 0
	for i := 0; i < 10; i++ {
		sum += int(cpf[i]-'0') * (11 - i)
	}
	rem = sum % 11
	d2 := 0
	if rem >= 2 {
		d2 = 11 - rem
	}
	return int(cpf[10]-'0') == d2
}

func IsValidCNPJ(cnpj string) bool {
	if len(cnpj) != 14 {
		return false
	}

	allSame := true
	for i := 1; i < 14; i++ {
		if cnpj[i] != cnpj[0] {
			allSame = false
			break
		}
	}
	if allSame {
		return false
	}

	w1 := []int{5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2}
	w2 := []int{6, 5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2}

	sum := 0
	for i := 0; i < 12; i++ {
		sum += int(cnpj[i]-'0') * w1[i]
	}
	rem := sum % 11
	d1 := 0
	if rem >= 2 {
		d1 = 11 - rem
	}
	if int(cnpj[12]-'0') != d1 {
		return false
	}

	sum = 0
	for i := 0; i < 13; i++ {
		sum += int(cnpj[i]-'0') * w2[i]
	}
	rem = sum % 11
	d2 := 0
	if rem >= 2 {
		d2 = 11 - rem
	}
	return int(cnpj[13]-'0') == d2
}

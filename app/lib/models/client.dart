class Cliente {
  final String? id;
  final String nome;
  final String cpfCnpj;
  final String email;
  final String? telefone;
  final String? endereco;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Cliente({
    this.id,
    required this.nome,
    required this.cpfCnpj,
    required this.email,
    this.telefone,
    this.endereco,
    this.createdAt,
    this.updatedAt,
  });

  factory Cliente.fromJson(Map<String, dynamic> json) {
    return Cliente(
      id: json['id'],
      nome: json['nome'] ?? '',
      cpfCnpj: json['cpf_cnpj'] ?? '',
      email: json['email'] ?? '',
      telefone: json['telefone'],
      endereco: json['endereco'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'nome': nome,
      'cpf_cnpj': cpfCnpj,
      'email': email,
      if (telefone != null) 'telefone': telefone,
      if (endereco != null) 'endereco': endereco,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }

  // Basic validation helpers
  static String cleanCPFCNPJ(String s) {
    return s.replaceAll(RegExp(r'[^0-9]'), '');
  }

  static bool isValidCPFCNPJ(String s) {
    final cleaned = cleanCPFCNPJ(s);
    if (cleaned.length == 11) {
      return _isValidCPF(cleaned);
    } else if (cleaned.length == 14) {
      return _isValidCNPJ(cleaned);
    }
    return false;
  }

  static bool _isValidCPF(String cpf) {
    if (cpf.length != 11) return false;
    if (RegExp(r'^(\d)\1{10}$').hasMatch(cpf)) return false;

    int sum = 0;
    for (int i = 0; i < 9; i++) {
      sum += int.parse(cpf[i]) * (10 - i);
    }
    int rem = sum % 11;
    int d1 = rem < 2 ? 0 : 11 - rem;
    if (int.parse(cpf[9]) != d1) return false;

    sum = 0;
    for (int i = 0; i < 10; i++) {
      sum += int.parse(cpf[i]) * (11 - i);
    }
    rem = sum % 11;
    int d2 = rem < 2 ? 0 : 11 - rem;
    return int.parse(cpf[10]) == d2;
  }

  static bool _isValidCNPJ(String cnpj) {
    if (cnpj.length != 14) return false;
    if (RegExp(r'^(\d)\1{13}$').hasMatch(cnpj)) return false;

    final w1 = [5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2];
    final w2 = [6, 5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2];

    int sum = 0;
    for (int i = 0; i < 12; i++) {
      sum += int.parse(cnpj[i]) * w1[i];
    }
    int rem = sum % 11;
    int d1 = rem < 2 ? 0 : 11 - rem;
    if (int.parse(cnpj[12]) != d1) return false;

    sum = 0;
    for (int i = 0; i < 13; i++) {
      sum += int.parse(cnpj[i]) * w2[i];
    }
    rem = sum % 11;
    int d2 = rem < 2 ? 0 : 11 - rem;
    return int.parse(cnpj[13]) == d2;
  }
}

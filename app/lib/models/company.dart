class Empresa {
  final String? id;
  final String nome;
  final String cnpj;
  final String email;
  final String? telefone;
  final String? responsavelNome;
  final String? responsavelEmail;
  final String? responsavelTelefone;
  final bool ativo;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Empresa({
    this.id,
    required this.nome,
    required this.cnpj,
    required this.email,
    this.telefone,
    this.responsavelNome,
    this.responsavelEmail,
    this.responsavelTelefone,
    required this.ativo,
    this.createdAt,
    this.updatedAt,
  });

  factory Empresa.fromJson(Map<String, dynamic> json) {
    return Empresa(
      id: json['id'],
      nome: json['nome'] ?? '',
      cnpj: json['cnpj'] ?? '',
      email: json['email'] ?? '',
      telefone: json['telefone'],
      responsavelNome: json['responsavel_nome'],
      responsavelEmail: json['responsavel_email'],
      responsavelTelefone: json['responsavel_telefone'],
      ativo: json['ativo'] ?? true,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'nome': nome,
      'cnpj': cnpj,
      'email': email,
      if (telefone != null) 'telefone': telefone,
      if (responsavelNome != null) 'responsavel_nome': responsavelNome,
      if (responsavelEmail != null) 'responsavel_email': responsavelEmail,
      if (responsavelTelefone != null) 'responsavel_telefone': responsavelTelefone,
      'ativo': ativo,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }
}

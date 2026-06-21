import 'dart:convert';

class Perfil {
  final String id;
  final String nome;
  final String descricao;
  final List<String> permissoes;
  final bool isSistema;

  Perfil({
    required this.id,
    required this.nome,
    required this.descricao,
    required this.permissoes,
    required this.isSistema,
  });

  factory Perfil.fromJson(Map<String, dynamic> json) {
    List<String> perms = [];
    var rawPerms = json['permissoes'];
    if (rawPerms != null) {
      if (rawPerms is List) {
        perms = List<String>.from(rawPerms);
      } else if (rawPerms is String) {
        try {
          var decoded = jsonDecode(rawPerms);
          if (decoded is List) {
            perms = List<String>.from(decoded);
          }
        } catch (_) {}
      }
    }

    return Perfil(
      id: json['id'] ?? '',
      nome: json['nome'] ?? '',
      descricao: json['descricao'] ?? '',
      permissoes: perms,
      isSistema: json['is_sistema'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'descricao': descricao,
      'permissoes': permissoes,
      'is_sistema': isSistema,
    };
  }
}

class Usuario {
  final String id;
  final String nome;
  final String email;
  final String perfilId;
  final Perfil? perfil;
  final bool ativo;

  Usuario({
    required this.id,
    required this.nome,
    required this.email,
    required this.perfilId,
    this.perfil,
    required this.ativo,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'] ?? '',
      nome: json['nome'] ?? '',
      email: json['email'] ?? '',
      perfilId: json['perfil_id'] ?? '',
      perfil: json['perfil'] != null ? Perfil.fromJson(json['perfil']) : null,
      ativo: json['ativo'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'email': email,
      'perfil_id': perfilId,
      if (perfil != null) 'perfil': perfil!.toJson(),
      'ativo': ativo,
    };
  }
}

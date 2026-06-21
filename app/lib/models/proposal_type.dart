import 'dart:convert';

class CampoTipoProposta {
  final String nome;
  final String chave;
  final String tipo; // "text", "number", "boolean"
  final bool obrigatorio;

  CampoTipoProposta({
    required this.nome,
    required this.chave,
    required this.tipo,
    required this.obrigatorio,
  });

  factory CampoTipoProposta.fromJson(Map<String, dynamic> json) {
    return CampoTipoProposta(
      nome: json['nome'] ?? '',
      chave: json['chave'] ?? '',
      tipo: json['tipo'] ?? 'text',
      obrigatorio: json['obrigatorio'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nome': nome,
      'chave': chave,
      'tipo': tipo,
      'obrigatorio': obrigatorio,
    };
  }
}

class TipoProposta {
  final String? id;
  final String nome;
  final String chave;
  final List<CampoTipoProposta> campos;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  TipoProposta({
    this.id,
    required this.nome,
    required this.chave,
    required this.campos,
    this.createdAt,
    this.updatedAt,
  });

  factory TipoProposta.fromJson(Map<String, dynamic> json) {
    List<CampoTipoProposta> camposList = [];
    var rawCampos = json['campos'];
    if (rawCampos != null) {
      if (rawCampos is List) {
        camposList = rawCampos.map((e) => CampoTipoProposta.fromJson(e)).toList();
      } else if (rawCampos is String && rawCampos.isNotEmpty) {
        try {
          var decoded = jsonDecode(rawCampos);
          if (decoded is List) {
            camposList = decoded.map((e) => CampoTipoProposta.fromJson(e)).toList();
          }
        } catch (_) {}
      }
    }

    return TipoProposta(
      id: json['id'],
      nome: json['nome'] ?? '',
      chave: json['chave'] ?? '',
      campos: camposList,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'nome': nome,
      'chave': chave,
      'campos': jsonEncode(campos.map((e) => e.toJson()).toList()), // Serialized JSON string for GORM
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }
}

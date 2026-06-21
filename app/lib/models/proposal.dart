import 'dart:convert';
import 'company.dart';

class Proposta {
  final String? id;
  final String clienteId;
  final String tipo; // "Imobiliaria", "Auto", "CompraVenda" or custom keys
  final double valor;
  final String status; // "Pendente", "Aprovada", "Recusada", "Em Analise"
  final String? descricao;
  final Map<String, dynamic> dadosEspecificos;
  final String? empresaId;
  final Empresa? empresa;
  final String? statusCorretagem; // "Pendente", "Encaminhada", "FechadaComSucesso"
  final double? valorComissao;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Proposta({
    this.id,
    required this.clienteId,
    required this.tipo,
    required this.valor,
    required this.status,
    this.descricao,
    required this.dadosEspecificos,
    this.empresaId,
    this.empresa,
    this.statusCorretagem,
    this.valorComissao,
    this.createdAt,
    this.updatedAt,
  });

  factory Proposta.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> specData = {};
    var rawSpec = json['dados_especificos'];
    if (rawSpec != null) {
      if (rawSpec is Map) {
        specData = Map<String, dynamic>.from(rawSpec);
      } else if (rawSpec is String && rawSpec.isNotEmpty) {
        try {
          var decoded = jsonDecode(rawSpec);
          if (decoded is Map) {
            specData = Map<String, dynamic>.from(decoded);
          }
        } catch (_) {}
      }
    }

    return Proposta(
      id: json['id'],
      clienteId: json['cliente_id'] ?? '',
      tipo: json['tipo'] ?? '',
      valor: (json['valor'] ?? 0.0).toDouble(),
      status: json['status'] ?? 'Pendente',
      descricao: json['descricao'],
      dadosEspecificos: specData,
      empresaId: json['empresa_id'],
      empresa: json['empresa'] != null ? Empresa.fromJson(json['empresa']) : null,
      statusCorretagem: json['status_corretagem'],
      valorComissao: json['valor_comissao'] != null ? (json['valor_comissao'] as num).toDouble() : null,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'cliente_id': clienteId,
      'tipo': tipo,
      'valor': valor,
      'status': status,
      if (descricao != null) 'descricao': descricao,
      'dados_especificos': jsonEncode(dadosEspecificos), // Send as serialized JSON string to Go backend
      if (empresaId != null) 'empresa_id': empresaId,
      if (empresa != null) 'empresa': empresa!.toJson(),
      if (statusCorretagem != null) 'status_corretagem': statusCorretagem,
      if (valorComissao != null) 'valor_comissao': valorComissao,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }
}

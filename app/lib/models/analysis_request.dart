class PedidoAnalise {
  final String? id;
  final String tipoAcao; // "DeletarCliente", "DeletarProposta", "AprovarProposta", "EncaminharEmpresa"
  final String entidadeId;
  final String entidadeTipo; // "Cliente", "Proposta", etc.
  final String? descricao;
  final String status; // "Pendente", "Aprovado", "Recusado"
  final String? solicitadoPor;
  final String? dadosAcao; // JSON String
  final DateTime? createdAt;
  final DateTime? updatedAt;

  PedidoAnalise({
    this.id,
    required this.tipoAcao,
    required this.entidadeId,
    required this.entidadeTipo,
    this.descricao,
    required this.status,
    this.solicitadoPor,
    this.dadosAcao,
    this.createdAt,
    this.updatedAt,
  });

  factory PedidoAnalise.fromJson(Map<String, dynamic> json) {
    return PedidoAnalise(
      id: json['id'],
      tipoAcao: json['tipo_acao'] ?? '',
      entidadeId: json['entidade_id'] ?? '',
      entidadeTipo: json['entidade_tipo'] ?? '',
      descricao: json['descricao'],
      status: json['status'] ?? 'Pendente',
      solicitadoPor: json['solicitado_por'],
      dadosAcao: json['dados_acao'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'tipo_acao': tipoAcao,
      'entidade_id': entidadeId,
      'entidade_tipo': entidadeTipo,
      if (descricao != null) 'descricao': descricao,
      'status': status,
      if (solicitadoPor != null) 'solicitado_por': solicitadoPor,
      if (dadosAcao != null) 'dados_acao': dadosAcao,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }
}

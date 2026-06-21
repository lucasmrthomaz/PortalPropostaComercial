class DashboardStats {
  final int totalClients;
  final int totalProposals;
  final int totalCompanies;
  final double totalValue;
  final double closedCommissionsValue;
  final double pendingCommissionsValue;
  final Map<String, int> proposalsByStatus;
  final Map<String, int> proposalsByType;
  final Map<String, double> valueByStatus;
  final Map<String, double> valueByType;

  DashboardStats({
    required this.totalClients,
    required this.totalProposals,
    required this.totalCompanies,
    required this.totalValue,
    required this.closedCommissionsValue,
    required this.pendingCommissionsValue,
    required this.proposalsByStatus,
    required this.proposalsByType,
    required this.valueByStatus,
    required this.valueByType,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    Map<String, int> statusCount = {};
    if (json['proposals_by_status'] != null) {
      statusCount = Map<String, int>.from(json['proposals_by_status']);
    }

    Map<String, int> typeCount = {};
    if (json['proposals_by_type'] != null) {
      typeCount = Map<String, int>.from(json['proposals_by_type']);
    }

    Map<String, double> statusVal = {};
    if (json['value_by_status'] != null) {
      json['value_by_status'].forEach((k, v) {
        statusVal[k] = (v as num).toDouble();
      });
    }

    Map<String, double> typeVal = {};
    if (json['value_by_type'] != null) {
      json['value_by_type'].forEach((k, v) {
        typeVal[k] = (v as num).toDouble();
      });
    }

    return DashboardStats(
      totalClients: json['total_clients'] ?? 0,
      totalProposals: json['total_proposals'] ?? 0,
      totalCompanies: json['total_companies'] ?? 0,
      totalValue: (json['total_value'] ?? 0.0).toDouble(),
      closedCommissionsValue: (json['closed_commissions_value'] ?? 0.0).toDouble(),
      pendingCommissionsValue: (json['pending_commissions_value'] ?? 0.0).toDouble(),
      proposalsByStatus: statusCount,
      proposalsByType: typeCount,
      valueByStatus: statusVal,
      valueByType: typeVal,
    );
  }
}

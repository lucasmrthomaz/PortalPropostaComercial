import 'package:flutter/material.dart';
import '../core/constants.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final double fontSize;

  const StatusBadge({
    super.key,
    required this.status,
    this.fontSize = 12.0,
  });

  @override
  Widget build(key) {
    Color color;
    String label;

    switch (status) {
      case 'Aprovada':
      case 'Aprovado':
        color = AppColors.statusApproved;
        label = 'Aprovada';
        break;
      case 'Recusada':
      case 'Recusado':
        color = AppColors.statusRejected;
        label = 'Recusada';
        break;
      case 'Em Analise':
        color = AppColors.statusAnalysis;
        label = 'Em Análise';
        break;
      case 'Pendente':
      default:
        color = AppColors.statusPending;
        label = 'Pendente';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class BrokerageStatusBadge extends StatelessWidget {
  final String? status;

  const BrokerageStatusBadge({super.key, this.status});

  @override
  Widget build(BuildContext context) {
    if (status == null) return const SizedBox.shrink();

    Color color;
    String label;

    switch (status) {
      case 'FechadaComSucesso':
        color = AppColors.statusApproved;
        label = 'Fechada';
        break;
      case 'Encaminhada':
        color = AppColors.statusAnalysis;
        label = 'Encaminhada';
        break;
      case 'Pendente':
      default:
        color = AppColors.statusPending;
        label = 'Pendente';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../core/constants.dart';
import '../../providers/proposal_provider.dart';
import '../../models/proposal.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final NumberFormat _currencyFormat =
      NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final proposalProvider =
        Provider.of<ProposalProvider>(context, listen: false);
    await Future.wait([
      proposalProvider.fetchDashboardStats(),
      proposalProvider.fetchProposals(),
    ]);
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: AppStyles.cardRadius,
        boxShadow: AppStyles.cardShadow(isDark),
        border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.borderLight),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark
                        ? AppColors.textMutedDark
                        : AppColors.textMutedLight,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? AppColors.textMainDark
                        : AppColors.textMainLight,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  List<PieChartSectionData> _getChartSections(Map<String, int> data) {
    if (data.isEmpty) {
      return [
        PieChartSectionData(
          color: Colors.grey.withValues(alpha: 0.3),
          value: 100,
          title: 'Nenhum',
          radius: 40,
          titleStyle: const TextStyle(
              color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
        )
      ];
    }

    final colors = [
      AppColors.primaryLight,
      AppColors.statusPending,
      AppColors.statusApproved,
      AppColors.statusRejected,
      AppColors.accent,
    ];

    int colorIndex = 0;
    return data.entries.map((entry) {
      final color = colors[colorIndex % colors.length];
      colorIndex++;

      // Translate labels
      String title = entry.key;
      if (title == 'Pendente') title = 'Pend.';
      if (title == 'Aprovada') title = 'Aprov.';
      if (title == 'Recusada') title = 'Recus.';
      if (title == 'Em Analise' || title == 'Em Análise') title = 'Anál.';

      return PieChartSectionData(
        color: color,
        value: entry.value.toDouble(),
        title: '$title\n(${entry.value})',
        radius: 45,
        titleStyle: const TextStyle(
            color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
      );
    }).toList();
  }

  Widget _buildRecentProposalRow(Proposta proposal, bool isDark) {
    Color statusColor;
    switch (proposal.status) {
      case 'Aprovada':
        statusColor = AppColors.statusApproved;
        break;
      case 'Recusada':
        statusColor = AppColors.statusRejected;
        break;
      case 'Em Analise':
      case 'Em Análise':
        statusColor = AppColors.statusAnalysis;
        break;
      default:
        statusColor = AppColors.statusPending;
        break;
    }

    String typeLabel = proposal.tipo;
    if (typeLabel == 'Imobiliaria') typeLabel = 'Imobiliária';
    if (typeLabel == 'Auto') typeLabel = 'Automotiva';
    if (typeLabel == 'CompraVenda') typeLabel = 'Compra/Venda';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child:
                Icon(Icons.description_outlined, color: statusColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  typeLabel,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 13),
                ),
                Text(
                  proposal.id != null
                      ? 'Ref: ${proposal.id!.substring(0, 8)}'
                      : '',
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),
          Text(
            _currencyFormat.format(proposal.valor),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final proposalProvider = Provider.of<ProposalProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final stats = proposalProvider.dashboardStats;

    if (proposalProvider.isLoading && stats == null) {
      return const Center(child: CircularProgressIndicator());
    }

    // Default statistics variables in case load fails
    final totalClients = stats?.totalClients ?? 0;
    final totalProposals = stats?.totalProposals ?? 0;
    final totalCompanies = stats?.totalCompanies ?? 0;
    final totalValue = stats?.totalValue ?? 0.0;
    final closedCommissions = stats?.closedCommissionsValue ?? 0.0;
    final pendingCommissions = stats?.pendingCommissionsValue ?? 0.0;
    final statusMap = stats?.proposalsByStatus ?? {};

    // Get recent 5 proposals
    final recentProposals = proposalProvider.proposals.take(5).toList();

    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Screen Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Visão Geral',
                        style: GoogleFonts.outfit(
                            fontSize: 26, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Métricas e status das propostas em tempo real',
                        style: TextStyle(
                            color: isDark
                                ? AppColors.textMutedDark
                                : AppColors.textMutedLight,
                            fontSize: 13),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _loadData,
                ),
              ],
            ),
            const SizedBox(height: 28),

            // Metrics Cards Layout (Responsive Grid)
            LayoutBuilder(
              builder: (context, constraints) {
                int crossAxisCount = constraints.maxWidth >= 900
                    ? 3
                    : (constraints.maxWidth >= 600 ? 2 : 1);
                double spacing = 16.0;
                double width =
                    (constraints.maxWidth - (spacing * (crossAxisCount - 1))) /
                        crossAxisCount;

                final items = [
                  _buildMetricCard(
                    title: 'Total de Clientes',
                    value: totalClients.toString(),
                    icon: Icons.people_outline,
                    color: AppColors.primaryLight,
                    isDark: isDark,
                  ),
                  _buildMetricCard(
                    title: 'Total de Propostas',
                    value: totalProposals.toString(),
                    icon: Icons.assignment_outlined,
                    color: AppColors.statusPending,
                    isDark: isDark,
                  ),
                  _buildMetricCard(
                    title: 'Empresas Parceiras',
                    value: totalCompanies.toString(),
                    icon: Icons.business_outlined,
                    color: Colors.purple,
                    isDark: isDark,
                  ),
                  _buildMetricCard(
                    title: 'Valor Total de Propostas',
                    value: _currencyFormat.format(totalValue),
                    icon: Icons.monetization_on_outlined,
                    color: AppColors.statusApproved,
                    isDark: isDark,
                  ),
                  _buildMetricCard(
                    title: 'Comissões Recebidas',
                    value: _currencyFormat.format(closedCommissions),
                    icon: Icons.check_circle_outline,
                    color: AppColors.statusApproved,
                    isDark: isDark,
                  ),
                  _buildMetricCard(
                    title: 'Comissões Estimadas',
                    value: _currencyFormat.format(pendingCommissions),
                    icon: Icons.hourglass_empty_outlined,
                    color: AppColors.statusAnalysis,
                    isDark: isDark,
                  ),
                ];

                return Wrap(
                  spacing: spacing,
                  runSpacing: spacing,
                  children: items
                      .map((card) => SizedBox(width: width, child: card))
                      .toList(),
                );
              },
            ),
            const SizedBox(height: 28),

            // Charts and Recent Activities
            LayoutBuilder(
              builder: (context, constraints) {
                final bool isWide = constraints.maxWidth >= 800;
                final double columnWidth = isWide
                    ? (constraints.maxWidth - 24) / 2
                    : constraints.maxWidth;

                final chartCard = Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.cardDark : AppColors.cardLight,
                    borderRadius: AppStyles.cardRadius,
                    boxShadow: AppStyles.cardShadow(isDark),
                    border: Border.all(
                        color: isDark
                            ? AppColors.borderDark
                            : AppColors.borderLight),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Propostas por Status',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 220,
                        child: PieChart(
                          PieChartData(
                            sectionsSpace: 4,
                            centerSpaceRadius: 40,
                            sections: _getChartSections(statusMap),
                          ),
                        ),
                      ),
                    ],
                  ),
                );

                final recentActivityCard = Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.cardDark : AppColors.cardLight,
                    borderRadius: AppStyles.cardRadius,
                    boxShadow: AppStyles.cardShadow(isDark),
                    border: Border.all(
                        color: isDark
                            ? AppColors.borderDark
                            : AppColors.borderLight),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Últimas Propostas Cadastradas',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      if (recentProposals.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 32.0),
                          child: Center(
                            child: Text(
                              'Nenhuma proposta cadastrada no momento.',
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 13),
                            ),
                          ),
                        )
                      else
                        ...recentProposals
                            .map((p) => _buildRecentProposalRow(p, isDark)),
                    ],
                  ),
                );

                if (isWide) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(width: columnWidth, child: chartCard),
                      const SizedBox(width: 24),
                      SizedBox(width: columnWidth, child: recentActivityCard),
                    ],
                  );
                } else {
                  return Column(
                    children: [
                      chartCard,
                      const SizedBox(height: 24),
                      recentActivityCard,
                    ],
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

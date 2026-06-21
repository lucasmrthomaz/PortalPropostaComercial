import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/constants.dart';
import '../../models/client.dart';
import '../../models/proposal.dart';
import '../../providers/client_provider.dart';
import '../../widgets/status_badge.dart';
import '../proposals/proposal_detail_screen.dart';

class ClientDetailScreen extends StatefulWidget {
  final Cliente client;

  const ClientDetailScreen({super.key, required this.client});

  @override
  State<ClientDetailScreen> createState() => _ClientDetailScreenState();
}

class _ClientDetailScreenState extends State<ClientDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Proposta> _proposals = [];
  bool _isLoadingProposals = true;
  final NumberFormat _currencyFormat =
      NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy HH:mm');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadProposals();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadProposals() async {
    setState(() {
      _isLoadingProposals = true;
    });

    final clientProvider = Provider.of<ClientProvider>(context, listen: false);
    final list = await clientProvider.fetchClientProposals(widget.client.id!);

    setState(() {
      _proposals = list;
      _isLoadingProposals = false;
    });
  }

  Widget _buildInfoRow(IconData icon, String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.primaryLight),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? AppColors.textMutedDark
                        : AppColors.textMutedLight,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.client.nome,
          style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 900;

          final profileCard = Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : AppColors.cardLight,
              borderRadius: AppStyles.cardRadius,
              boxShadow: AppStyles.cardShadow(isDark),
              border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor:
                          AppColors.primary.withValues(alpha: 0.12),
                      foregroundColor: AppColors.primary,
                      child: Text(
                        widget.client.nome
                            .split(' ')
                            .map((e) => e[0].toUpperCase())
                            .take(2)
                            .join(),
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.client.nome,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'CPF/CNPJ: ${widget.client.cpfCnpj}',
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 13),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 24),
                const Divider(),
                _buildInfoRow(Icons.email_outlined, 'E-mail Comercial',
                    widget.client.email, isDark),
                _buildInfoRow(Icons.phone_outlined, 'Telefone de Contato',
                    widget.client.telefone ?? 'Não informado', isDark),
                _buildInfoRow(Icons.location_on_outlined, 'Endereço Completo',
                    widget.client.endereco ?? 'Não informado', isDark),
              ],
            ),
          );

          final detailsTabs = Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : AppColors.cardLight,
              borderRadius: AppStyles.cardRadius,
              boxShadow: AppStyles.cardShadow(isDark),
              border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight),
            ),
            child: Column(
              children: [
                TabBar(
                  controller: _tabController,
                  labelColor: AppColors.primary,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: AppColors.primary,
                  tabs: const [
                    Tab(
                        icon: Icon(Icons.assignment_outlined),
                        text: 'Propostas Comerciais'),
                    Tab(
                        icon: Icon(Icons.history_outlined),
                        text: 'Histórico de Atividade'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // Tab 1: Proposals
                      _isLoadingProposals
                          ? const Center(child: CircularProgressIndicator())
                          : _proposals.isEmpty
                              ? const Center(
                                  child: Text(
                                      'Nenhuma proposta comercial vinculada.',
                                      style: TextStyle(color: Colors.grey)),
                                )
                              : ListView.builder(
                                  padding: const EdgeInsets.all(16),
                                  itemCount: _proposals.length,
                                  itemBuilder: (context, index) {
                                    final prop = _proposals[index];
                                    String typeLabel = prop.tipo;
                                    if (typeLabel == 'Imobiliaria') {
                                      typeLabel = 'Imobiliária';
                                    }
                                    if (typeLabel == 'Auto') {
                                      typeLabel = 'Automotiva';
                                    }
                                    if (typeLabel == 'CompraVenda') {
                                      typeLabel = 'Compra/Venda';
                                    }

                                    return Card(
                                      margin: const EdgeInsets.only(bottom: 8),
                                      child: ListTile(
                                        title: Text(typeLabel,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold)),
                                        subtitle: Text(
                                            'Valor: ${_currencyFormat.format(prop.valor)}'),
                                        trailing: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            StatusBadge(status: prop.status),
                                            const SizedBox(width: 8),
                                            const Icon(Icons.chevron_right),
                                          ],
                                        ),
                                        onTap: () {
                                          Navigator.of(context)
                                              .push(
                                                MaterialPageRoute(
                                                  builder: (_) =>
                                                      ProposalDetailScreen(
                                                          proposal: prop),
                                                ),
                                              )
                                              .then((_) => _loadProposals());
                                        },
                                      ),
                                    );
                                  },
                                ),
                      // Tab 2: Activity Log
                      Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: ListView(
                          children: [
                            ListTile(
                              leading: const Icon(Icons.check_circle,
                                  color: Colors.green),
                              title: const Text(
                                  'Cliente criado no banco de dados local'),
                              subtitle: Text(widget.client.createdAt != null
                                  ? _dateFormat.format(widget.client.createdAt!)
                                  : 'Data não informada'),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          );

          if (isWide) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 2,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: profileCard,
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: detailsTabs,
                  ),
                )
              ],
            );
          } else {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  profileCard,
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 400,
                    child: detailsTabs,
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}

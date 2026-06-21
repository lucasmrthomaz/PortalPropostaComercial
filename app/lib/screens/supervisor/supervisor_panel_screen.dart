import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/constants.dart';
import '../../providers/supervisor_provider.dart';
import '../../models/analysis_request.dart';
import '../../widgets/status_badge.dart';

class SupervisorPanelScreen extends StatefulWidget {
  const SupervisorPanelScreen({super.key});

  @override
  State<SupervisorPanelScreen> createState() => _SupervisorPanelScreenState();
}

class _SupervisorPanelScreenState extends State<SupervisorPanelScreen> {
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy HH:mm');
  String _activeTabFilter = 'Pendente'; // 'Pendente' or 'Todos'

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadRequests();
    });
  }

  Future<void> _loadRequests() async {
    final provider = Provider.of<SupervisorProvider>(context, listen: false);
    // If Tab is Pendente, pass status 'Pendente', else null (for all)
    await provider.fetchRequests(
        status: _activeTabFilter == 'Pendente' ? 'Pendente' : null);
  }

  String _getActionLabel(String action) {
    switch (action) {
      case 'DeletarCliente':
        return 'Excluir Cliente';
      case 'DeletarProposta':
        return 'Excluir Proposta';
      case 'AprovarProposta':
        return 'Aprovar Proposta';
      case 'EncaminharEmpresa':
        return 'Encaminhar para Parceiro';
      default:
        return action;
    }
  }

  void _approve(PedidoAnalise req) {
    final provider = Provider.of<SupervisorProvider>(context, listen: false);
    setState(() {});
    provider.approveRequest(req.id!).then((success) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Solicitação aprovada e executada com sucesso!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  provider.errorMessage ?? 'Falha ao aprovar solicitação.')),
        );
      }
    });
  }

  void _reject(PedidoAnalise req) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Recusar Solicitação'),
          content: const Text(
              'Deseja realmente recusar esta solicitação de análise?'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar')),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                final provider =
                    Provider.of<SupervisorProvider>(context, listen: false);
                provider.rejectRequest(req.id!).then((success) {
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Solicitação recusada com sucesso.')),
                    );
                  }
                });
              },
              child: const Text('Recusar',
                  style: TextStyle(color: Colors.redAccent)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final supervisorProvider = Provider.of<SupervisorProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title & Refresh
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Painel do Supervisor',
                        style: GoogleFonts.outfit(
                            fontSize: 26, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Fila de liberação para ações administrativas e análises críticas',
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
                  onPressed: _loadRequests,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Tab Filter Buttons
            Row(
              children: [
                ChoiceChip(
                  label: const Text('Pendentes'),
                  selected: _activeTabFilter == 'Pendente',
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _activeTabFilter = 'Pendente';
                      });
                      _loadRequests();
                    }
                  },
                ),
                const SizedBox(width: 12),
                ChoiceChip(
                  label: const Text('Histórico Completo'),
                  selected: _activeTabFilter == 'Todos',
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _activeTabFilter = 'Todos';
                      });
                      _loadRequests();
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Requests List
            Expanded(
              child: supervisorProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : supervisorProvider.requests.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.checklist_outlined,
                                  size: 64,
                                  color: Colors.grey.withValues(alpha: 0.5)),
                              const SizedBox(height: 16),
                              Text(
                                _activeTabFilter == 'Pendente'
                                    ? 'Nenhuma solicitação pendente no momento.'
                                    : 'Nenhuma solicitação encontrada no histórico.',
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: supervisorProvider.requests.length,
                          itemBuilder: (context, index) {
                            final req = supervisorProvider.requests[index];

                            return Card(
                              margin: const EdgeInsets.only(bottom: 16),
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: AppStyles.cardRadius,
                                side: BorderSide(
                                    color: isDark
                                        ? AppColors.borderDark
                                        : AppColors.borderLight),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Row 1: Header
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: AppColors.secondary
                                                .withValues(alpha: 0.12),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            _getActionLabel(req.tipoAcao)
                                                .toUpperCase(),
                                            style: const TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.secondary,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                        ),
                                        StatusBadge(status: req.status),
                                      ],
                                    ),
                                    const SizedBox(height: 12),

                                    // Row 2: Description
                                    Text(
                                      req.descricao ?? 'Sem descrição da ação.',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 14),
                                    ),
                                    const SizedBox(height: 12),

                                    // Row 3: Meta info & action buttons
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            'Solicitado por: ${req.solicitadoPor ?? "N/A"} • ${req.createdAt != null ? _dateFormat.format(req.createdAt!) : ""}',
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                                fontSize: 11, color: Colors.grey),
                                          ),
                                        ),
                                        const SizedBox(width: 8),

                                        // Approve / Reject actions (only visible if status is Pendente)
                                        if (req.status == 'Pendente')
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              OutlinedButton.icon(
                                                onPressed: () => _reject(req),
                                                icon: const Icon(Icons.close,
                                                    size: 14,
                                                    color: Colors.redAccent),
                                                label: const Text('Recusar',
                                                    style: TextStyle(
                                                        fontSize: 12)),
                                                style: OutlinedButton.styleFrom(
                                                  foregroundColor:
                                                      Colors.redAccent,
                                                  side: const BorderSide(
                                                      color: Colors.redAccent),
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              16)),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              ElevatedButton.icon(
                                                onPressed: () => _approve(req),
                                                icon: const Icon(Icons.check,
                                                    size: 14),
                                                label: const Text('Aprovar',
                                                    style: TextStyle(
                                                        fontSize: 12)),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      AppColors.statusApproved,
                                                  foregroundColor: Colors.white,
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              16)),
                                                ),
                                              ),
                                            ],
                                          )
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            )
          ],
        ),
      ),
    );
  }
}

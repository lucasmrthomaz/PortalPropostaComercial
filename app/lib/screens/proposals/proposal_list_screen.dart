import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/constants.dart';
import '../../providers/proposal_provider.dart';
import '../../providers/client_provider.dart';
import '../../providers/company_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/proposal.dart';
import '../../models/analysis_request.dart';
import '../../models/company.dart';
import '../../models/client.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/supervisor_dialog.dart';
import 'proposal_form_screen.dart';
import 'proposal_detail_screen.dart';

class ProposalListScreen extends StatefulWidget {
  final String? filterClientId;

  const ProposalListScreen({super.key, this.filterClientId});

  @override
  State<ProposalListScreen> createState() => _ProposalListScreenState();
}

class _ProposalListScreenState extends State<ProposalListScreen> {
  final NumberFormat _currencyFormat =
      NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy HH:mm');

  String _selectedClientFilter = 'all';
  String _selectedTypeFilter = 'all';
  String _selectedStatusFilter = 'all';

  @override
  void initState() {
    super.initState();
    if (widget.filterClientId != null) {
      _selectedClientFilter = widget.filterClientId!;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    await Future.wait([
      Provider.of<ClientProvider>(context, listen: false).fetchClients(),
      Provider.of<CompanyProvider>(context, listen: false).fetchCompanies(),
      Provider.of<ProposalProvider>(context, listen: false).fetchProposals(),
    ]);
  }

  void _openProposalForm([Proposta? proposal]) {
    showDialog(
      context: context,
      builder: (_) => ProposalFormScreen(proposal: proposal),
    );
  }

  void _deleteProposal(Proposta proposal) {
    final proposalProvider =
        Provider.of<ProposalProvider>(context, listen: false);
    final clientProvider = Provider.of<ClientProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final clientName = clientProvider.clients
        .firstWhere((c) => c.id == proposal.clienteId,
            orElse: () => clientProvider.clients.isNotEmpty
                ? clientProvider.clients.first
                : Cliente(nome: 'Carregando...', cpfCnpj: '', email: ''))
        .nome;

    final ped = PedidoAnalise(
      tipoAcao: 'DeletarProposta',
      entidadeId: proposal.id!,
      entidadeTipo: 'Proposta',
      status: 'Pendente',
      solicitadoPor: authProvider.currentUser?.nome ?? 'Sistema',
      descricao:
          'Excluir proposta comercial de R\$ ${proposal.valor} (Cliente: $clientName).',
      dadosAcao: '{"proposta_id":"${proposal.id}"}',
    );

    showDialog(
      context: context,
      builder: (_) => SupervisorDialog(
        title: 'Excluir Proposta Comercial',
        description:
            'Você está tentando excluir permanentemente a proposta de R\$ ${proposal.valor} do cliente $clientName.',
        pedido: ped,
      ),
    ).then((res) {
      if (res != null) {
        if (res['confirmed'] == true) {
          proposalProvider.deleteProposal(proposal.id!).then((success) {
            if (success) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Proposta excluída com sucesso!')),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(proposalProvider.errorMessage ??
                        'Erro ao excluir proposta.')),
              );
            }
          });
        } else if (res['submitted'] == true) {
          proposalProvider.fetchProposals();
        }
      }
    });
  }

  void _approveProposalDirectly(Proposta proposal) {
    final proposalProvider =
        Provider.of<ProposalProvider>(context, listen: false);
    final clientProvider = Provider.of<ClientProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final clientName = clientProvider.clients
        .firstWhere((c) => c.id == proposal.clienteId,
            orElse: () => clientProvider.clients.isNotEmpty
                ? clientProvider.clients.first
                : Cliente(nome: 'Carregando...', cpfCnpj: '', email: ''))
        .nome;

    final ped = PedidoAnalise(
      tipoAcao: 'AprovarProposta',
      entidadeId: proposal.id!,
      entidadeTipo: 'Proposta',
      status: 'Pendente',
      solicitadoPor: authProvider.currentUser?.nome ?? 'Sistema',
      descricao:
          'Aprovar proposta comercial de R\$ ${proposal.valor} para o cliente $clientName.',
      dadosAcao: '{"proposta_id":"${proposal.id}"}',
    );

    showDialog(
      context: context,
      builder: (_) => SupervisorDialog(
        title: 'Aprovar Proposta Comercial',
        description:
            'Você está tentando aprovar a proposta de R\$ ${proposal.valor} do cliente $clientName. Isso ativará a cobrança de corretagem caso haja empresa parceira vinculada.',
        pedido: ped,
      ),
    ).then((res) {
      if (res != null) {
        if (res['confirmed'] == true) {
          final updated = Proposta(
            id: proposal.id,
            clienteId: proposal.clienteId,
            tipo: proposal.tipo,
            valor: proposal.valor,
            status: 'Aprovada',
            descricao: proposal.descricao,
            dadosEspecificos: proposal.dadosEspecificos,
            empresaId: proposal.empresaId,
            statusCorretagem: proposal.statusCorretagem,
            valorComissao: proposal.valorComissao,
          );
          proposalProvider
              .updateProposal(proposal.id!, updated)
              .then((success) {
            if (success) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Proposta aprovada com sucesso!')),
              );
            }
          });
        } else if (res['submitted'] == true) {
          proposalProvider.fetchProposals();
        }
      }
    });
  }

  void _forwardProposal(Proposta proposal) {
    final companyProvider =
        Provider.of<CompanyProvider>(context, listen: false);
    final activeCompanies =
        companyProvider.companies.where((e) => e.ativo).toList();

    if (activeCompanies.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Não existem empresas parceiras ativas cadastradas.')),
      );
      return;
    }

    showDialog<Empresa>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Selecionar Empresa Parceira'),
          content: SizedBox(
            width: 300,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: activeCompanies.length,
              itemBuilder: (context, index) {
                final company = activeCompanies[index];
                return ListTile(
                  title: Text(company.nome),
                  subtitle:
                      Text('Representante: ${company.responsavelNome ?? ""}'),
                  onTap: () => Navigator.of(context).pop(company),
                );
              },
            ),
          ),
        );
      },
    ).then((selectedCompany) {
      if (selectedCompany == null) return;

      final proposalProvider =
          Provider.of<ProposalProvider>(context, listen: false);
      final clientProvider =
          Provider.of<ClientProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      final clientName = clientProvider.clients
          .firstWhere((c) => c.id == proposal.clienteId,
              orElse: () => clientProvider.clients.isNotEmpty
                  ? clientProvider.clients.first
                  : Cliente(nome: 'Carregando...', cpfCnpj: '', email: ''))
          .nome;

      final ped = PedidoAnalise(
        tipoAcao: 'EncaminharEmpresa',
        entidadeId: proposal.id!,
        entidadeTipo: 'Proposta',
        status: 'Pendente',
        solicitadoPor: authProvider.currentUser?.nome ?? 'Sistema',
        descricao:
            'Encaminhar proposta comercial de R\$ ${proposal.valor} (Cliente: $clientName) para a empresa parceira ${selectedCompany.nome}. Representante: ${selectedCompany.responsavelNome}.',
        dadosAcao:
            '{"proposta_id":"${proposal.id}","empresa_id":"${selectedCompany.id}"}',
      );

      showDialog(
        context: context,
        builder: (_) => SupervisorDialog(
          title: 'Encaminhar Proposta',
          description:
              'Você está tentando encaminhar os dados da proposta de R\$ ${proposal.valor} do cliente "$clientName" para a empresa parceira "${selectedCompany.nome}".',
          pedido: ped,
        ),
      ).then((res) {
        if (res != null) {
          if (res['confirmed'] == true) {
            final updated = Proposta(
              id: proposal.id,
              clienteId: proposal.clienteId,
              tipo: proposal.tipo,
              valor: proposal.valor,
              status: proposal.status,
              descricao: proposal.descricao,
              dadosEspecificos: proposal.dadosEspecificos,
              empresaId: selectedCompany.id,
              statusCorretagem: 'Encaminhada',
              valorComissao: proposal.valorComissao,
            );
            proposalProvider
                .updateProposal(proposal.id!, updated)
                .then((success) {
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Proposta encaminhada com sucesso!')),
                );
              }
            });
          } else if (res['submitted'] == true) {
            proposalProvider.fetchProposals();
          }
        }
      });
    });
  }

  String _getTypeLabel(String tipo) {
    switch (tipo) {
      case 'Imobiliaria':
        return 'Imobiliária';
      case 'Auto':
        return 'Automotiva';
      case 'CompraVenda':
        return 'Compra/Venda Diversas';
      default:
        return tipo;
    }
  }

  @override
  Widget build(BuildContext context) {
    final proposalProvider = Provider.of<ProposalProvider>(context);
    final clientProvider = Provider.of<ClientProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Filter proposals logic
    final filteredProposals = proposalProvider.proposals.where((p) {
      if (_selectedClientFilter != 'all' &&
          p.clienteId != _selectedClientFilter) {
        return false;
      }
      if (_selectedTypeFilter != 'all' && p.tipo != _selectedTypeFilter) {
        return false;
      }
      if (_selectedStatusFilter != 'all' && p.status != _selectedStatusFilter) {
        return false;
      }
      return true;
    }).toList();

    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Action
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Propostas Comerciais',
                        style: GoogleFonts.outfit(
                            fontSize: 26, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Acompanhe, envie a empresas parceiras e gerencie o fluxo de propostas',
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
                ElevatedButton.icon(
                  onPressed: () => _openProposalForm(),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Nova Proposta'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: AppStyles.buttonRadius),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Dropdown Filter Row
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : AppColors.cardLight,
                borderRadius: AppStyles.cardRadius,
                border: Border.all(
                    color:
                        isDark ? AppColors.borderDark : AppColors.borderLight),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final bool isCompact = constraints.maxWidth < 600;
                  final childrenList = [
                    // Client filter
                    DropdownButtonFormField<String>(
                      initialValue: _selectedClientFilter,
                      decoration: const InputDecoration(
                          labelText: 'Cliente', border: InputBorder.none),
                      items: [
                        const DropdownMenuItem(
                            value: 'all', child: Text('Todos os Clientes')),
                        ...clientProvider.clients.map((c) =>
                            DropdownMenuItem(value: c.id, child: Text(c.nome))),
                      ],
                      onChanged: (val) {
                        setState(() {
                          _selectedClientFilter = val ?? 'all';
                        });
                      },
                    ),
                    // Proposal Type filter
                    DropdownButtonFormField<String>(
                      initialValue: _selectedTypeFilter,
                      decoration: const InputDecoration(
                          labelText: 'Tipo', border: InputBorder.none),
                      items: const [
                        DropdownMenuItem(
                            value: 'all', child: Text('Todos os Tipos')),
                        DropdownMenuItem(
                            value: 'Imobiliaria', child: Text('Imobiliária')),
                        DropdownMenuItem(
                            value: 'Auto', child: Text('Automotiva')),
                        DropdownMenuItem(
                            value: 'CompraVenda', child: Text('Compra/Venda')),
                      ],
                      onChanged: (val) {
                        setState(() {
                          _selectedTypeFilter = val ?? 'all';
                        });
                      },
                    ),
                    // Status filter
                    DropdownButtonFormField<String>(
                      initialValue: _selectedStatusFilter,
                      decoration: const InputDecoration(
                          labelText: 'Status', border: InputBorder.none),
                      items: const [
                        DropdownMenuItem(
                            value: 'all', child: Text('Todos os Status')),
                        DropdownMenuItem(
                            value: 'Pendente', child: Text('Pendente')),
                        DropdownMenuItem(
                            value: 'Aprovada', child: Text('Aprovada')),
                        DropdownMenuItem(
                            value: 'Recusada', child: Text('Recusada')),
                        DropdownMenuItem(
                            value: 'Em Analise', child: Text('Em Análise')),
                      ],
                      onChanged: (val) {
                        setState(() {
                          _selectedStatusFilter = val ?? 'all';
                        });
                      },
                    ),
                  ];

                  if (isCompact) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        childrenList[0],
                        const SizedBox(height: 12),
                        childrenList[1],
                        const SizedBox(height: 12),
                        childrenList[2],
                      ],
                    );
                  } else {
                    return Row(
                      children: [
                        Expanded(child: childrenList[0]),
                        const SizedBox(width: 16),
                        Expanded(child: childrenList[1]),
                        const SizedBox(width: 16),
                        Expanded(child: childrenList[2]),
                      ],
                    );
                  }
                },
              ),
            ),
            const SizedBox(height: 20),

            // Proposals List / Table representation
            Expanded(
              child: proposalProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filteredProposals.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.assignment_outlined,
                                  size: 64,
                                  color: Colors.grey.withValues(alpha: 0.5)),
                              const SizedBox(height: 16),
                              const Text('Nenhuma proposta encontrada.',
                                  style: TextStyle(color: Colors.grey)),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: filteredProposals.length,
                          itemBuilder: (context, index) {
                            final prop = filteredProposals[index];
                            final client = clientProvider.clients.firstWhere(
                                (c) => c.id == prop.clienteId,
                                orElse: () => Cliente(
                                    nome: 'Carregando...',
                                    cpfCnpj: '',
                                    email: ''));

                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: AppStyles.cardRadius,
                                side: BorderSide(
                                    color: isDark
                                        ? AppColors.borderDark
                                        : AppColors.borderLight),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ListTile(
                                  title: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          client.nome,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        _currencyFormat.format(prop.valor),
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.primaryLight),
                                      ),
                                    ],
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 4),
                                      Text(
                                          'Tipo: ${_getTypeLabel(prop.tipo)} • Data: ${prop.createdAt != null ? _dateFormat.format(prop.createdAt!) : ""}'),
                                      if (prop.empresa != null) ...[
                                        const SizedBox(height: 2),
                                        Row(
                                          children: [
                                            const Icon(Icons.business,
                                                size: 14, color: Colors.grey),
                                            const SizedBox(width: 4),
                                            Expanded(
                                              child: Text(
                                                'Parceiro: ${prop.empresa!.nome}',
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                    fontSize: 12),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            BrokerageStatusBadge(
                                                status: prop.statusCorretagem),
                                          ],
                                        ),
                                      ]
                                    ],
                                  ),
                                  trailing: PopupMenuButton<String>(
                                    onSelected: (val) {
                                      if (val == 'view') {
                                        Navigator.of(context)
                                            .push(
                                              MaterialPageRoute(
                                                  builder: (_) =>
                                                      ProposalDetailScreen(
                                                          proposal: prop)),
                                            )
                                            .then((_) => _loadData());
                                      } else if (val == 'edit') {
                                        _openProposalForm(prop);
                                      } else if (val == 'approve' &&
                                          prop.status == 'Pendente') {
                                        _approveProposalDirectly(prop);
                                      } else if (val == 'forward' &&
                                          prop.statusCorretagem !=
                                              'Encaminhada') {
                                        _forwardProposal(prop);
                                      } else if (val == 'delete') {
                                        _deleteProposal(prop);
                                      }
                                    },
                                    itemBuilder: (context) => [
                                      const PopupMenuItem(
                                        value: 'view',
                                        child: ListTile(
                                          leading:
                                              Icon(Icons.visibility_outlined),
                                          title: Text('Detalhes'),
                                        ),
                                      ),
                                      const PopupMenuItem(
                                        value: 'edit',
                                        child: ListTile(
                                          leading: Icon(Icons.edit_outlined),
                                          title: Text('Editar'),
                                        ),
                                      ),
                                      if (prop.status == 'Pendente')
                                        const PopupMenuItem(
                                          value: 'approve',
                                          child: ListTile(
                                            leading: Icon(Icons.check,
                                                color:
                                                    AppColors.statusApproved),
                                            title: Text('Aprovar Proposta'),
                                          ),
                                        ),
                                      if (prop.statusCorretagem !=
                                              'Encaminhada' &&
                                          prop.statusCorretagem !=
                                              'FechadaComSucesso')
                                        const PopupMenuItem(
                                          value: 'forward',
                                          child: ListTile(
                                            leading: Icon(Icons.send_outlined,
                                                color:
                                                    AppColors.statusAnalysis),
                                            title: Text('Encaminhar Parceiro'),
                                          ),
                                        ),
                                      const PopupMenuItem(
                                        value: 'delete',
                                        child: ListTile(
                                          leading: Icon(Icons.delete_outline,
                                              color: Colors.redAccent),
                                          title: Text('Excluir',
                                              style: TextStyle(
                                                  color: Colors.redAccent)),
                                        ),
                                      ),
                                    ],
                                  ),
                                  onTap: () {
                                    Navigator.of(context)
                                        .push(
                                          MaterialPageRoute(
                                              builder: (_) =>
                                                  ProposalDetailScreen(
                                                      proposal: prop)),
                                        )
                                        .then((_) => _loadData());
                                  },
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

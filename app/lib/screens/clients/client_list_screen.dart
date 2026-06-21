import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../providers/client_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/client.dart';
import '../../models/analysis_request.dart';
import '../../widgets/supervisor_dialog.dart';
import 'client_form_screen.dart';
import 'client_detail_screen.dart';
import '../proposals/proposal_form_screen.dart';

class ClientListScreen extends StatefulWidget {
  const ClientListScreen({super.key});

  @override
  State<ClientListScreen> createState() => _ClientListScreenState();
}

class _ClientListScreenState extends State<ClientListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ClientProvider>(context, listen: false).fetchClients();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openClientForm([Cliente? client]) {
    showDialog(
      context: context,
      builder: (_) => ClientFormScreen(client: client),
    );
  }

  void _deleteClient(Cliente client) {
    final clientProvider = Provider.of<ClientProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final ped = PedidoAnalise(
      tipoAcao: 'DeletarCliente',
      entidadeId: client.id!,
      entidadeTipo: 'Cliente',
      status: 'Pendente',
      solicitadoPor: authProvider.currentUser?.nome ?? 'Sistema',
      descricao:
          'Excluir o cliente "${client.nome}" (CPF/CNPJ: ${client.cpfCnpj}) e todas as suas propostas associadas.',
      dadosAcao: '{"cliente_id":"${client.id}"}',
    );

    showDialog(
      context: context,
      builder: (_) => SupervisorDialog(
        title: 'Excluir Cliente',
        description:
            'Você está tentando excluir o cliente "${client.nome}". Esta ação removerá todas as propostas associadas permanentemente.',
        pedido: ped,
      ),
    ).then((res) {
      if (res != null) {
        if (res['confirmed'] == true) {
          // Direct bypass
          clientProvider.deleteClient(client.id!).then((success) {
            if (success) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cliente excluído com sucesso!')),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(clientProvider.errorMessage ??
                        'Erro ao excluir cliente.')),
              );
            }
          });
        } else if (res['submitted'] == true) {
          // Submitted to supervisor queue
          clientProvider.fetchClients();
        }
      }
    });
  }

  void _addProposalForClient(Cliente client) {
    showDialog(
      context: context,
      builder: (_) => ProposalFormScreen(presetClient: client),
    );
  }

  @override
  Widget build(BuildContext context) {
    final clientProvider = Provider.of<ClientProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Filter clients based on search query
    final filteredClients = clientProvider.clients.where((c) {
      final q = _searchQuery.toLowerCase();
      return c.nome.toLowerCase().contains(q) ||
          c.cpfCnpj.toLowerCase().contains(q) ||
          c.email.toLowerCase().contains(q) ||
          (c.telefone != null && c.telefone!.contains(q));
    }).toList();

    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title & Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Clientes',
                        style: GoogleFonts.outfit(
                            fontSize: 26, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Gerenciamento de contatos e informações cadastrais',
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
                  onPressed: () => _openClientForm(),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Novo Cliente'),
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

            // Search Filter Row
            Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : AppColors.cardLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color:
                        isDark ? AppColors.borderDark : AppColors.borderLight),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _searchController,
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val;
                  });
                },
                decoration: const InputDecoration(
                  hintText: 'Pesquise por nome, CPF/CNPJ, e-mail...',
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Clients List
            Expanded(
              child: clientProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filteredClients.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.people_outline,
                                  size: 64,
                                  color: Colors.grey.withValues(alpha: 0.5)),
                              const SizedBox(height: 16),
                              const Text(
                                  'Nenhum cliente cadastrado ou encontrado.',
                                  style: TextStyle(color: Colors.grey)),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: filteredClients.size,
                          itemBuilder: (context, index) {
                            final client = filteredClients[index];
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
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor:
                                      AppColors.primary.withValues(alpha: 0.12),
                                  foregroundColor: AppColors.primary,
                                  child: const Icon(Icons.person),
                                ),
                                title: Text(client.nome,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                                subtitle: Text(
                                  'CPF/CNPJ: ${client.cpfCnpj} • ${client.email}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.add_task,
                                          color: AppColors.statusPending),
                                      tooltip: 'Nova Proposta',
                                      onPressed: () =>
                                          _addProposalForClient(client),
                                    ),
                                    PopupMenuButton<String>(
                                      onSelected: (val) {
                                        if (val == 'view') {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder: (_) =>
                                                    ClientDetailScreen(
                                                        client: client)),
                                          );
                                        } else if (val == 'edit') {
                                          _openClientForm(client);
                                        } else if (val == 'delete') {
                                          _deleteClient(client);
                                        }
                                      },
                                      itemBuilder: (context) => [
                                        const PopupMenuItem(
                                          value: 'view',
                                          child: ListTile(
                                            leading:
                                                Icon(Icons.visibility_outlined),
                                            title: Text('Visualizar Detalhes'),
                                          ),
                                        ),
                                        const PopupMenuItem(
                                          value: 'edit',
                                          child: ListTile(
                                            leading: Icon(Icons.edit_outlined),
                                            title: Text('Editar Cadastro'),
                                          ),
                                        ),
                                        const PopupMenuItem(
                                          value: 'delete',
                                          child: ListTile(
                                            leading: Icon(Icons.delete_outline,
                                                color: Colors.redAccent),
                                            title: Text('Excluir Cliente',
                                                style: TextStyle(
                                                    color: Colors.redAccent)),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                        builder: (_) =>
                                            ClientDetailScreen(client: client)),
                                  );
                                },
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

extension ListExtensions<T> on List<T> {
  int get size => length;
}

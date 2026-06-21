import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/constants.dart';
import '../../models/proposal.dart';
import '../../models/client.dart';
import '../../providers/client_provider.dart';
import '../../widgets/status_badge.dart';

class ProposalDetailScreen extends StatefulWidget {
  final Proposta proposal;

  const ProposalDetailScreen({super.key, required this.proposal});

  @override
  State<ProposalDetailScreen> createState() => _ProposalDetailScreenState();
}

class _ProposalDetailScreenState extends State<ProposalDetailScreen> {
  final NumberFormat _currencyFormat =
      NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy HH:mm');
  Cliente? _client;
  bool _isLoadingClient = true;

  @override
  void initState() {
    super.initState();
    _loadClient();
  }

  Future<void> _loadClient() async {
    final clientProvider = Provider.of<ClientProvider>(context, listen: false);
    try {
      // Find client in loaded client cache or download
      _client = clientProvider.clients
          .firstWhere((e) => e.id == widget.proposal.clienteId);
      setState(() {
        _isLoadingClient = false;
      });
    } catch (_) {
      // Fetch clients to reload cache if not found
      await clientProvider.fetchClients();
      if (mounted) {
        setState(() {
          try {
            _client = clientProvider.clients
                .firstWhere((e) => e.id == widget.proposal.clienteId);
          } catch (_) {}
          _isLoadingClient = false;
        });
      }
    }
  }

  Widget _buildTimelineStep({
    required String title,
    required String subtitle,
    required bool isCompleted,
    required bool isLast,
    required IconData icon,
    required Color color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isCompleted ? color : Colors.grey.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 16, color: Colors.white),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: isCompleted ? color : Colors.grey.withValues(alpha: 0.2),
              )
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: isCompleted ? null : Colors.grey,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 12),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildFieldRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style:
                  const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoWidget(String fotoData) {
    try {
      String base64Str = fotoData;
      if (base64Str.contains(',')) {
        base64Str = base64Str.split(',').last;
      }
      final decodedBytes = base64Decode(base64Str);
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.memory(
          decodedBytes,
          fit: BoxFit.cover,
          width: double.infinity,
          height: 180,
          errorBuilder: (context, error, stackTrace) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.broken_image, size: 48, color: Colors.redAccent),
                  SizedBox(height: 8),
                  Text('Erro ao carregar imagem', style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            );
          },
        ),
      );
    } catch (e) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.broken_image, size: 48, color: Colors.redAccent),
            SizedBox(height: 8),
            Text('Erro ao decodificar imagem', style: TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final prop = widget.proposal;

    String typeLabel = prop.tipo;
    if (typeLabel == 'Imobiliaria') typeLabel = 'Imobiliária';
    if (typeLabel == 'Auto') typeLabel = 'Automotiva';
    if (typeLabel == 'CompraVenda') typeLabel = 'Compra/Venda';

    // Timeline calculations
    const bool step1Done = true; // Created is always true
    final bool step2Done =
        prop.empresaId != null || prop.statusCorretagem == 'Encaminhada';
    final bool step3Done =
        prop.status == 'Aprovada' || prop.status == 'Recusada';

    String step3Subtitle = 'Aguardando decisão da análise de crédito';
    if (prop.status == 'Aprovada') {
      step3Subtitle = 'Aprovada e fechada';
    } else if (prop.status == 'Recusada') {
      step3Subtitle = 'Recusada e finalizada';
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Detalhes da Proposta',
            style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoadingClient
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth >= 800;

                  final mainContent = Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Overview Card
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color:
                              isDark ? AppColors.cardDark : AppColors.cardLight,
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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                StatusBadge(status: prop.status),
                                Text(
                                  _dateFormat
                                      .format(prop.createdAt ?? DateTime.now()),
                                  style: const TextStyle(
                                      color: Colors.grey, fontSize: 12),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              typeLabel,
                              style: GoogleFonts.outfit(
                                  fontSize: 22, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _currencyFormat.format(prop.valor),
                              style: GoogleFonts.outfit(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryLight),
                            ),
                            if (prop.descricao != null &&
                                prop.descricao!.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              const Text('Descrição:',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13)),
                              const SizedBox(height: 4),
                              Text(prop.descricao!,
                                  style: const TextStyle(
                                      color: Colors.grey, height: 1.4)),
                            ]
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Specific Data Card
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color:
                              isDark ? AppColors.cardDark : AppColors.cardLight,
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
                            const Text('Dados Específicos',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 16),
                            if (prop.tipo == 'Imobiliaria') ...[
                              _buildFieldRow(
                                  'Endereço',
                                  prop.dadosEspecificos['endereco_imovel'] ??
                                      ''),
                              _buildFieldRow('Tipo Imóvel',
                                  prop.dadosEspecificos['tipo_imovel'] ?? ''),
                              _buildFieldRow('Área m²',
                                  '${prop.dadosEspecificos['area_m2']} m²'),
                            ] else if (prop.tipo == 'Auto') ...[
                              _buildFieldRow('Marca',
                                  prop.dadosEspecificos['marca'] ?? ''),
                              _buildFieldRow('Modelo',
                                  prop.dadosEspecificos['modelo'] ?? ''),
                              _buildFieldRow(
                                  'Ano',
                                  prop.dadosEspecificos['ano']?.toString() ??
                                      ''),
                              _buildFieldRow('Placa',
                                  prop.dadosEspecificos['placa'] ?? ''),
                            ] else if (prop.tipo == 'CompraVenda') ...[
                              _buildFieldRow('Itens',
                                  prop.dadosEspecificos['itens'] ?? ''),
                              _buildFieldRow(
                                  'Condições Pagamento',
                                  prop.dadosEspecificos[
                                          'condicoes_pagamento'] ??
                                      ''),
                            ] else ...[
                              ...prop.dadosEspecificos.entries.map((e) =>
                                  _buildFieldRow(
                                      e.key.toUpperCase(), e.value.toString())),
                            ],

                            // Mocking Photo Attachments view
                            if (prop.dadosEspecificos['foto'] != null &&
                                prop.dadosEspecificos['foto']
                                    .toString()
                                    .isNotEmpty) ...[
                              const SizedBox(height: 20),
                              const Text('Foto Anexada:',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13)),
                              const SizedBox(height: 8),
                              Container(
                                height: 180,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color:
                                          Colors.grey.withValues(alpha: 0.3)),
                                  color: Colors.grey.withValues(alpha: 0.1),
                                ),
                                child: _buildPhotoWidget(
                                    prop.dadosEspecificos['foto'].toString()),
                              ),
                            ],

                            // Mocking File Attachment Link
                            if (prop.dadosEspecificos['nome_anexo'] != null &&
                                prop.dadosEspecificos['nome_anexo']
                                    .toString()
                                    .isNotEmpty) ...[
                              const SizedBox(height: 16),
                              ListTile(
                                leading: const Icon(Icons.picture_as_pdf,
                                    color: Colors.redAccent),
                                title: Text(prop.dadosEspecificos['nome_anexo']
                                    .toString()),
                                subtitle: const Text(
                                    'Anexo Comercial (Download Disponível)'),
                                trailing: const Icon(Icons.download),
                                dense: true,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                tileColor: Colors.grey.withValues(alpha: 0.1),
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            'Download do arquivo iniciado...')),
                                  );
                                },
                              ),
                            ]
                          ],
                        ),
                      ),
                    ],
                  );

                  final sidebarContent = Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Client Info Card
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color:
                              isDark ? AppColors.cardDark : AppColors.cardLight,
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
                            const Text('Dados do Cliente',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 16),
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(_client?.nome ?? 'Não encontrado',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                              subtitle: Text(
                                  'CPF/CNPJ: ${_client?.cpfCnpj ?? ""}\nE-mail: ${_client?.email ?? ""}'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Brokerage details Card
                      if (prop.empresa != null) ...[
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.cardDark
                                : AppColors.cardLight,
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
                              const Text('Parceiro & Comissão',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(height: 16),
                              _buildFieldRow(
                                  'Empresa Vinculada', prop.empresa!.nome),
                              _buildFieldRow('Status Repasse',
                                  prop.statusCorretagem ?? 'Pendente'),
                              const Divider(),
                              _buildFieldRow(
                                  'Valor da Comissão',
                                  _currencyFormat
                                      .format(prop.valorComissao ?? 0.0)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Proposal Status Timeline Card
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color:
                              isDark ? AppColors.cardDark : AppColors.cardLight,
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
                            const Text('Status do Fluxo',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 24),
                            _buildTimelineStep(
                              title: 'Proposta Cadastrada',
                              subtitle: 'Registrada com sucesso no portal',
                              isCompleted: step1Done,
                              isLast: false,
                              icon: Icons.add,
                              color: AppColors.primaryLight,
                            ),
                            _buildTimelineStep(
                              title: 'Encaminhada ao Parceiro',
                              subtitle: prop.empresa != null
                                  ? 'Vinculada à empresa "${prop.empresa!.nome}"'
                                  : 'Aguardando encaminhamento a um parceiro',
                              isCompleted: step2Done,
                              isLast: false,
                              icon: Icons.business,
                              color: AppColors.statusAnalysis,
                            ),
                            _buildTimelineStep(
                              title: 'Decisão da Proposta',
                              subtitle: step3Subtitle,
                              isCompleted: step3Done,
                              isLast: true,
                              icon: prop.status == 'Recusada'
                                  ? Icons.cancel
                                  : Icons.check_circle,
                              color: prop.status == 'Recusada'
                                  ? AppColors.statusRejected
                                  : AppColors.statusApproved,
                            ),
                          ],
                        ),
                      ),
                    ],
                  );

                  if (isWide) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 3, child: mainContent),
                        const SizedBox(width: 24),
                        Expanded(flex: 2, child: sidebarContent),
                      ],
                    );
                  } else {
                    return Column(
                      children: [
                        mainContent,
                        const SizedBox(height: 24),
                        sidebarContent,
                      ],
                    );
                  }
                },
              ),
            ),
    );
  }
}

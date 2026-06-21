import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../models/proposal.dart';
import '../../models/client.dart';
import '../../models/proposal_type.dart';
import '../../providers/proposal_provider.dart';
import '../../providers/client_provider.dart';
import '../../providers/proposal_type_provider.dart';
import '../../widgets/dynamic_form_field.dart';

class ProposalFormScreen extends StatefulWidget {
  final Proposta? proposal;
  final Cliente? presetClient;

  const ProposalFormScreen({
    super.key,
    this.proposal,
    this.presetClient,
  });

  @override
  State<ProposalFormScreen> createState() => _ProposalFormScreenState();
}

class _ProposalFormScreenState extends State<ProposalFormScreen> {
  final _formKey = GlobalKey<FormState>();

  String? _selectedClientId;
  String _selectedType = 'Imobiliaria';
  String _selectedStatus = 'Pendente';

  final TextEditingController _valorController = TextEditingController();
  final TextEditingController _descricaoController = TextEditingController();

  // Imobiliaria fields
  final TextEditingController _enderecoController = TextEditingController();
  String _tipoImovel = 'Casa';
  final TextEditingController _areaController = TextEditingController();

  // Auto fields
  final TextEditingController _marcaController = TextEditingController();
  final TextEditingController _modeloController = TextEditingController();
  final TextEditingController _anoController = TextEditingController();
  final TextEditingController _placaController = TextEditingController();

  // CompraVenda fields
  final TextEditingController _itensController = TextEditingController();
  final TextEditingController _condicoesController = TextEditingController();

  // Dynamic Custom type values
  final Map<String, dynamic> _customValues = {};

  // Attachments Mock variables
  String _fotoBase64 = '';
  String _anexoBase64 = '';
  String _nomeAnexo = '';

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    // Load presets or existing values
    if (widget.presetClient != null) {
      _selectedClientId = widget.presetClient!.id;
    }

    if (widget.proposal != null) {
      final p = widget.proposal!;
      _selectedClientId = p.clienteId;
      _selectedType = p.tipo;
      _selectedStatus = p.status;
      _valorController.text = p.valor.toString();
      _descricaoController.text = p.descricao ?? '';

      final spec = p.dadosEspecificos;
      _fotoBase64 = spec['foto'] ?? '';
      _anexoBase64 = spec['anexo'] ?? '';
      _nomeAnexo = spec['nome_anexo'] ?? '';

      if (_selectedType == 'Imobiliaria') {
        _enderecoController.text = spec['endereco_imovel'] ?? '';
        _tipoImovel = spec['tipo_imovel'] ?? 'Casa';
        _areaController.text = spec['area_m2']?.toString() ?? '';
      } else if (_selectedType == 'Auto') {
        _marcaController.text = spec['marca'] ?? '';
        _modeloController.text = spec['modelo'] ?? '';
        _anoController.text = spec['ano']?.toString() ?? '';
        _placaController.text = spec['placa'] ?? '';
      } else if (_selectedType == 'CompraVenda') {
        _itensController.text = spec['itens'] ?? '';
        _condicoesController.text = spec['condicoes_pagamento'] ?? '';
      } else {
        _customValues.addAll(spec);
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ClientProvider>(context, listen: false).fetchClients();
      Provider.of<ProposalTypeProvider>(context, listen: false)
          .fetchProposalTypes();
    });
  }

  @override
  void dispose() {
    _valorController.dispose();
    _descricaoController.dispose();
    _enderecoController.dispose();
    _areaController.dispose();
    _marcaController.dispose();
    _modeloController.dispose();
    _anoController.dispose();
    _placaController.dispose();
    _itensController.dispose();
    _condicoesController.dispose();
    super.dispose();
  }

  Future<void> _saveForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedClientId == null) {
      setState(() {
        _errorMessage = 'Selecione um cliente para vincular a proposta.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final proposalProvider =
        Provider.of<ProposalProvider>(context, listen: false);

    // Build specific data maps
    Map<String, dynamic> filteredDados = {};
    filteredDados['foto'] = _fotoBase64;

    if (_selectedType == 'Imobiliaria') {
      filteredDados['endereco_imovel'] = _enderecoController.text.trim();
      filteredDados['tipo_imovel'] = _tipoImovel;
      filteredDados['area_m2'] = double.tryParse(_areaController.text) ?? 0.0;
    } else if (_selectedType == 'Auto') {
      filteredDados['marca'] = _marcaController.text.trim();
      filteredDados['modelo'] = _modeloController.text.trim();
      filteredDados['ano'] = int.tryParse(_anoController.text) ?? 0;
      filteredDados['placa'] = _placaController.text.trim();
    } else if (_selectedType == 'CompraVenda') {
      filteredDados['itens'] = _itensController.text.trim();
      filteredDados['condicoes_pagamento'] = _condicoesController.text.trim();
      filteredDados['anexo'] = _anexoBase64;
      filteredDados['nome_anexo'] = _nomeAnexo;
    } else {
      filteredDados.addAll(_customValues);
    }

    final proposalData = Proposta(
      id: widget.proposal?.id,
      clienteId: _selectedClientId!,
      tipo: _selectedType,
      valor: double.tryParse(_valorController.text) ?? 0.0,
      status: _selectedStatus,
      descricao: _descricaoController.text.trim().isEmpty
          ? null
          : _descricaoController.text.trim(),
      dadosEspecificos: filteredDados,
      empresaId: widget.proposal?.empresaId,
      statusCorretagem: widget.proposal?.statusCorretagem,
      valorComissao: widget.proposal?.valorComissao,
    );

    bool success;
    if (widget.proposal != null) {
      success = await proposalProvider.updateProposal(
          widget.proposal!.id!, proposalData);
    } else {
      success = await proposalProvider.createProposal(proposalData);
    }

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(widget.proposal != null
                ? 'Proposta atualizada com sucesso!'
                : 'Proposta cadastrada com sucesso!')),
      );
      Navigator.of(context).pop(true);
    } else {
      setState(() {
        _errorMessage = proposalProvider.errorMessage ??
            'Ocorreu um erro ao salvar a proposta.';
      });
    }
  }

  // Mock adding photo
  void _mockAddPhoto() {
    setState(() {
      _fotoBase64 =
          'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAUAAAAFCAYAAACNbyblAAAAHElEQVQI12P4//8/w38GIAXDIBKE0DHxgljNBAAO9TXL0Y4OHwAAAABJRU5ErkJggg==';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Foto anexada com sucesso (Mock).')),
    );
  }

  // Mock adding attachment
  void _mockAddAttachment() {
    setState(() {
      _anexoBase64 = 'data:application/pdf;base64,JVBERi0xLjQKJcfsj6y...';
      _nomeAnexo = 'documento_comercial.pdf';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Documento PDF anexado com sucesso (Mock).')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEdit = widget.proposal != null;

    final clientProvider = Provider.of<ClientProvider>(context);
    final propTypeProvider = Provider.of<ProposalTypeProvider>(context);

    // Find custom dynamic fields if selecting custom type
    TipoProposta? foundCustomType;
    if (_selectedType != 'Imobiliaria' &&
        _selectedType != 'Auto' &&
        _selectedType != 'CompraVenda') {
      try {
        foundCustomType = propTypeProvider.proposalTypes
            .firstWhere((e) => e.chave == _selectedType);
      } catch (_) {}
    }

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: AppStyles.inputRadius),
      backgroundColor: isDark ? AppColors.cardDark : AppColors.cardLight,
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 650),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isEdit
                          ? 'Editar Proposta Comercial'
                          : 'Nova Proposta Comercial',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    )
                  ],
                ),
                const Divider(),
                const SizedBox(height: 16),

                if (_errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.statusRejected.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color:
                              AppColors.statusRejected.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(
                          color: Colors.redAccent, fontSize: 13),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Client selector dropdown
                DropdownButtonFormField<String>(
                  initialValue: _selectedClientId,
                  decoration: InputDecoration(
                    labelText: 'Selecione o Cliente *',
                    prefixIcon: const Icon(Icons.person_outline),
                    border:
                        OutlineInputBorder(borderRadius: AppStyles.inputRadius),
                  ),
                  items: clientProvider.clients
                      .map((c) =>
                          DropdownMenuItem(value: c.id, child: Text(c.nome)))
                      .toList(),
                  onChanged: isEdit
                      ? null
                      : (val) {
                          setState(() {
                            _selectedClientId = val;
                          });
                        },
                  validator: (value) =>
                      value == null ? 'Selecione um cliente' : null,
                ),
                const SizedBox(height: 16),

                // Proposal type selector dropdown
                DropdownButtonFormField<String>(
                  initialValue: _selectedType,
                  decoration: InputDecoration(
                    labelText: 'Tipo de Proposta *',
                    prefixIcon: const Icon(Icons.class_outlined),
                    border:
                        OutlineInputBorder(borderRadius: AppStyles.inputRadius),
                  ),
                  items: [
                    const DropdownMenuItem(
                        value: 'Imobiliaria', child: Text('Imobiliária')),
                    const DropdownMenuItem(
                        value: 'Auto', child: Text('Automotiva')),
                    const DropdownMenuItem(
                        value: 'CompraVenda',
                        child: Text('Compra e Venda Diversas')),
                    ...propTypeProvider.proposalTypes.map((t) =>
                        DropdownMenuItem(value: t.chave, child: Text(t.nome))),
                  ],
                  onChanged: isEdit
                      ? null
                      : (val) {
                          setState(() {
                            _selectedType = val ?? 'Imobiliaria';
                          });
                        },
                ),
                const SizedBox(height: 16),

                // Valor financeiro
                TextFormField(
                  controller: _valorController,
                  decoration: InputDecoration(
                    labelText: 'Valor da Proposta *',
                    prefixIcon: const Icon(Icons.monetization_on_outlined),
                    hintText: '0.00',
                    border:
                        OutlineInputBorder(borderRadius: AppStyles.inputRadius),
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'O valor é obrigatório';
                    }
                    final parsed = double.tryParse(value);
                    if (parsed == null || parsed <= 0.0) {
                      return 'O valor deve ser maior que zero';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Status dropdown
                DropdownButtonFormField<String>(
                  initialValue: _selectedStatus,
                  decoration: InputDecoration(
                    labelText: 'Status da Proposta *',
                    prefixIcon: const Icon(Icons.info_outline),
                    border:
                        OutlineInputBorder(borderRadius: AppStyles.inputRadius),
                  ),
                  items: const [
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
                      _selectedStatus = val ?? 'Pendente';
                    });
                  },
                ),
                const SizedBox(height: 16),

                // Descrição geral
                TextFormField(
                  controller: _descricaoController,
                  decoration: InputDecoration(
                    labelText: 'Descrição / Observações',
                    prefixIcon: const Icon(Icons.note_alt_outlined),
                    border:
                        OutlineInputBorder(borderRadius: AppStyles.inputRadius),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 24),

                const Text('Dados Específicos do Tipo',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryLight)),
                const SizedBox(height: 8),
                const Divider(),
                const SizedBox(height: 12),

                // Rendering specific fields based on chosen type
                if (_selectedType == 'Imobiliaria') ...[
                  // Endereco do imovel
                  TextFormField(
                    controller: _enderecoController,
                    decoration: InputDecoration(
                      labelText: 'Endereço do Imóvel *',
                      border: OutlineInputBorder(
                          borderRadius: AppStyles.inputRadius),
                    ),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Endereço é obrigatório'
                        : null,
                  ),
                  const SizedBox(height: 16),

                  // Tipo do imovel dropdown
                  DropdownButtonFormField<String>(
                    initialValue: _tipoImovel,
                    decoration: InputDecoration(
                      labelText: 'Tipo do Imóvel *',
                      border: OutlineInputBorder(
                          borderRadius: AppStyles.inputRadius),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Casa', child: Text('Casa')),
                      DropdownMenuItem(
                          value: 'Apartamento', child: Text('Apartamento')),
                      DropdownMenuItem(
                          value: 'Comercial', child: Text('Comercial')),
                      DropdownMenuItem(
                          value: 'Terreno', child: Text('Terreno')),
                    ],
                    onChanged: (val) =>
                        setState(() => _tipoImovel = val ?? 'Casa'),
                  ),
                  const SizedBox(height: 16),

                  // Area m2
                  TextFormField(
                    controller: _areaController,
                    decoration: InputDecoration(
                      labelText: 'Área Privativa (m²) *',
                      border: OutlineInputBorder(
                          borderRadius: AppStyles.inputRadius),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Área é obrigatória';
                      }
                      if (double.tryParse(value) == null ||
                          double.parse(value) <= 0) {
                        return 'Insira uma área válida';
                      }
                      return null;
                    },
                  ),
                ] else if (_selectedType == 'Auto') ...[
                  // Marca
                  TextFormField(
                    controller: _marcaController,
                    decoration: InputDecoration(
                      labelText: 'Marca *',
                      border: OutlineInputBorder(
                          borderRadius: AppStyles.inputRadius),
                    ),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Marca é obrigatória'
                        : null,
                  ),
                  const SizedBox(height: 16),

                  // Modelo
                  TextFormField(
                    controller: _modeloController,
                    decoration: InputDecoration(
                      labelText: 'Modelo *',
                      border: OutlineInputBorder(
                          borderRadius: AppStyles.inputRadius),
                    ),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Modelo é obrigatório'
                        : null,
                  ),
                  const SizedBox(height: 16),

                  // Ano Fabricacao
                  TextFormField(
                    controller: _anoController,
                    decoration: InputDecoration(
                      labelText: 'Ano de Fabricação *',
                      border: OutlineInputBorder(
                          borderRadius: AppStyles.inputRadius),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Ano é obrigatório';
                      }
                      final parsed = int.tryParse(value);
                      if (parsed == null || parsed < 1900) {
                        return 'Insira um ano válido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Placa
                  TextFormField(
                    controller: _placaController,
                    decoration: InputDecoration(
                      labelText: 'Placa do Veículo *',
                      border: OutlineInputBorder(
                          borderRadius: AppStyles.inputRadius),
                    ),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Placa é obrigatória'
                        : null,
                  ),
                ] else if (_selectedType == 'CompraVenda') ...[
                  // Descricao dos itens
                  TextFormField(
                    controller: _itensController,
                    decoration: InputDecoration(
                      labelText: 'Descrição dos Itens *',
                      border: OutlineInputBorder(
                          borderRadius: AppStyles.inputRadius),
                    ),
                    maxLines: 2,
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Descrição de itens é obrigatória'
                        : null,
                  ),
                  const SizedBox(height: 16),

                  // Condicoes de pagamento
                  TextFormField(
                    controller: _condicoesController,
                    decoration: InputDecoration(
                      labelText: 'Condições de Pagamento *',
                      border: OutlineInputBorder(
                          borderRadius: AppStyles.inputRadius),
                    ),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Condições são obrigatórias'
                        : null,
                  ),
                ] else if (foundCustomType != null) ...[
                  // Dynamic fields rendering
                  ...foundCustomType.campos.map((campo) {
                    return DynamicFormField(
                      field: campo,
                      initialValue: _customValues[campo.chave],
                      onChanged: (val) {
                        _customValues[campo.chave] = val;
                      },
                    );
                  }),
                ],
                const SizedBox(height: 20),

                // Photos & Document Attachments Mock Section
                const Text('Anexos e Fotos',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: _mockAddPhoto,
                      icon: const Icon(Icons.camera_alt_outlined),
                      label: Text(_fotoBase64.isNotEmpty
                          ? 'Foto Anexada'
                          : 'Adicionar Foto'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _fotoBase64.isNotEmpty
                            ? AppColors.statusApproved
                            : Colors.grey,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: _mockAddAttachment,
                      icon: const Icon(Icons.attach_file_outlined),
                      label: Text(_nomeAnexo.isNotEmpty
                          ? _nomeAnexo
                          : 'Adicionar Anexo'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _anexoBase64.isNotEmpty
                            ? AppColors.statusApproved
                            : Colors.grey,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Save buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed:
                          _isLoading ? null : () => Navigator.of(context).pop(),
                      child: const Text('Cancelar'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _saveForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: AppStyles.buttonRadius),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2),
                            )
                          : Text(isEdit ? 'Atualizar' : 'Salvar Proposta'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

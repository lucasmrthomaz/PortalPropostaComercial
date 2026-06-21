import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../models/client.dart';
import '../../providers/client_provider.dart';

class ClientFormScreen extends StatefulWidget {
  final Cliente? client;

  const ClientFormScreen({super.key, this.client});

  @override
  State<ClientFormScreen> createState() => _ClientFormScreenState();
}

class _ClientFormScreenState extends State<ClientFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nomeController;
  late TextEditingController _cpfCnpjController;
  late TextEditingController _emailController;
  late TextEditingController _telefoneController;
  late TextEditingController _enderecoController;

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController(text: widget.client?.nome ?? '');
    _cpfCnpjController =
        TextEditingController(text: widget.client?.cpfCnpj ?? '');
    _emailController = TextEditingController(text: widget.client?.email ?? '');
    _telefoneController =
        TextEditingController(text: widget.client?.telefone ?? '');
    _enderecoController =
        TextEditingController(text: widget.client?.endereco ?? '');
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _cpfCnpjController.dispose();
    _emailController.dispose();
    _telefoneController.dispose();
    _enderecoController.dispose();
    super.dispose();
  }

  Future<void> _saveForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final clientProvider = Provider.of<ClientProvider>(context, listen: false);

    final cleanCpfCnpj = Cliente.cleanCPFCNPJ(_cpfCnpjController.text);

    final clientData = Cliente(
      id: widget.client?.id,
      nome: _nomeController.text.trim(),
      cpfCnpj: cleanCpfCnpj,
      email: _emailController.text.trim(),
      telefone: _telefoneController.text.trim().isEmpty
          ? null
          : _telefoneController.text.trim(),
      endereco: _enderecoController.text.trim().isEmpty
          ? null
          : _enderecoController.text.trim(),
    );

    bool success;
    if (widget.client != null) {
      success =
          await clientProvider.updateClient(widget.client!.id!, clientData);
    } else {
      success = await clientProvider.createClient(clientData);
    }

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(widget.client != null
                ? 'Cliente atualizado com sucesso!'
                : 'Cliente cadastrado com sucesso!')),
      );
      Navigator.of(context).pop(true);
    } else {
      setState(() {
        _errorMessage = clientProvider.errorMessage ??
            'Ocorreu um erro ao salvar o cliente.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEdit = widget.client != null;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: AppStyles.inputRadius),
      backgroundColor: isDark ? AppColors.cardDark : AppColors.cardLight,
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 550),
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
                      isEdit ? 'Editar Cliente' : 'Novo Cliente',
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

                // Nome Completo
                TextFormField(
                  controller: _nomeController,
                  decoration: InputDecoration(
                    labelText: 'Nome Completo *',
                    prefixIcon: const Icon(Icons.person_outline),
                    border:
                        OutlineInputBorder(borderRadius: AppStyles.inputRadius),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'O nome completo é obrigatório';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // CPF ou CNPJ
                TextFormField(
                  controller: _cpfCnpjController,
                  decoration: InputDecoration(
                    labelText: 'CPF ou CNPJ *',
                    prefixIcon: const Icon(Icons.badge_outlined),
                    helperText:
                        'Apenas números (ex: 12345678901 ou 12345678000195)',
                    border:
                        OutlineInputBorder(borderRadius: AppStyles.inputRadius),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'O CPF ou CNPJ é obrigatório';
                    }
                    final cleaned = Cliente.cleanCPFCNPJ(value);
                    if (!Cliente.isValidCPFCNPJ(cleaned)) {
                      return 'Formato de CPF ou CNPJ inválido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // E-mail
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'E-mail *',
                    prefixIcon: const Icon(Icons.email_outlined),
                    border:
                        OutlineInputBorder(borderRadius: AppStyles.inputRadius),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'O e-mail é obrigatório';
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return 'Insira um e-mail válido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Telefone
                TextFormField(
                  controller: _telefoneController,
                  decoration: InputDecoration(
                    labelText: 'Telefone',
                    prefixIcon: const Icon(Icons.phone_outlined),
                    hintText: '(11) 99999-9999',
                    border:
                        OutlineInputBorder(borderRadius: AppStyles.inputRadius),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),

                // Endereço completo
                TextFormField(
                  controller: _enderecoController,
                  decoration: InputDecoration(
                    labelText: 'Endereço Completo',
                    prefixIcon: const Icon(Icons.home_outlined),
                    border:
                        OutlineInputBorder(borderRadius: AppStyles.inputRadius),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 24),

                // Actions Buttons
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
                          : Text(isEdit ? 'Atualizar' : 'Cadastrar'),
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

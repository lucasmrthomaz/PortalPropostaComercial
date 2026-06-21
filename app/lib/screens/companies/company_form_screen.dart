import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../models/company.dart';
import '../../providers/company_provider.dart';

class CompanyFormScreen extends StatefulWidget {
  final Empresa? company;

  const CompanyFormScreen({super.key, this.company});

  @override
  State<CompanyFormScreen> createState() => _CompanyFormScreenState();
}

class _CompanyFormScreenState extends State<CompanyFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nomeController;
  late TextEditingController _cnpjController;
  late TextEditingController _emailController;
  late TextEditingController _telefoneController;
  late TextEditingController _respNomeController;
  late TextEditingController _respEmailController;
  late TextEditingController _respTelefoneController;

  bool _ativo = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController(text: widget.company?.nome ?? '');
    _cnpjController = TextEditingController(text: widget.company?.cnpj ?? '');
    _emailController = TextEditingController(text: widget.company?.email ?? '');
    _telefoneController =
        TextEditingController(text: widget.company?.telefone ?? '');
    _respNomeController =
        TextEditingController(text: widget.company?.responsavelNome ?? '');
    _respEmailController =
        TextEditingController(text: widget.company?.responsavelEmail ?? '');
    _respTelefoneController =
        TextEditingController(text: widget.company?.responsavelTelefone ?? '');
    _ativo = widget.company?.ativo ?? true;
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _cnpjController.dispose();
    _emailController.dispose();
    _telefoneController.dispose();
    _respNomeController.dispose();
    _respEmailController.dispose();
    _respTelefoneController.dispose();
    super.dispose();
  }

  Future<void> _saveForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final companyProvider =
        Provider.of<CompanyProvider>(context, listen: false);

    // CNPJ basic sanitization
    final cleanCnpj = _cnpjController.text.replaceAll(RegExp(r'[^0-9]'), '');

    final companyData = Empresa(
      id: widget.company?.id,
      nome: _nomeController.text.trim(),
      cnpj: cleanCnpj,
      email: _emailController.text.trim(),
      telefone: _telefoneController.text.trim().isEmpty
          ? null
          : _telefoneController.text.trim(),
      responsavelNome: _respNomeController.text.trim().isEmpty
          ? null
          : _respNomeController.text.trim(),
      responsavelEmail: _respEmailController.text.trim().isEmpty
          ? null
          : _respEmailController.text.trim(),
      responsavelTelefone: _respTelefoneController.text.trim().isEmpty
          ? null
          : _respTelefoneController.text.trim(),
      ativo: _ativo,
    );

    bool success;
    if (widget.company != null) {
      success =
          await companyProvider.updateCompany(widget.company!.id!, companyData);
    } else {
      success = await companyProvider.createCompany(companyData);
    }

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(widget.company != null
                ? 'Empresa parceira atualizada!'
                : 'Empresa parceira cadastrada!')),
      );
      Navigator.of(context).pop(true);
    } else {
      setState(() {
        _errorMessage =
            companyProvider.errorMessage ?? 'Ocorreu um erro ao salvar.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEdit = widget.company != null;

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
                      isEdit
                          ? 'Editar Empresa Parceira'
                          : 'Nova Empresa Parceira',
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

                // Empresa Name
                TextFormField(
                  controller: _nomeController,
                  decoration: InputDecoration(
                    labelText: 'Razão Social / Nome Fantasia *',
                    prefixIcon: const Icon(Icons.business),
                    border:
                        OutlineInputBorder(borderRadius: AppStyles.inputRadius),
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Nome da empresa é obrigatório'
                      : null,
                ),
                const SizedBox(height: 16),

                // CNPJ
                TextFormField(
                  controller: _cnpjController,
                  decoration: InputDecoration(
                    labelText: 'CNPJ *',
                    prefixIcon: const Icon(Icons.badge_outlined),
                    border:
                        OutlineInputBorder(borderRadius: AppStyles.inputRadius),
                    helperText: 'Apenas números (ex: 12345678000195)',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'CNPJ é obrigatório';
                    }
                    final cleaned = value.replaceAll(RegExp(r'[^0-9]'), '');
                    if (cleaned.length != 14) {
                      return 'CNPJ deve conter exatamente 14 dígitos';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // E-mail da Empresa
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'E-mail Comercial *',
                    prefixIcon: const Icon(Icons.email_outlined),
                    border:
                        OutlineInputBorder(borderRadius: AppStyles.inputRadius),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'E-mail é obrigatório';
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return 'Insira um e-mail válido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Telefone da Empresa
                TextFormField(
                  controller: _telefoneController,
                  decoration: InputDecoration(
                    labelText: 'Telefone Comercial',
                    prefixIcon: const Icon(Icons.phone_outlined),
                    border:
                        OutlineInputBorder(borderRadius: AppStyles.inputRadius),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 24),

                const Text('Representante Responsável',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryLight)),
                const SizedBox(height: 8),
                const Divider(),
                const SizedBox(height: 12),

                // Representante Name
                TextFormField(
                  controller: _respNomeController,
                  decoration: InputDecoration(
                    labelText: 'Nome do Representante',
                    prefixIcon: const Icon(Icons.person_outline),
                    border:
                        OutlineInputBorder(borderRadius: AppStyles.inputRadius),
                  ),
                ),
                const SizedBox(height: 16),

                // Representante Email
                TextFormField(
                  controller: _respEmailController,
                  decoration: InputDecoration(
                    labelText: 'E-mail do Representante',
                    prefixIcon: const Icon(Icons.mail_outline),
                    border:
                        OutlineInputBorder(borderRadius: AppStyles.inputRadius),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),

                // Representante Telefone
                TextFormField(
                  controller: _respTelefoneController,
                  decoration: InputDecoration(
                    labelText: 'Telefone do Representante',
                    prefixIcon: const Icon(Icons.phone_android_outlined),
                    border:
                        OutlineInputBorder(borderRadius: AppStyles.inputRadius),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),

                // Active toggle switch
                SwitchListTile(
                  title: const Text('Empresa Ativa'),
                  subtitle: const Text(
                      'Permite vincular novas propostas de corretagem'),
                  value: _ativo,
                  onChanged: (val) {
                    setState(() {
                      _ativo = val;
                    });
                  },
                  activeThumbColor: AppColors.primary,
                  contentPadding: EdgeInsets.zero,
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

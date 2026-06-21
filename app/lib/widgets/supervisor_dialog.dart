import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants.dart';
import '../models/analysis_request.dart';
import '../providers/settings_provider.dart';
import '../providers/supervisor_provider.dart';

class SupervisorDialog extends StatefulWidget {
  final String title;
  final String description;
  final PedidoAnalise pedido;

  const SupervisorDialog({
    super.key,
    required this.title,
    required this.description,
    required this.pedido,
  });

  @override
  State<SupervisorDialog> createState() => _SupervisorDialogState();
}

class _SupervisorDialogState extends State<SupervisorDialog> {
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorText;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _verifyAndPasswordApprove() async {
    final pwd = _passwordController.text.trim();
    if (pwd.isEmpty) {
      setState(() {
        _errorText = 'A senha é obrigatória';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    final isValid = await settingsProvider.verifySupervisorPassword(pwd);

    if (!mounted) return;

    if (isValid) {
      Navigator.of(context).pop({'confirmed': true, 'passwordUsed': true, 'password': pwd});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Senha do supervisor confirmada!')),
      );
    } else {
      setState(() {
        _isLoading = false;
        _errorText = 'Senha do supervisor inválida!';
      });
    }
  }

  Future<void> _submitForAnalysis() async {
    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    final supervisorProvider = Provider.of<SupervisorProvider>(context, listen: false);
    final success = await supervisorProvider.createRequest(widget.pedido);

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (success) {
      Navigator.of(context).pop({'submitted': true});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Solicitação enviada para a análise do Supervisor!')),
      );
    } else {
      setState(() {
        _errorText = supervisorProvider.errorMessage ?? 'Erro ao enviar para análise.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: AppStyles.inputRadius),
      backgroundColor: isDark ? AppColors.cardDark : AppColors.cardLight,
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 500),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.security, color: AppColors.statusPending, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.title,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              widget.description,
              style: TextStyle(
                color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            const Text(
              'Opção 1: Liberação Imediata',
              style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.secondary),
            ),
            const SizedBox(height: 8),
            Text(
              'Digite a senha do supervisor para aprovar esta ação imediatamente.',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                hintText: 'Senha do Supervisor',
                errorText: _errorText,
                prefixIcon: const Icon(Icons.lock_outline),
                border: OutlineInputBorder(borderRadius: AppStyles.inputRadius),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _verifyAndPasswordApprove,
              icon: _isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.check_circle_outline),
              label: const Text('Autorizar Imediatamente'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: AppStyles.buttonRadius),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                const Expanded(child: Divider()),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    'OU',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                    ),
                  ),
                ),
                const Expanded(child: Divider()),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Opção 2: Solicitar Análise',
              style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.accent),
            ),
            const SizedBox(height: 8),
            Text(
              'Se você não possui a senha, envie esta ação para a fila de solicitações do supervisor.',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _isLoading ? null : _submitForAnalysis,
              icon: const Icon(Icons.send_outlined),
              label: const Text('Solicitar Liberação ao Supervisor'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.accent,
                side: const BorderSide(color: AppColors.accent),
                shape: RoundedRectangleBorder(borderRadius: AppStyles.buttonRadius),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                child: const Text('Cancelar'),
              ),
            )
          ],
        ),
      ),
    );
  }
}

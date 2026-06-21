import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../providers/company_provider.dart';
import '../../models/company.dart';
import 'company_form_screen.dart';

class CompanyListScreen extends StatefulWidget {
  const CompanyListScreen({super.key});

  @override
  State<CompanyListScreen> createState() => _CompanyListScreenState();
}

class _CompanyListScreenState extends State<CompanyListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CompanyProvider>(context, listen: false).fetchCompanies();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openCompanyForm([Empresa? company]) {
    showDialog(
      context: context,
      builder: (_) => CompanyFormScreen(company: company),
    );
  }

  void _toggleCompanyActive(Empresa company, bool isActive) {
    final companyProvider =
        Provider.of<CompanyProvider>(context, listen: false);
    final updated = Empresa(
      id: company.id,
      nome: company.nome,
      cnpj: company.cnpj,
      email: company.email,
      telefone: company.telefone,
      responsavelNome: company.responsavelNome,
      responsavelEmail: company.responsavelEmail,
      responsavelTelefone: company.responsavelTelefone,
      ativo: isActive,
    );

    companyProvider.updateCompany(company.id!, updated).then((success) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Empresa ${isActive ? "ativada" : "desativada"} com sucesso.')),
        );
      }
    });
  }

  void _deleteCompany(Empresa company) {
    final companyProvider =
        Provider.of<CompanyProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Excluir Empresa Parceira'),
          content: Text(
              'Deseja realmente excluir permanentemente a empresa "${company.nome}"?'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar')),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                companyProvider.deleteCompany(company.id!).then((success) {
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Empresa excluída com sucesso.')),
                    );
                  }
                });
              },
              child: const Text('Excluir',
                  style: TextStyle(color: Colors.redAccent)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final companyProvider = Provider.of<CompanyProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final filteredCompanies = companyProvider.companies.where((e) {
      final q = _searchQuery.toLowerCase();
      return e.nome.toLowerCase().contains(q) ||
          e.cnpj.toLowerCase().contains(q) ||
          e.email.toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Empresas Parceiras',
                        style: GoogleFonts.outfit(
                            fontSize: 26, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Gerenciamento de corretoras e convênios para repasse de comissões',
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
                  onPressed: () => _openCompanyForm(),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Nova Empresa'),
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

            // Search filter input
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
                  hintText: 'Pesquise por nome, CNPJ, e-mail...',
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Companies grid or list
            Expanded(
              child: companyProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filteredCompanies.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.business_outlined,
                                  size: 64,
                                  color: Colors.grey.withValues(alpha: 0.5)),
                              const SizedBox(height: 16),
                              const Text('Nenhuma empresa parceira cadastrada.',
                                  style: TextStyle(color: Colors.grey)),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: filteredCompanies.length,
                          itemBuilder: (context, index) {
                            final comp = filteredCompanies[index];

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
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8.0, horizontal: 4.0),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: AppColors.accent
                                        .withValues(alpha: 0.12),
                                    foregroundColor: AppColors.accent,
                                    child: const Icon(Icons.business),
                                  ),
                                  title: Text(comp.nome,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  subtitle: Text(
                                    'CNPJ: ${comp.cnpj} • Responsável: ${comp.responsavelNome ?? "Não informado"}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Switch(
                                        value: comp.ativo,
                                        activeThumbColor:
                                            AppColors.statusApproved,
                                        onChanged: (val) =>
                                            _toggleCompanyActive(comp, val),
                                      ),
                                      PopupMenuButton<String>(
                                        onSelected: (val) {
                                          if (val == 'edit') {
                                            _openCompanyForm(comp);
                                          } else if (val == 'delete') {
                                            _deleteCompany(comp);
                                          }
                                        },
                                        itemBuilder: (context) => [
                                          const PopupMenuItem(
                                            value: 'edit',
                                            child: ListTile(
                                              leading:
                                                  Icon(Icons.edit_outlined),
                                              title: Text('Editar Cadastro'),
                                            ),
                                          ),
                                          const PopupMenuItem(
                                            value: 'delete',
                                            child: ListTile(
                                              leading: Icon(
                                                  Icons.delete_outline,
                                                  color: Colors.redAccent),
                                              title: Text('Excluir Empresa',
                                                  style: TextStyle(
                                                      color: Colors.redAccent)),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
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

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../providers/settings_provider.dart';
import '../../providers/proposal_type_provider.dart';
import '../../providers/user_management_provider.dart';
import '../../models/proposal_type.dart';
import '../../models/user.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Parametros Controllers
  final TextEditingController _rateController = TextEditingController();
  final TextEditingController _supPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAllSettings();
    });
  }

  Future<void> _loadAllSettings() async {
    final settingsProv = Provider.of<SettingsProvider>(context, listen: false);
    final propTypeProv =
        Provider.of<ProposalTypeProvider>(context, listen: false);
    final userManProv =
        Provider.of<UserManagementProvider>(context, listen: false);

    await Future.wait([
      settingsProv.fetchSettings(),
      propTypeProv.fetchProposalTypes(),
      userManProv.fetchUsers(),
      userManProv.fetchProfiles(),
    ]);

    _rateController.text = settingsProv.commissionRate.toString();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _rateController.dispose();
    _supPasswordController.dispose();
    super.dispose();
  }

  // --- PARAMETROS SAVE ACTIONS ---
  Future<void> _saveCommissionRate() async {
    final val = double.tryParse(_rateController.text);
    if (val == null || val < 0.0) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Insira uma taxa de comissão válida.')));
      return;
    }
    final success = await Provider.of<SettingsProvider>(context, listen: false)
        .updateCommissionRate(val);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Taxa de corretagem atualizada!')));
    }
  }

  Future<void> _saveSupervisorPassword() async {
    final pwd = _supPasswordController.text;
    if (pwd.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('A senha do supervisor não pode ser vazia.')));
      return;
    }
    final success = await Provider.of<SettingsProvider>(context, listen: false)
        .updateSupervisorPassword(pwd);
    if (success && mounted) {
      _supPasswordController.clear();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Senha do supervisor alterada com sucesso!')));
    }
  }

  // --- PROPOSAL TYPE BUILDER ACTIONS ---
  void _openProposalTypeBuilder() {
    final TextEditingController typeNameCtrl = TextEditingController();
    final TextEditingController typeKeyCtrl = TextEditingController();
    final List<CampoTipoProposta> dynamicFields = [];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Novo Tipo de Proposta'),
              content: SizedBox(
                width: 450,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: typeNameCtrl,
                        decoration: const InputDecoration(
                            labelText:
                                'Nome do Tipo (ex: Consórcio Imobiliário)'),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: typeKeyCtrl,
                        decoration: const InputDecoration(
                            labelText:
                                'Chave Identificadora (ex: ConsorcioImovel)'),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Campos do Formulário',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          TextButton.icon(
                            onPressed: () {
                              setDialogState(() {
                                dynamicFields.add(CampoTipoProposta(
                                  nome: 'Novo Campo',
                                  chave: 'novo_campo_${dynamicFields.length}',
                                  tipo: 'text',
                                  obrigatorio: false,
                                ));
                              });
                            },
                            icon: const Icon(Icons.add, size: 16),
                            label: const Text('Add Campo'),
                          ),
                        ],
                      ),
                      const Divider(),
                      ...dynamicFields.asMap().entries.map((entry) {
                        final idx = entry.key;
                        final field = entry.value;

                        final TextEditingController fNameCtrl =
                            TextEditingController(text: field.nome);
                        final TextEditingController fKeyCtrl =
                            TextEditingController(text: field.chave);

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller: fNameCtrl,
                                        decoration: const InputDecoration(
                                            labelText: 'Nome do Campo'),
                                        onChanged: (val) => dynamicFields[idx] =
                                            CampoTipoProposta(
                                          nome: val,
                                          chave: dynamicFields[idx].chave,
                                          tipo: dynamicFields[idx].tipo,
                                          obrigatorio:
                                              dynamicFields[idx].obrigatorio,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: TextField(
                                        controller: fKeyCtrl,
                                        decoration: const InputDecoration(
                                            labelText: 'Chave (JSON)'),
                                        onChanged: (val) => dynamicFields[idx] =
                                            CampoTipoProposta(
                                          nome: dynamicFields[idx].nome,
                                          chave: val,
                                          tipo: dynamicFields[idx].tipo,
                                          obrigatorio:
                                              dynamicFields[idx].obrigatorio,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete,
                                          color: Colors.redAccent),
                                      onPressed: () {
                                        setDialogState(() {
                                          dynamicFields.removeAt(idx);
                                        });
                                      },
                                    )
                                  ],
                                ),
                                Row(
                                  children: [
                                    DropdownButton<String>(
                                      value: field.tipo,
                                      items: const [
                                        DropdownMenuItem(
                                            value: 'text',
                                            child: Text('Texto')),
                                        DropdownMenuItem(
                                            value: 'number',
                                            child: Text('Número')),
                                        DropdownMenuItem(
                                            value: 'boolean',
                                            child: Text('Booleano')),
                                      ],
                                      onChanged: (val) {
                                        setDialogState(() {
                                          dynamicFields[idx] =
                                              CampoTipoProposta(
                                            nome: dynamicFields[idx].nome,
                                            chave: dynamicFields[idx].chave,
                                            tipo: val ?? 'text',
                                            obrigatorio:
                                                dynamicFields[idx].obrigatorio,
                                          );
                                        });
                                      },
                                    ),
                                    const SizedBox(width: 16),
                                    Checkbox(
                                      value: field.obrigatorio,
                                      onChanged: (val) {
                                        setDialogState(() {
                                          dynamicFields[idx] =
                                              CampoTipoProposta(
                                            nome: dynamicFields[idx].nome,
                                            chave: dynamicFields[idx].chave,
                                            tipo: dynamicFields[idx].tipo,
                                            obrigatorio: val ?? false,
                                          );
                                        });
                                      },
                                    ),
                                    const Text('Obrigatório',
                                        style: TextStyle(fontSize: 12)),
                                  ],
                                )
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancelar')),
                TextButton(
                  onPressed: () {
                    final newType = TipoProposta(
                      nome: typeNameCtrl.text.trim(),
                      chave: typeKeyCtrl.text.trim(),
                      campos: dynamicFields,
                    );
                    Provider.of<ProposalTypeProvider>(context, listen: false)
                        .createProposalType(newType)
                        .then((success) {
                      if (success) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Tipo criado!')));
                      }
                    });
                  },
                  child: const Text('Criar Tipo'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // --- USER CREATION ACTIONS ---
  void _openUserForm([Usuario? user]) {
    final TextEditingController nameCtrl =
        TextEditingController(text: user?.nome ?? '');
    final TextEditingController emailCtrl =
        TextEditingController(text: user?.email ?? '');
    final TextEditingController passwordCtrl = TextEditingController();
    String? selectedProfileId = user?.perfilId;
    bool ativo = user?.ativo ?? true;

    final userManProv =
        Provider.of<UserManagementProvider>(context, listen: false);

    if (selectedProfileId == null && userManProv.profiles.isNotEmpty) {
      selectedProfileId = userManProv.profiles.first.id;
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(user != null ? 'Editar Usuário' : 'Novo Usuário'),
              content: SizedBox(
                width: 400,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameCtrl,
                      decoration:
                          const InputDecoration(labelText: 'Nome Completo *'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: emailCtrl,
                      decoration: const InputDecoration(labelText: 'E-mail *'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: passwordCtrl,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: user != null
                            ? 'Nova Senha (opcional)'
                            : 'Senha de Acesso *',
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: selectedProfileId,
                      decoration: const InputDecoration(
                          labelText: 'Perfil de Acesso *'),
                      items: userManProv.profiles
                          .map((p) => DropdownMenuItem(
                              value: p.id, child: Text(p.nome)))
                          .toList(),
                      onChanged: (val) =>
                          setState(() => selectedProfileId = val),
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      title: const Text('Usuário Ativo'),
                      value: ativo,
                      onChanged: (val) => setDialogState(() => ativo = val),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancelar')),
                TextButton(
                  onPressed: () {
                    if (user != null) {
                      userManProv
                          .updateUser(
                              user.id,
                              nameCtrl.text.trim(),
                              emailCtrl.text.trim(),
                              passwordCtrl.text,
                              selectedProfileId!,
                              ativo)
                          .then((success) {
                        if (success) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Usuário atualizado!')));
                        }
                      });
                    } else {
                      userManProv
                          .createUser(
                              nameCtrl.text.trim(),
                              emailCtrl.text.trim(),
                              passwordCtrl.text,
                              selectedProfileId!,
                              ativo)
                          .then((success) {
                        if (success) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Usuário criado!')));
                        }
                      });
                    }
                  },
                  child: const Text('Salvar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // --- ACCESS PROFILE ACTIONS ---
  void _openProfileForm() {
    final TextEditingController nameCtrl = TextEditingController();
    final TextEditingController descCtrl = TextEditingController();
    final List<String> permissions = [];

    final availablePermissions = [
      {'key': '*', 'label': 'Acesso Total (*)'},
      {'key': 'clients.read', 'label': 'Visualizar Clientes'},
      {'key': 'clients.write', 'label': 'Modificar Clientes'},
      {'key': 'proposals.read', 'label': 'Visualizar Propostas'},
      {'key': 'proposals.write', 'label': 'Modificar Propostas'},
      {'key': 'settings.read', 'label': 'Configurações'},
      {'key': 'supervisor.access', 'label': 'Painel do Supervisor'},
    ];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Novo Perfil de Acesso'),
              content: SizedBox(
                width: 420,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: nameCtrl,
                        decoration: const InputDecoration(
                            labelText: 'Nome do Perfil *'),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: descCtrl,
                        decoration:
                            const InputDecoration(labelText: 'Descrição'),
                      ),
                      const SizedBox(height: 20),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Permissões de Segurança',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      const Divider(),
                      ...availablePermissions.map((perm) {
                        final key = perm['key']!;
                        final label = perm['label']!;
                        final isSelected = permissions.contains(key);

                        return CheckboxListTile(
                          title:
                              Text(label, style: const TextStyle(fontSize: 13)),
                          value: isSelected,
                          onChanged: (val) {
                            setDialogState(() {
                              if (val == true) {
                                permissions.add(key);
                              } else {
                                permissions.remove(key);
                              }
                            });
                          },
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                        );
                      }),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancelar')),
                TextButton(
                  onPressed: () {
                    final newProf = Perfil(
                      id: '',
                      nome: nameCtrl.text.trim(),
                      descricao: descCtrl.text.trim(),
                      permissoes: permissions,
                      isSistema: false,
                    );
                    Provider.of<UserManagementProvider>(context, listen: false)
                        .createProfile(newProf)
                        .then((success) {
                      if (success) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Perfil criado!')));
                      }
                    });
                  },
                  child: const Text('Criar Perfil'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final propTypeProv = Provider.of<ProposalTypeProvider>(context);
    final userManProv = Provider.of<UserManagementProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações do Portal'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: isDark ? Colors.white : Colors.black87,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(icon: Icon(Icons.tune), text: 'Parâmetros'),
            Tab(
                icon: Icon(Icons.dynamic_feed_outlined),
                text: 'Tipos Proposta'),
            Tab(icon: Icon(Icons.people_outline), text: 'Usuários'),
            Tab(
                icon: Icon(Icons.admin_panel_settings_outlined),
                text: 'Perfis'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Parametros
          SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Repasse & Taxas',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text('Taxa de Corretagem (%)',
                            style: TextStyle(fontSize: 13, color: Colors.grey)),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _rateController,
                                keyboardType: const TextInputType.numberWithOptions(
                                    decimal: true),
                                decoration: const InputDecoration(
                                    border: OutlineInputBorder()),
                              ),
                            ),
                            const SizedBox(width: 16),
                            ElevatedButton(
                              onPressed: _saveCommissionRate,
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white),
                              child: const Text('Salvar Taxa'),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text('Segurança do Supervisor',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text('Alterar Senha do Supervisor',
                            style: TextStyle(fontSize: 13, color: Colors.grey)),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _supPasswordController,
                                obscureText: true,
                                decoration: const InputDecoration(
                                    hintText: 'Nova senha numérica ou alfa...',
                                    border: OutlineInputBorder()),
                              ),
                            ),
                            const SizedBox(width: 16),
                            ElevatedButton(
                              onPressed: _saveSupervisorPassword,
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white),
                              child: const Text('Alterar Senha'),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),

          // Tab 2: Proposal Types
          SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Tipos Dinâmicos Cadastrados',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    ElevatedButton.icon(
                      onPressed: _openProposalTypeBuilder,
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Novo Tipo'),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                propTypeProv.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: propTypeProv.proposalTypes.length,
                        itemBuilder: (context, index) {
                          final type = propTypeProv.proposalTypes[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              title: Text(type.nome,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                              subtitle: Text(
                                  'Chave API: ${type.chave} • ${type.campos.length} campos customizados'),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete_outline,
                                    color: Colors.redAccent),
                                onPressed: () {
                                  propTypeProv
                                      .deleteProposalType(type.id!)
                                      .then((success) {
                                    if (success) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(const SnackBar(
                                              content: Text(
                                                  'Tipo de proposta excluído.')));
                                    }
                                  });
                                },
                              ),
                            ),
                          );
                        },
                      )
              ],
            ),
          ),

          // Tab 3: Users
          SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Usuários do Sistema',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    ElevatedButton.icon(
                      onPressed: () => _openUserForm(),
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Criar Usuário'),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                userManProv.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: userManProv.users.length,
                        itemBuilder: (context, index) {
                          final u = userManProv.users[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: u.ativo
                                    ? AppColors.statusApproved
                                        .withValues(alpha: 0.1)
                                    : Colors.grey.withValues(alpha: 0.1),
                                child: Icon(Icons.person,
                                    color: u.ativo
                                        ? AppColors.statusApproved
                                        : Colors.grey),
                              ),
                              title: Text(u.nome,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                              subtitle: Text(
                                  '${u.email} • Perfil: ${u.perfil?.nome ?? "N/A"}'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit_outlined),
                                    onPressed: () => _openUserForm(u),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline,
                                        color: Colors.redAccent),
                                    onPressed: () {
                                      userManProv
                                          .deleteUser(u.id)
                                          .then((success) {
                                        if (success) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(const SnackBar(
                                                  content: Text(
                                                      'Usuário excluído.')));
                                        }
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      )
              ],
            ),
          ),

          // Tab 4: Profiles
          SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Perfis de Acesso',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    ElevatedButton.icon(
                      onPressed: _openProfileForm,
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Novo Perfil'),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                userManProv.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: userManProv.profiles.length,
                        itemBuilder: (context, index) {
                          final prof = userManProv.profiles[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              title: Text(prof.nome,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                              subtitle: Text(
                                  '${prof.descricao}\nPermissões: ${prof.permissoes.join(", ")}'),
                              isThreeLine: true,
                              trailing: prof.isSistema
                                  ? const Icon(Icons.lock, color: Colors.grey)
                                  : IconButton(
                                      icon: const Icon(Icons.delete_outline,
                                          color: Colors.redAccent),
                                      onPressed: () {
                                        userManProv
                                            .deleteProfile(prof.id)
                                            .then((success) {
                                          if (success) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(const SnackBar(
                                                    content: Text(
                                                        'Perfil excluído.')));
                                          }
                                        });
                                      },
                                    ),
                            ),
                          );
                        },
                      )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/constants.dart';
import '../providers/auth_provider.dart';
import 'dashboard/dashboard_screen.dart';
import 'clients/client_list_screen.dart';
import 'proposals/proposal_list_screen.dart';
import 'companies/company_list_screen.dart';
import 'supervisor/supervisor_panel_screen.dart';
import 'settings/settings_screen.dart';
import 'login_screen.dart';
import 'clients/client_form_screen.dart';
import 'proposals/proposal_form_screen.dart';
import 'companies/company_form_screen.dart';

class ShellScreen extends StatefulWidget {
  const ShellScreen({super.key});

  @override
  State<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends State<ShellScreen> {
  int _selectedIndex = 0;

  // Track if we need to reload screens when index changes
  final List<Widget> _baseScreens = [
    const DashboardScreen(),
    const ClientListScreen(),
    const ProposalListScreen(),
    const CompanyListScreen(),
  ];

  Widget _getCurrentScreen(bool canSeeSupervisor, bool canSeeSettings) {
    int index = _selectedIndex;
    if (index < 4) {
      return _baseScreens[index];
    } else if (index == 4 && canSeeSupervisor) {
      return const SupervisorPanelScreen();
    } else if (index == 5 && canSeeSettings) {
      return const SettingsScreen();
    } else if (index == 4 && !canSeeSupervisor && canSeeSettings) {
      return const SettingsScreen();
    }
    return const DashboardScreen();
  }

  void _openQuickAction(BuildContext context, String action) {
    if (action == 'client') {
      showDialog(
        context: context,
        builder: (_) => const ClientFormScreen(),
      ).then((val) {
        if (val == true && _selectedIndex == 1) {
          // If on client list, it will refresh due to provider listeners
        }
      });
    } else if (action == 'proposal') {
      showDialog(
        context: context,
        builder: (_) => const ProposalFormScreen(),
      );
    } else if (action == 'company') {
      showDialog(
        context: context,
        builder: (_) => const CompanyFormScreen(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.currentUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bool canSeeSettings =
        auth.isSuperAdmin || auth.hasPermission('settings.read');
    final bool canSeeSupervisor =
        auth.isSuperAdmin || auth.hasPermission('supervisor.access');

    // Calculate user initials
    String initials = '';
    if (user != null && user.nome.isNotEmpty) {
      final parts = user.nome.trim().split(' ');
      if (parts.isNotEmpty) {
        initials = parts.first[0].toUpperCase();
        if (parts.length > 1) {
          initials += parts.last[0].toUpperCase();
        }
      }
    }

    final double width = MediaQuery.of(context).size.width;
    final bool isLargeScreen = width >= 900;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isLargeScreen
              ? 'Sistema de Cadastro & Propostas Comerciais'
              : 'Portal Propostas',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          // Quick actions menu button
          PopupMenuButton<String>(
            icon: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add, color: Colors.white, size: 18),
                  SizedBox(width: 4),
                  Text('Novo',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13)),
                ],
              ),
            ),
            onSelected: (action) => _openQuickAction(context, action),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'client',
                child: ListTile(
                  leading: Icon(Icons.person_add_alt_1_outlined,
                      color: AppColors.primaryLight),
                  title: Text('Novo Cliente'),
                ),
              ),
              const PopupMenuItem(
                value: 'proposal',
                child: ListTile(
                  leading: Icon(Icons.assignment_outlined,
                      color: AppColors.statusPending),
                  title: Text('Nova Proposta'),
                ),
              ),
              if (canSeeSettings)
                const PopupMenuItem(
                  value: 'company',
                  child: ListTile(
                    leading:
                        Icon(Icons.business_outlined, color: Colors.purple),
                    title: Text('Nova Empresa Parceira'),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 8),

          // User dropdown menu
          PopupMenuButton<String>(
            offset: const Offset(0, 48),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppColors.primaryLight,
                    radius: 16,
                    child: Text(
                      initials,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  if (isLargeScreen) ...[
                    const SizedBox(width: 8),
                    Text(user?.nome ?? '',
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w500)),
                    const Icon(Icons.arrow_drop_down, size: 18),
                  ]
                ],
              ),
            ),
            onSelected: (val) {
              if (val == 'logout') {
                auth.logout();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              } else if (val == 'settings') {
                setState(() {
                  _selectedIndex = 5;
                });
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                enabled: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user?.nome ?? '',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary)),
                    Text(user?.email ?? '',
                        style:
                            const TextStyle(fontSize: 11, color: Colors.grey)),
                    const SizedBox(height: 4),
                    Text(user?.perfil?.nome ?? '',
                        style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Colors.amber)),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              if (canSeeSettings)
                const PopupMenuItem(
                  value: 'settings',
                  child: ListTile(
                    leading: Icon(Icons.settings_outlined),
                    title: Text('Configurações'),
                  ),
                ),
              const PopupMenuItem(
                value: 'logout',
                child: ListTile(
                  leading: Icon(Icons.logout_outlined, color: Colors.redAccent),
                  title: Text('Sair do Sistema',
                      style: TextStyle(color: Colors.redAccent)),
                ),
              ),
            ],
          ),
        ],
      ),
      drawer: isLargeScreen
          ? null
          : Drawer(
              child: Column(
                children: [
                  UserAccountsDrawerHeader(
                    accountName: Text(user?.nome ?? ''),
                    accountEmail: Text(user?.email ?? ''),
                    currentAccountPicture: CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Text(initials,
                          style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 20)),
                    ),
                    decoration: const BoxDecoration(
                      gradient: AppColors.premiumGradient,
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.dashboard_outlined),
                    title: const Text('Dashboard'),
                    selected: _selectedIndex == 0,
                    onTap: () {
                      setState(() => _selectedIndex = 0);
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.people_alt_outlined),
                    title: const Text('Clientes'),
                    selected: _selectedIndex == 1,
                    onTap: () {
                      setState(() => _selectedIndex = 1);
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.assignment_outlined),
                    title: const Text('Propostas'),
                    selected: _selectedIndex == 2,
                    onTap: () {
                      setState(() => _selectedIndex = 2);
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.business_outlined),
                    title: const Text('Empresas Parceiras'),
                    selected: _selectedIndex == 3,
                    onTap: () {
                      setState(() => _selectedIndex = 3);
                      Navigator.pop(context);
                    },
                  ),
                  if (canSeeSupervisor)
                    ListTile(
                      leading: const Icon(Icons.security_outlined),
                      title: const Text('Painel Supervisor'),
                      selected: _selectedIndex == 4,
                      onTap: () {
                        setState(() => _selectedIndex = 4);
                        Navigator.pop(context);
                      },
                    ),
                  const Divider(),
                  if (canSeeSettings)
                    ListTile(
                      leading: const Icon(Icons.settings_outlined),
                      title: const Text('Configurações'),
                      selected: _selectedIndex == 5,
                      onTap: () {
                        setState(() => _selectedIndex = 5);
                        Navigator.pop(context);
                      },
                    ),
                  const Spacer(),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.redAccent),
                    title: const Text('Sair do Sistema',
                        style: TextStyle(color: Colors.redAccent)),
                    onTap: () {
                      Navigator.pop(context);
                      auth.logout();
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
      body: Row(
        children: [
          // Sidebar on large screens
          if (isLargeScreen)
            NavigationRail(
              selectedIndex: _selectedIndex > 5 ? 0 : _selectedIndex,
              onDestinationSelected: (int index) {
                // Adjust index if we hide supervisor or settings options in destination index list
                setState(() {
                  _selectedIndex = index;
                });
              },
              extended: true,
              minExtendedWidth: 200,
              backgroundColor: isDark ? AppColors.cardDark : Colors.white,
              elevation: 4,
              destinations: [
                const NavigationRailDestination(
                  icon: Icon(Icons.dashboard_outlined),
                  selectedIcon: Icon(Icons.dashboard),
                  label: Text('Dashboard'),
                ),
                const NavigationRailDestination(
                  icon: Icon(Icons.people_alt_outlined),
                  selectedIcon: Icon(Icons.people_alt),
                  label: Text('Clientes'),
                ),
                const NavigationRailDestination(
                  icon: Icon(Icons.assignment_outlined),
                  selectedIcon: Icon(Icons.assignment),
                  label: Text('Propostas'),
                ),
                const NavigationRailDestination(
                  icon: Icon(Icons.business_outlined),
                  selectedIcon: Icon(Icons.business),
                  label: Text('Empresas'),
                ),
                if (canSeeSupervisor)
                  const NavigationRailDestination(
                    icon: Icon(Icons.security_outlined),
                    selectedIcon: Icon(Icons.security),
                    label: Text('Supervisor'),
                  ),
                if (canSeeSettings)
                  const NavigationRailDestination(
                    icon: Icon(Icons.settings_outlined),
                    selectedIcon: Icon(Icons.settings),
                    label: Text('Configurações'),
                  ),
              ],
            ),

          // Main content area
          Expanded(
            child: _getCurrentScreen(canSeeSupervisor, canSeeSettings),
          ),
        ],
      ),
      bottomNavigationBar: isLargeScreen
          ? null
          : BottomNavigationBar(
              currentIndex: _selectedIndex > 3 ? 0 : _selectedIndex,
              onTap: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              type: BottomNavigationBarType.fixed,
              selectedItemColor: AppColors.primary,
              unselectedItemColor: Colors.grey,
              items: const [
                BottomNavigationBarItem(
                    icon: Icon(Icons.dashboard_outlined), label: 'Dashboard'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.people_alt_outlined), label: 'Clientes'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.assignment_outlined), label: 'Propostas'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.business_outlined), label: 'Empresas'),
              ],
            ),
    );
  }
}

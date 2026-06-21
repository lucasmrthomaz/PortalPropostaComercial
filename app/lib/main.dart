import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'core/api_client.dart';
import 'core/constants.dart';
import 'providers/auth_provider.dart';
import 'providers/client_provider.dart';
import 'providers/proposal_provider.dart';
import 'providers/company_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/supervisor_provider.dart';
import 'providers/proposal_type_provider.dart';
import 'providers/user_management_provider.dart';
import 'screens/login_screen.dart';
import 'screens/shell_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize ApiClient configurations
  await ApiClient.instance.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ClientProvider()),
        ChangeNotifierProvider(create: (_) => ProposalProvider()),
        ChangeNotifierProvider(create: (_) => CompanyProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => SupervisorProvider()),
        ChangeNotifierProvider(create: (_) => ProposalTypeProvider()),
        ChangeNotifierProvider(create: (_) => UserManagementProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    // Dynamic material themes matching premium designs
    final lightTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.bgLight,
      ),
      textTheme: GoogleFonts.interTextTheme(),
      cardTheme: CardThemeData(
        color: AppColors.cardLight,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: AppStyles.cardRadius),
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: AppColors.cardLight,
        surfaceTintColor: Colors.transparent,
      ),
      dropdownMenuTheme: const DropdownMenuThemeData(
        textStyle: TextStyle(fontSize: 14),
      ),
    );

    final darkTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        brightness: Brightness.dark,
        seedColor: AppColors.primary,
        primary: AppColors.primaryLight,
        secondary: AppColors.secondary,
        surface: AppColors.bgDark,
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
      cardTheme: CardThemeData(
        color: AppColors.cardDark,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: AppStyles.cardRadius),
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: AppColors.cardDark,
        surfaceTintColor: Colors.transparent,
      ),
      dropdownMenuTheme: const DropdownMenuThemeData(
        textStyle: TextStyle(fontSize: 14, color: Colors.white),
      ),
    );

    return MaterialApp(
      title: 'Portal Propostas',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.system, // Auto detect dark mode
      debugShowCheckedModeBanner: false,
      home: auth.isLoggedIn ? const ShellScreen() : const LoginScreen(),
    );
  }
}

import 'package:flutter/material.dart';

class AppColors {
  // Theme Colors
  static const Color primary = Color(0xFF1E3A8A); // Deep Blue
  static const Color primaryLight = Color(0xFF3B82F6);
  static const Color secondary = Color(0xFF4F46E5); // Indigo
  static const Color accent = Color(0xFF8B5CF6); // Purple

  // Backgrounds
  static const Color bgLight = Color(0xFFF8FAFC);
  static const Color bgDark = Color(0xFF0F172A);
  static const Color cardLight = Colors.white;
  static const Color cardDark = Color(0xFF1E293B);

  // Status Colors
  static const Color statusPending = Color(0xFFF59E0B); // Amber
  static const Color statusApproved = Color(0xFF10B981); // Emerald
  static const Color statusRejected = Color(0xFFEF4444); // Red/Rose
  static const Color statusAnalysis = Color(0xFF06B6D4); // Cyan

  // Greys
  static const Color textMainLight = Color(0xFF0F172A);
  static const Color textMainDark = Color(0xFFF8FAFC);
  static const Color textMutedLight = Color(0xFF64748B);
  static const Color textMutedDark = Color(0xFF94A3B8);
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color borderDark = Color(0xFF334155);

  // Gradient definitions for premium look
  static const LinearGradient premiumGradient = LinearGradient(
    colors: [primary, secondary, accent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0x1F3B82F6), Color(0x0A8B5CF6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AppGradients {
  static const LinearGradient loginBg = LinearGradient(
    colors: [Color(0xFF0F172A), Color(0xFF1E1E38), Color(0xFF111827)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}

class AppStyles {
  static final BorderRadius cardRadius = BorderRadius.circular(16.0);
  static final BorderRadius inputRadius = BorderRadius.circular(12.0);
  static final BorderRadius buttonRadius = BorderRadius.circular(24.0);

  static List<BoxShadow> cardShadow(bool isDark) {
    if (isDark) {
      return [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.3),
          blurRadius: 10,
          offset: const Offset(0, 4),
        )
      ];
    } else {
      return [
        BoxShadow(
          color: Colors.grey.withValues(alpha: 0.08),
          blurRadius: 15,
          offset: const Offset(0, 8),
        ),
        BoxShadow(
          color: Colors.grey.withValues(alpha: 0.03),
          blurRadius: 5,
          offset: const Offset(0, 2),
        )
      ];
    }
  }
}

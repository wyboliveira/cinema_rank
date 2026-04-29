import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// As 4 opções de paleta disponíveis na tela de Configurações.
enum AppThemeOption {
  blueCyan,   // fundo branco · azul e ciano
  pink,       // fundo branco · rosa e magenta
  greenLime,  // fundo branco · verde e lima
  graySlate,  // fundo branco · cinza, preto e prata
}

extension AppThemeOptionLabel on AppThemeOption {
  String get label => switch (this) {
    AppThemeOption.blueCyan  => 'Azul / Ciano',
    AppThemeOption.pink      => 'Rosa',
    AppThemeOption.greenLime => 'Verde / Lima',
    AppThemeOption.graySlate => 'Cinza / Prata',
  };

  Color get previewColor => switch (this) {
    AppThemeOption.blueCyan  => const Color(0xFF0077B6),
    AppThemeOption.pink      => const Color(0xFFD63384),
    AppThemeOption.greenLime => const Color(0xFF4CAF50),
    AppThemeOption.graySlate => const Color(0xFF455A64),
  };

  String get settingsValue => name; // serializado como string no banco
}

class AppTheme {
  AppTheme._();

  static ThemeData build(AppThemeOption option) {
    return switch (option) {
      AppThemeOption.blueCyan  => _blueCyan(),
      AppThemeOption.pink      => _pink(),
      AppThemeOption.greenLime => _greenLime(),
      AppThemeOption.graySlate => _graySlate(),
    };
  }

  static CardThemeData get _cardTheme => const CardThemeData(
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
    ),
  );

  // ── Azul / Ciano ──────────────────────────────────────────────────────────
  static ThemeData _blueCyan() => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF0077B6),
      primary: const Color(0xFF0077B6),
      secondary: const Color(0xFF00B4D8),
      surface: Colors.white,
      brightness: Brightness.light,
    ),
    textTheme: GoogleFonts.interTextTheme(),
    cardTheme: _cardTheme,
  );

  // ── Rosa ──────────────────────────────────────────────────────────────────
  static ThemeData _pink() => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFFD63384),
      primary: const Color(0xFFD63384),
      secondary: const Color(0xFFFF85A1),
      surface: Colors.white,
      brightness: Brightness.light,
    ),
    textTheme: GoogleFonts.interTextTheme(),
    cardTheme: _cardTheme,
  );

  // ── Verde / Lima ──────────────────────────────────────────────────────────
  static ThemeData _greenLime() => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF2E7D32),
      primary: const Color(0xFF388E3C),
      secondary: const Color(0xFF8BC34A),
      surface: Colors.white,
      brightness: Brightness.light,
    ),
    textTheme: GoogleFonts.interTextTheme(),
    cardTheme: _cardTheme,
  );

  // ── Cinza / Prata ─────────────────────────────────────────────────────────
  static ThemeData _graySlate() => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF455A64),
      primary: const Color(0xFF37474F),
      secondary: const Color(0xFF90A4AE),
      surface: Colors.white,
      brightness: Brightness.light,
    ),
    textTheme: GoogleFonts.interTextTheme(),
    cardTheme: _cardTheme,
  );
}

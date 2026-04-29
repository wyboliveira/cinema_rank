import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'presentation/pages/home/home_page.dart';
import 'presentation/providers/theme_provider.dart';

class CinemaRankApp extends ConsumerWidget {
  const CinemaRankApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 📖 themeProvider é assíncrono (lê do banco na inicialização).
    // Enquanto carrega, usa o tema padrão para não exibir tela em branco.
    final themeOption = ref
        .watch(themeProvider)
        .valueOrNull ?? AppThemeOption.blueCyan;

    return MaterialApp(
      title: 'Cinema Rank',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.build(themeOption),
      home: const HomePage(),
    );
  }
}

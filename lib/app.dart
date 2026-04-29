import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'presentation/pages/home/home_page.dart';

// 📖 ConsumerWidget permite que o widget leia providers do Riverpod.
// Aqui usamos apenas para ter acesso ao tema reativo no futuro (ex: dark mode).
class CinemaRankApp extends ConsumerWidget {
  const CinemaRankApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Cinema Rank',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      home: const HomePage(),
    );
  }
}
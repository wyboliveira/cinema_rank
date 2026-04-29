import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';

// Tela inicial com atalhos para Biblioteca de Filmes e Listas de Ranking.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cinema Rank'),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppConstants.kSpacingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Bem-vindo!', style: theme.textTheme.headlineMedium),
            const SizedBox(height: AppConstants.kSpacingSmall),
            Text(
              'Cadastre filmes e crie seus rankings.',
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: AppConstants.kSpacingLarge),
            // TODO(feat): substituir por cards de navegação com ícones
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.movie_outlined),
              label: const Text('Biblioteca de Filmes'),
            ),
            const SizedBox(height: AppConstants.kSpacingMedium),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.format_list_numbered),
              label: const Text('Minhas Listas'),
            ),
          ],
        ),
      ),
    );
  }
}

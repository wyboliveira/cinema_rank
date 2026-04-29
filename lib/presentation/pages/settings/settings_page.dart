import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import 'genre_manager_section.dart';
import 'theme_selector_section.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
      body: ListView(
        padding: const EdgeInsets.all(AppConstants.kSpacingLarge),
        children: [
          Text('Aparência', style: theme.textTheme.titleLarge),
          const SizedBox(height: AppConstants.kSpacingMedium),
          const ThemeSelectorSection(),
          const SizedBox(height: AppConstants.kSpacingLarge),
          const Divider(),
          const SizedBox(height: AppConstants.kSpacingMedium),
          Text('Gêneros e Subgêneros', style: theme.textTheme.titleLarge),
          const SizedBox(height: AppConstants.kSpacingSmall),
          Text(
            'Gerencie os gêneros e subgêneros disponíveis para cadastro de filmes.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppConstants.kSpacingMedium),
          const GenreManagerSection(),
        ],
      ),
    );
  }
}

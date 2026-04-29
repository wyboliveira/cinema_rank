import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../domain/entities/genre.dart';
import '../../providers/genre_provider.dart';

class GenreManagerSection extends ConsumerWidget {
  const GenreManagerSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final genresAsync = ref.watch(genresStreamProvider);

    return genresAsync.when(
      loading: () => const CircularProgressIndicator(),
      error: (e, _) => Text('Erro: $e'),
      data: (genres) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...genres.map((g) => _GenreTile(genre: g)),
          const SizedBox(height: AppConstants.kSpacingSmall),
          OutlinedButton.icon(
            onPressed: () => _showAddGenreDialog(context, ref),
            icon: const Icon(Icons.add),
            label: const Text('Novo Gênero'),
          ),
        ],
      ),
    );
  }

  void _showAddGenreDialog(BuildContext context, WidgetRef ref) {
    final ctrl = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Novo Gênero'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(
            labelText: 'Nome do gênero',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
          onSubmitted: (_) => _saveGenre(context, ref, ctrl),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => _saveGenre(context, ref, ctrl),
            child: const Text('Adicionar'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveGenre(
    BuildContext context,
    WidgetRef ref,
    TextEditingController ctrl,
  ) async {
    if (ctrl.text.trim().isEmpty) return;
    await ref.read(genreNotifierProvider.notifier).addGenre(ctrl.text.trim());
    if (context.mounted) Navigator.of(context).pop();
  }
}

class _GenreTile extends ConsumerWidget {
  const _GenreTile({required this.genre});

  final Genre genre;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subgenresAsync = ref.watch(subgenresStreamProvider(genre.id));

    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.kSpacingSmall),
      child: ExpansionTile(
        title: Text(genre.name),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!genre.isDefault)
              IconButton(
                icon: const Icon(Icons.delete_outline),
                tooltip: 'Excluir gênero',
                onPressed: () => ref
                    .read(genreNotifierProvider.notifier)
                    .deleteGenre(genre.id),
              ),
            const Icon(Icons.expand_more),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.kSpacingMedium,
              vertical: AppConstants.kSpacingSmall,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                subgenresAsync.when(
                  loading: () => const SizedBox.shrink(),
                  error: (e, _) => Text('Erro: $e'),
                  data: (subs) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ...subs.map(
                        (s) => ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          title: Text(s.name),
                          trailing: s.isDefault
                              ? null
                              : IconButton(
                                  icon: const Icon(Icons.close, size: 18),
                                  onPressed: () => ref
                                      .read(genreNotifierProvider.notifier)
                                      .deleteSubgenre(s.id),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppConstants.kSpacingSmall),
                TextButton.icon(
                  onPressed: () =>
                      _showAddSubgenreDialog(context, ref, genre.id),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Novo Subgênero'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddSubgenreDialog(
    BuildContext context,
    WidgetRef ref,
    String genreId,
  ) {
    final ctrl = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Subgênero para "${genre.name}"'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(
            labelText: 'Nome do subgênero',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () async {
              if (ctrl.text.trim().isEmpty) return;
              await ref
                  .read(genreNotifierProvider.notifier)
                  .addSubgenre(ctrl.text.trim(), genreId);
              if (context.mounted) Navigator.of(context).pop();
            },
            child: const Text('Adicionar'),
          ),
        ],
      ),
    );
  }
}

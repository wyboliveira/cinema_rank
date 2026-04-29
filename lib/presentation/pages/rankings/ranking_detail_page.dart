import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../domain/entities/movie.dart';
import '../../../domain/entities/ranking_item.dart';
import '../../../domain/entities/ranking_list.dart';
import '../../providers/movie_provider.dart';
import '../../providers/ranking_provider.dart';
import '../../widgets/movie_card.dart';

// Tela de detalhe de um ranking com drag-and-drop de filmes.
class RankingDetailPage extends ConsumerWidget {
  const RankingDetailPage({super.key, required this.list});

  final RankingList list;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(rankingItemsStreamProvider(list.id));
    final moviesAsync = ref.watch(moviesStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(list.title),
            Text(list.category,
                style: Theme.of(context).textTheme.labelSmall),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Adicionar filme',
            onPressed: () => moviesAsync.whenData(
              (movies) => _showMoviePicker(context, ref, movies),
            ),
          ),
        ],
      ),
      body: itemsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro: $e')),
        data: (items) => items.isEmpty
            ? const _EmptyState()
            : _RankingListView(list: list, items: items),
      ),
    );
  }

  void _showMoviePicker(
    BuildContext context,
    WidgetRef ref,
    List<Movie> movies,
  ) {
    showDialog<void>(
      context: context,
      builder: (_) => _MoviePickerDialog(list: list, allMovies: movies),
    );
  }
}

// Lista reordenável com drag-and-drop.
class _RankingListView extends ConsumerWidget {
  const _RankingListView({required this.list, required this.items});

  final RankingList list;
  final List<RankingItem> items;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final moviesAsync = ref.watch(moviesStreamProvider);
    final movieMap = moviesAsync.valueOrNull != null
        ? {for (final m in moviesAsync.valueOrNull!) m.id: m}
        : <String, Movie>{};

    return ReorderableListView.builder(
      padding: const EdgeInsets.only(
        left: AppConstants.kSpacingMedium,
        right: AppConstants.kSpacingMedium,
        top: AppConstants.kSpacingMedium,
        // Espaço extra no fundo para não cobrir o FAB.
        bottom: 80,
      ),
      itemCount: items.length,
      // 📖 onReorder é chamado após o usuário soltar o item.
      // Delegamos o recálculo de positions ao RankingNotifier.
      onReorder: (oldIndex, newIndex) {
        ref.read(rankingNotifierProvider.notifier).reorder(
              list.id,
              items,
              oldIndex,
              // 📖 ReorderableListView incrementa newIndex quando a direção
              // é para baixo; o Notifier já trata essa convenção corretamente.
              newIndex > oldIndex ? newIndex - 1 : newIndex,
            );
      },
      itemBuilder: (context, index) {
        final item = items[index];
        final movie = movieMap[item.movieId];

        return _RankingTile(
          key: ValueKey(item.id),
          position: item.position,
          movie: movie,
          onDelete: () => ref
              .read(rankingNotifierProvider.notifier)
              .removeItem(item.id, list.id),
        );
      },
    );
  }
}

class _RankingTile extends StatelessWidget {
  const _RankingTile({
    super.key,
    required this.position,
    required this.movie,
    required this.onDelete,
  });

  final int position;
  final Movie? movie;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.kSpacingSmall),
      child: Row(
        children: [
          // Número de posição em destaque.
          SizedBox(
            width: 36,
            child: Text(
              '$position',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: AppConstants.kSpacingSmall),
          Expanded(
            child: movie != null
                ? MovieCard(
                    movie: movie!,
                    trailing: IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: onDelete,
                    ),
                  )
                : const Card(child: ListTile(title: Text('Filme removido'))),
          ),
          // Ícone de drag visível (ReorderableListView usa ReorderableDragStartListener).
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Icon(Icons.drag_handle),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: AppConstants.kAnimationFast)
        .slideX(begin: 0.04, duration: AppConstants.kAnimationNormal);
  }
}

// Dialog de seleção de filme para adicionar ao ranking.
class _MoviePickerDialog extends ConsumerWidget {
  const _MoviePickerDialog({required this.list, required this.allMovies});

  final RankingList list;
  final List<Movie> allMovies;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(rankingItemsStreamProvider(list.id));
    final alreadyInList = itemsAsync.valueOrNull
            ?.map((i) => i.movieId)
            .toSet() ??
        {};

    final available = allMovies
        .where((m) => !alreadyInList.contains(m.id))
        .toList();

    return AlertDialog(
      title: const Text('Adicionar filme'),
      content: SizedBox(
        width: 480,
        height: 400,
        child: available.isEmpty
            ? const Center(child: Text('Todos os filmes já estão na lista.'))
            : ListView.builder(
                itemCount: available.length,
                itemBuilder: (_, i) {
                  final movie = available[i];
                  return MovieCard(
                    movie: movie,
                    onTap: () async {
                      final position = (itemsAsync.valueOrNull?.length ?? 0) + 1;
                      await ref
                          .read(rankingNotifierProvider.notifier)
                          .addMovie(list.id, movie.id, position);
                      if (context.mounted) Navigator.of(context).pop();
                    },
                  );
                },
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Fechar'),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.playlist_add,
              size: 64, color: Theme.of(context).colorScheme.outlineVariant),
          const SizedBox(height: AppConstants.kSpacingMedium),
          const Text('Adicione filmes usando o botão + acima.'),
        ],
      ),
    );
  }
}

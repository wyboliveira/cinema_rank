import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../domain/entities/movie.dart';
import '../../providers/movie_provider.dart';
import '../../widgets/movie_card.dart';
import 'movie_form_dialog.dart';

// 📖 ConsumerWidget é o equivalente Riverpod de StatelessWidget.
// Recebe um WidgetRef para ler/escutar providers.
class MoviesPage extends ConsumerWidget {
  const MoviesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // AsyncValue<List<Movie>> — pode ser loading, error ou data.
    final moviesAsync = ref.watch(moviesStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Biblioteca de Filmes')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(context, ref, null),
        icon: const Icon(Icons.add),
        label: const Text('Novo Filme'),
      ),
      body: moviesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Erro: $e')),
        data: (movies) => movies.isEmpty
            ? const _EmptyState()
            : _MovieList(movies: movies, onEdit: (m) => _openForm(context, ref, m)),
      ),
    );
  }

  void _openForm(BuildContext context, WidgetRef ref, Movie? movie) {
    showDialog<void>(
      context: context,
      builder: (_) => MovieFormDialog(existingMovie: movie),
    );
  }
}

class _MovieList extends StatelessWidget {
  const _MovieList({required this.movies, required this.onEdit});

  final List<Movie> movies;
  final void Function(Movie) onEdit;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(AppConstants.kSpacingMedium),
      itemCount: movies.length,
      separatorBuilder: (_, _) =>
          const SizedBox(height: AppConstants.kSpacingSmall),
      itemBuilder: (_, i) => MovieCard(
        movie: movies[i],
        onTap: () => onEdit(movies[i]),
      ),
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
          Icon(Icons.movie_outlined,
              size: 64, color: Theme.of(context).colorScheme.outlineVariant),
          const SizedBox(height: AppConstants.kSpacingMedium),
          Text('Nenhum filme cadastrado ainda.',
              style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }
}

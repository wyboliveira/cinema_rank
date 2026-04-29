import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../domain/entities/genre.dart';
import '../../../domain/entities/movie.dart';
import '../../../domain/entities/subgenre.dart';
import '../../providers/genre_provider.dart';
import '../../providers/movie_provider.dart';
import '../../widgets/movie_card.dart';
import 'movie_form_dialog.dart';

// Enum dos 3 modos de exibição da biblioteca.
enum LibraryViewMode { list, grid, icons }

// Provider local (in-memory) do modo de exibição. Não precisa persistir.
final _viewModeProvider = StateProvider<LibraryViewMode>(
  (_) => LibraryViewMode.list,
);

class MoviesPage extends ConsumerWidget {
  const MoviesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final moviesAsync = ref.watch(moviesStreamProvider);
    final genresAsync = ref.watch(genresStreamProvider);
    final subgenresAsync = ref.watch(allSubgenresStreamProvider);
    final viewMode = ref.watch(_viewModeProvider);

    // Monta mapas id → nome para compor o label de gênero sem acessar o banco a cada card.
    final genreMap = {for (final g in genresAsync.valueOrNull ?? <Genre>[]) g.id: g.name};
    final subMap = {
      for (final s in subgenresAsync.valueOrNull ?? <Subgenre>[]) s.id: s.name,
    };

    String genreLabel(Movie m) {
      final g = m.genreId != null ? genreMap[m.genreId] : null;
      final s = m.subGenreId != null ? subMap[m.subGenreId] : null;
      if (g == null) return '';
      return s != null ? '$g · $s' : g;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Biblioteca de Filmes'),
        actions: [
          _ViewModeToggle(current: viewMode),
          const SizedBox(width: AppConstants.kSpacingSmall),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showDialog<void>(
          context: context,
          builder: (_) => const MovieFormDialog(),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Novo Filme'),
      ),
      body: moviesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro: $e')),
        data: (movies) {
          if (movies.isEmpty) return const _EmptyState();
          return switch (viewMode) {
            LibraryViewMode.list => _ListView(
                movies: movies,
                genreLabel: genreLabel,
                onEdit: (m) => _openForm(context, m),
              ),
            LibraryViewMode.grid => _GridView(
                movies: movies,
                genreLabel: genreLabel,
                onEdit: (m) => _openForm(context, m),
              ),
            LibraryViewMode.icons => _IconsView(
                movies: movies,
                onEdit: (m) => _openForm(context, m),
              ),
          };
        },
      ),
    );
  }

  void _openForm(BuildContext context, Movie? movie) {
    showDialog<void>(
      context: context,
      builder: (_) => MovieFormDialog(existingMovie: movie),
    );
  }
}

// ── Toggle de modo de exibição ────────────────────────────────────────────────
class _ViewModeToggle extends ConsumerWidget {
  const _ViewModeToggle({required this.current});

  final LibraryViewMode current;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SegmentedButton<LibraryViewMode>(
      segments: const [
        ButtonSegment(
          value: LibraryViewMode.list,
          icon: Icon(Icons.view_list, size: 18),
          tooltip: 'Lista',
        ),
        ButtonSegment(
          value: LibraryViewMode.grid,
          icon: Icon(Icons.grid_view, size: 18),
          tooltip: 'Grade',
        ),
        ButtonSegment(
          value: LibraryViewMode.icons,
          icon: Icon(Icons.grid_on, size: 18),
          tooltip: 'Ícones',
        ),
      ],
      selected: {current},
      onSelectionChanged: (s) =>
          ref.read(_viewModeProvider.notifier).state = s.first,
      style: const ButtonStyle(
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}

// ── Modo Lista (1 coluna) ──────────────────────────────────────────────────────
class _ListView extends StatelessWidget {
  const _ListView({
    required this.movies,
    required this.genreLabel,
    required this.onEdit,
  });

  final List<Movie> movies;
  final String Function(Movie) genreLabel;
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
        genreLabel: genreLabel(movies[i]),
        onTap: () => onEdit(movies[i]),
      ),
    );
  }
}

// ── Modo Grade (4 colunas) ─────────────────────────────────────────────────────
class _GridView extends StatelessWidget {
  const _GridView({
    required this.movies,
    required this.genreLabel,
    required this.onEdit,
  });

  final List<Movie> movies;
  final String Function(Movie) genreLabel;
  final void Function(Movie) onEdit;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(AppConstants.kSpacingMedium),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: AppConstants.kSpacingSmall,
        mainAxisSpacing: AppConstants.kSpacingSmall,
        childAspectRatio: 2.2,
      ),
      itemCount: movies.length,
      itemBuilder: (_, i) => MovieCard(
        movie: movies[i],
        genreLabel: genreLabel(movies[i]),
        onTap: () => onEdit(movies[i]),
      ),
    );
  }
}

// ── Modo Ícones (flex-wrap com poster + título) ────────────────────────────────
class _IconsView extends StatelessWidget {
  const _IconsView({required this.movies, required this.onEdit});

  final List<Movie> movies;
  final void Function(Movie) onEdit;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.kSpacingMedium),
      child: Wrap(
        spacing: AppConstants.kSpacingMedium,
        runSpacing: AppConstants.kSpacingMedium,
        children: movies
            .map((m) => _IconTile(movie: m, onTap: () => onEdit(m)))
            .toList(),
      ),
    );
  }
}

class _IconTile extends StatelessWidget {
  const _IconTile({required this.movie, required this.onTap});

  final Movie movie;
  final VoidCallback onTap;

  static const double _width = 140;
  static const double _posterHeight = 180;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppConstants.kCardBorderRadius),
      child: SizedBox(
        width: _width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            MoviePoster(
              imagePath: movie.imagePath,
              width: _width,
              height: _posterHeight,
              borderRadius: AppConstants.kCardBorderRadius,
            ),
            const SizedBox(height: AppConstants.kSpacingSmall),
            Text(
              movie.title,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
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
          Icon(
            Icons.movie_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
          const SizedBox(height: AppConstants.kSpacingMedium),
          Text(
            'Nenhum filme cadastrado ainda.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}

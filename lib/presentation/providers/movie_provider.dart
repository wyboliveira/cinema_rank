import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/movie.dart';
import '../../domain/repositories/movie_repository.dart';
import 'database_provider.dart';

// 📖 StreamProvider converte o Stream reativo do repositório em AsyncValue<T>.
// A UI usa .when(data:, loading:, error:) para tratar cada estado sem if/else.
final moviesStreamProvider = StreamProvider<List<Movie>>((ref) {
  return ref.watch(movieRepositoryProvider).watchAll();
});

// AsyncNotifier para operações de escrita (save, delete).
// Separar leitura (StreamProvider) de escrita (Notifier) mantém o código limpo.
final movieNotifierProvider =
    AsyncNotifierProvider<MovieNotifier, void>(MovieNotifier.new);

class MovieNotifier extends AsyncNotifier<void> {
  MovieRepository get _repo => ref.read(movieRepositoryProvider);

  @override
  Future<void> build() async {}

  Future<void> save(Movie movie) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _repo.save(movie));
  }

  Future<void> delete(String id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _repo.delete(id));
  }

  // Fábrica: garante que todo filme novo tenha UUID e timestamp corretos.
  Movie createNew({
    required String title,
    required int year,
    required String genre,
    required String director,
    required String synopsis,
    String? imagePath,
  }) {
    return Movie(
      id: const Uuid().v4(),
      title: title,
      year: year,
      genre: genre,
      director: director,
      synopsis: synopsis,
      imagePath: imagePath,
      createdAt: DateTime.now(),
    );
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/movie.dart';
import '../../domain/repositories/movie_repository.dart';
import 'database_provider.dart';

final moviesStreamProvider = StreamProvider<List<Movie>>((ref) {
  return ref.watch(movieRepositoryProvider).watchAll();
});

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

  Movie createNew({
    required String title,
    required int year,
    required String director,
    required String synopsis,
    String? imagePath,
    String? genreId,
    String? subGenreId,
  }) {
    return Movie(
      id: const Uuid().v4(),
      title: title,
      year: year,
      director: director,
      synopsis: synopsis,
      imagePath: imagePath,
      genreId: genreId,
      subGenreId: subGenreId,
      createdAt: DateTime.now(),
    );
  }
}

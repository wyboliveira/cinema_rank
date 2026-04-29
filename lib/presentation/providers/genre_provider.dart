import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/genre.dart';
import '../../domain/entities/subgenre.dart';
import '../../domain/repositories/genre_repository.dart';
import 'database_provider.dart';

final genresStreamProvider = StreamProvider<List<Genre>>((ref) {
  return ref.watch(genreRepositoryProvider).watchAll();
});

// Todos os subgêneros (para montar mapas de id→nome na UI).
final allSubgenresStreamProvider = StreamProvider<List<Subgenre>>((ref) {
  return ref.watch(genreRepositoryProvider).watchAllSubgenres();
});

// Provider parametrizado: subgêneros de um gênero específico.
final subgenresStreamProvider =
    StreamProvider.family<List<Subgenre>, String>((ref, genreId) {
  return ref.watch(genreRepositoryProvider).watchSubgenresByGenre(genreId);
});

final genreNotifierProvider =
    AsyncNotifierProvider<GenreNotifier, void>(GenreNotifier.new);

class GenreNotifier extends AsyncNotifier<void> {
  GenreRepository get _repo => ref.read(genreRepositoryProvider);

  @override
  Future<void> build() async {}

  Future<void> addGenre(String name) async {
    final genre = Genre(id: const Uuid().v4(), name: name);
    state = await AsyncValue.guard(() => _repo.saveGenre(genre));
  }

  Future<void> deleteGenre(String genreId) async {
    state = await AsyncValue.guard(() => _repo.deleteGenre(genreId));
  }

  Future<void> addSubgenre(String name, String genreId) async {
    final sub = Subgenre(id: const Uuid().v4(), name: name, genreId: genreId);
    state = await AsyncValue.guard(() => _repo.saveSubgenre(sub));
  }

  Future<void> deleteSubgenre(String subgenreId) async {
    state = await AsyncValue.guard(() => _repo.deleteSubgenre(subgenreId));
  }
}

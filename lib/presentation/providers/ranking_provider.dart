import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/ranking_item.dart';
import '../../domain/entities/ranking_list.dart';
import '../../domain/repositories/ranking_list_repository.dart';
import 'database_provider.dart';

final rankingListsStreamProvider = StreamProvider<List<RankingList>>((ref) {
  return ref.watch(rankingListRepositoryProvider).watchAll();
});

// Provider parametrizado: watch dos itens de uma lista específica.
// 📖 family() cria uma versão do provider para cada listId diferente,
// evitando que a troca de lista reconstrua providers de outras listas.
final rankingItemsStreamProvider =
    StreamProvider.family<List<RankingItem>, String>((ref, listId) {
  return ref.watch(rankingListRepositoryProvider).watchItemsByList(listId);
});

final rankingNotifierProvider =
    AsyncNotifierProvider<RankingNotifier, void>(RankingNotifier.new);

class RankingNotifier extends AsyncNotifier<void> {
  RankingListRepository get _repo => ref.read(rankingListRepositoryProvider);

  @override
  Future<void> build() async {}

  RankingList createNewList({
    required String title,
    required String category,
  }) {
    return RankingList(
      id: const Uuid().v4(),
      title: title,
      category: category,
      createdAt: DateTime.now(),
    );
  }

  Future<void> saveList(RankingList list) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _repo.save(list));
  }

  Future<void> deleteList(String listId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _repo.delete(listId));
  }

  Future<void> addMovie(String listId, String movieId, int position) async {
    final item = RankingItem(
      id: const Uuid().v4(),
      listId: listId,
      movieId: movieId,
      position: position,
    );
    state = await AsyncValue.guard(() => _repo.addItem(item));
  }

  Future<void> removeItem(String itemId, String listId) async {
    state = await AsyncValue.guard(() => _repo.removeItem(itemId, listId));
  }

  // Chamado após drag-and-drop: recalcula positions e persiste.
  Future<void> reorder(
    String listId,
    List<RankingItem> items,
    int oldIndex,
    int newIndex,
  ) async {
    // 📖 ReorderableListView entrega newIndex já ajustado para remoções
    // descendentes. Reindexamos aqui para manter positions 1-based e contínuos.
    final reordered = List<RankingItem>.from(items);
    final moved = reordered.removeAt(oldIndex);
    reordered.insert(newIndex, moved);

    final updated = [
      for (int i = 0; i < reordered.length; i++)
        reordered[i].copyWith(position: i + 1),
    ];

    state = await AsyncValue.guard(() => _repo.reorderItems(listId, updated));
  }
}

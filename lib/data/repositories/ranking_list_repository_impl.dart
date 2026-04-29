import '../../domain/entities/ranking_item.dart';
import '../../domain/entities/ranking_list.dart';
import '../../domain/repositories/ranking_list_repository.dart';

// TODO(implementação): substituir pelo DAO do Drift quando o schema estiver definido.
class RankingListRepositoryImpl implements RankingListRepository {
  @override
  Future<List<RankingList>> getAll() async => [];

  @override
  Future<void> save(RankingList list) async {}

  @override
  Future<void> delete(String listId) async {}

  @override
  Future<void> addItem(RankingItem item) async {}

  @override
  Future<void> removeItem(String itemId, String listId) async {}

  @override
  Future<void> reorderItems(String listId, List<RankingItem> items) async {}

  @override
  Stream<List<RankingList>> watchAll() => Stream.value([]);

  @override
  Stream<List<RankingItem>> watchItemsByList(String listId) => Stream.value([]);
}

import '../../core/utils/logger.dart';
import '../../domain/entities/ranking_item.dart';
import '../../domain/entities/ranking_list.dart';
import '../../domain/repositories/ranking_list_repository.dart';
import '../database/daos/ranking_list_dao.dart';
import '../models/ranking_list_model.dart';

class RankingListRepositoryImpl implements RankingListRepository {
  const RankingListRepositoryImpl(this._dao);

  final RankingListDao _dao;

  @override
  Stream<List<RankingList>> watchAll() => _dao
      .watchAll()
      .map((rows) => rows.map((r) => r.toEntity()).toList());

  @override
  Future<List<RankingList>> getAll() async {
    final rows = await _dao.watchAll().first;
    return rows.map((r) => r.toEntity()).toList();
  }

  @override
  Future<void> save(RankingList list) async {
    await _dao.upsertList(list.toCompanion());
    AppLogger.info('Lista salva', {'id': list.id, 'title': list.title});
  }

  @override
  Future<void> delete(String listId) async {
    await _dao.deleteList(listId);
    AppLogger.info('Lista removida', {'id': listId});
  }

  @override
  Future<void> addItem(RankingItem item) async {
    await _dao.upsertItem(item.toCompanion());
    AppLogger.info('Item adicionado à lista', {
      'listId': item.listId,
      'movieId': item.movieId,
      'position': item.position,
    });
  }

  @override
  Future<void> removeItem(String itemId, String listId) async {
    await _dao.deleteItem(itemId);
    AppLogger.info('Item removido da lista', {'itemId': itemId, 'listId': listId});
  }

  @override
  Future<void> reorderItems(String listId, List<RankingItem> items) async {
    final companions = items.map((i) => i.toCompanion()).toList();
    await _dao.reorderItems(listId, companions);
    AppLogger.debug('Lista reordenada', {'listId': listId, 'count': items.length});
  }

  @override
  Stream<List<RankingItem>> watchItemsByList(String listId) => _dao
      .watchItemsByList(listId)
      .map((rows) => rows.map((r) => r.toEntity()).toList());
}

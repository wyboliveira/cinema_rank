import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/ranking_items_table.dart';
import '../tables/ranking_lists_table.dart';

part 'ranking_list_dao.g.dart';

// 📖 O mixin gerado _$RankingListDaoMixin expõe rankingListsTable,
// rankingItemsTable e moviesTable como getters prontos para uso.
@DriftAccessor(tables: [RankingListsTable, RankingItemsTable])
class RankingListDao extends DatabaseAccessor<AppDatabase>
    with _$RankingListDaoMixin {
  RankingListDao(super.db);

  Stream<List<RankingListsTableData>> watchAll() =>
      (select(rankingListsTable)
            ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
          .watch();

  Future<void> upsertList(RankingListsTableCompanion companion) =>
      into(rankingListsTable).insertOnConflictUpdate(companion);

  Future<void> deleteList(String listId) =>
      (delete(rankingListsTable)..where((t) => t.id.equals(listId))).go();

  Stream<List<RankingItemsTableData>> watchItemsByList(String listId) =>
      (select(rankingItemsTable)
            ..where((t) => t.listId.equals(listId))
            ..orderBy([(t) => OrderingTerm.asc(t.position)]))
          .watch();

  Future<void> upsertItem(RankingItemsTableCompanion companion) =>
      into(rankingItemsTable).insertOnConflictUpdate(companion);

  Future<void> deleteItem(String itemId) =>
      (delete(rankingItemsTable)..where((t) => t.id.equals(itemId))).go();

  // 📖 Transação atômica: ou todos os positions são atualizados, ou nenhum.
  // Garante que o ranking nunca fique em estado inconsistente.
  Future<void> reorderItems(
    String listId,
    List<RankingItemsTableCompanion> companions,
  ) async {
    await transaction(() async {
      for (final companion in companions) {
        await (update(rankingItemsTable)
              ..where((t) => t.id.equals(companion.id.value)))
            .write(companion);
      }
    });
  }
}

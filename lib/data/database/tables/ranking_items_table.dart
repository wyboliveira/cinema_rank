import 'package:drift/drift.dart';

import 'movies_table.dart';
import 'ranking_lists_table.dart';

class RankingItemsTable extends Table {
  @override
  String get tableName => 'ranking_items';

  TextColumn get id => text()();

  // 📖 references() cria a FK e garante integridade referencial no SQLite.
  TextColumn get listId =>
      text().references(RankingListsTable, #id, onDelete: KeyAction.cascade)();

  TextColumn get movieId =>
      text().references(MoviesTable, #id, onDelete: KeyAction.cascade)();

  // 1-based: posição 1 = primeiro lugar.
  IntColumn get position => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

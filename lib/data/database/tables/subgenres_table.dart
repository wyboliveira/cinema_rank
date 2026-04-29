import 'package:drift/drift.dart';

import 'genres_table.dart';

class SubgenresTable extends Table {
  @override
  String get tableName => 'subgenres';

  TextColumn get id => text()();
  TextColumn get name => text()();

  // FK para o gênero pai; cascade deleta subgêneros quando o gênero é removido.
  TextColumn get genreId =>
      text().references(GenresTable, #id, onDelete: KeyAction.cascade)();

  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

import 'package:drift/drift.dart';

class RankingListsTable extends Table {
  @override
  String get tableName => 'ranking_lists';

  TextColumn get id => text()();

  TextColumn get title => text()();

  TextColumn get category => text()();

  IntColumn get createdAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

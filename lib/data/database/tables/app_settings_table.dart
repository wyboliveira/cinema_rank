import 'package:drift/drift.dart';

// Tabela de chave-valor para preferências do app (ex: tema selecionado).
// Evita dependência externa de shared_preferences.
class AppSettingsTable extends Table {
  @override
  String get tableName => 'app_settings';

  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

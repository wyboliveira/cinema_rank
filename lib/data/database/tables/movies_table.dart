import 'package:drift/drift.dart';

class MoviesTable extends Table {
  @override
  String get tableName => 'movies';

  TextColumn get id => text()();
  TextColumn get title => text()();
  IntColumn get year => integer()();

  // 📖 Coluna legada (v1): mantida para a migração SQLite não precisar
  // recriar a tabela. Não é mais exibida na UI — use genreId e subGenreId.
  TextColumn get genre => text().withDefault(const Constant(''))();

  TextColumn get director => text()();
  TextColumn get synopsis => text().withDefault(const Constant(''))();
  TextColumn get imagePath => text().nullable()();
  IntColumn get createdAt => integer()();

  // Adicionados na v2: FK para Genre e Subgenre (nullable = "Não selecionado").
  TextColumn get genreId => text().nullable()();
  TextColumn get subGenreId => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

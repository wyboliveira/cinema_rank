import 'package:drift/drift.dart';

// 📖 No Drift, uma "Table" descreve o schema em Dart puro.
// O build_runner gera a classe de dados (Movie) e o SQL correspondente.
// Usamos nomes em inglês/snake_case conforme convenção SQLite.
class MoviesTable extends Table {
  @override
  String get tableName => 'movies';

  // UUID v4 gerado na camada de domínio antes de salvar.
  TextColumn get id => text()();

  TextColumn get title => text()();

  IntColumn get year => integer()();

  TextColumn get genre => text()();

  TextColumn get director => text()();

  // withDefault('') evita NOT NULL sem valor em migrações futuras.
  TextColumn get synopsis => text().withDefault(const Constant(''))();

  // Nullable: o usuário pode não informar imagem.
  TextColumn get imagePath => text().nullable()();

  // Armazenado como inteiro (Unix timestamp em milissegundos).
  IntColumn get createdAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

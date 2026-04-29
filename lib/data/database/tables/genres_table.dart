import 'package:drift/drift.dart';

class GenresTable extends Table {
  @override
  String get tableName => 'genres';

  TextColumn get id => text()();
  TextColumn get name => text()();
  // Gêneros pré-cadastrados pelo sistema são marcados como padrão;
  // o usuário pode excluir apenas os que ele mesmo criou.
  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

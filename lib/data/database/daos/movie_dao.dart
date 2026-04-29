import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/movies_table.dart';

part 'movie_dao.g.dart';

// 📖 @DriftAccessor agrupa queries relacionadas a uma entidade.
// O Drift gera o mixin _$MovieDaoMixin via build_runner; ele expõe
// a propriedade `moviesTable` que usamos nas queries abaixo.
@DriftAccessor(tables: [MoviesTable])
class MovieDao extends DatabaseAccessor<AppDatabase> with _$MovieDaoMixin {
  MovieDao(super.db);

  Stream<List<MoviesTableData>> watchAll() =>
      (select(moviesTable)..orderBy([(t) => OrderingTerm.asc(t.title)]))
          .watch();

  Future<List<MoviesTableData>> getAll() =>
      (select(moviesTable)..orderBy([(t) => OrderingTerm.asc(t.title)])).get();

  Future<MoviesTableData?> getById(String id) =>
      (select(moviesTable)..where((t) => t.id.equals(id))).getSingleOrNull();

  // 📖 insertOnConflictUpdate é o "upsert" do Drift: insere se não existe,
  // substitui se o id já constar na tabela (baseado na primary key).
  Future<void> upsert(MoviesTableCompanion companion) =>
      into(moviesTable).insertOnConflictUpdate(companion);

  Future<void> deleteById(String id) =>
      (delete(moviesTable)..where((t) => t.id.equals(id))).go();
}

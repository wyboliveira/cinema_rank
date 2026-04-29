import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/genres_table.dart';
import '../tables/subgenres_table.dart';

part 'genre_dao.g.dart';

@DriftAccessor(tables: [GenresTable, SubgenresTable])
class GenreDao extends DatabaseAccessor<AppDatabase> with _$GenreDaoMixin {
  GenreDao(super.db);

  Stream<List<GenresTableData>> watchAll() =>
      (select(genresTable)..orderBy([(t) => OrderingTerm.asc(t.name)])).watch();

  Stream<List<SubgenresTableData>> watchByGenre(String genreId) =>
      (select(subgenresTable)
            ..where((t) => t.genreId.equals(genreId))
            ..orderBy([(t) => OrderingTerm.asc(t.name)]))
          .watch();

  Future<void> upsertGenre(GenresTableCompanion companion) =>
      into(genresTable).insertOnConflictUpdate(companion);

  Future<void> deleteGenre(String id) =>
      (delete(genresTable)..where((t) => t.id.equals(id))).go();

  Future<void> upsertSubgenre(SubgenresTableCompanion companion) =>
      into(subgenresTable).insertOnConflictUpdate(companion);

  Future<void> deleteSubgenre(String id) =>
      (delete(subgenresTable)..where((t) => t.id.equals(id))).go();

  Stream<List<SubgenresTableData>> watchAllSubgenres() =>
      (select(subgenresTable)..orderBy([(t) => OrderingTerm.asc(t.name)]))
          .watch();

  // Usado apenas para verificar se o seed já foi aplicado.
  Future<int> countGenres() =>
      (selectOnly(genresTable)..addColumns([genresTable.id.count()]))
          .map((row) => row.read(genresTable.id.count()) ?? 0)
          .getSingle();
}

import '../../domain/entities/genre.dart';
import '../../domain/entities/subgenre.dart';
import '../../domain/repositories/genre_repository.dart';
import '../database/daos/genre_dao.dart';
import '../models/genre_model.dart';

class GenreRepositoryImpl implements GenreRepository {
  const GenreRepositoryImpl(this._dao);

  final GenreDao _dao;

  @override
  Stream<List<Genre>> watchAll() =>
      _dao.watchAll().map((rows) => rows.map((r) => r.toEntity()).toList());

  @override
  Stream<List<Subgenre>> watchSubgenresByGenre(String genreId) => _dao
      .watchByGenre(genreId)
      .map((rows) => rows.map((r) => r.toEntity()).toList());

  @override
  Stream<List<Subgenre>> watchAllSubgenres() =>
      _dao.watchAllSubgenres().map((rows) => rows.map((r) => r.toEntity()).toList());

  @override
  Future<void> saveGenre(Genre genre) => _dao.upsertGenre(genre.toCompanion());

  @override
  Future<void> deleteGenre(String genreId) => _dao.deleteGenre(genreId);

  @override
  Future<void> saveSubgenre(Subgenre subgenre) =>
      _dao.upsertSubgenre(subgenre.toCompanion());

  @override
  Future<void> deleteSubgenre(String subgenreId) =>
      _dao.deleteSubgenre(subgenreId);
}

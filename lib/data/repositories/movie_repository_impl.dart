import '../../core/utils/logger.dart';
import '../../domain/entities/movie.dart';
import '../../domain/repositories/movie_repository.dart';
import '../database/daos/movie_dao.dart';
import '../models/movie_model.dart';

class MovieRepositoryImpl implements MovieRepository {
  const MovieRepositoryImpl(this._dao);

  final MovieDao _dao;

  @override
  Stream<List<Movie>> watchAll() =>
      _dao.watchAll().map((rows) => rows.map((r) => r.toEntity()).toList());

  @override
  Future<List<Movie>> getAll() async {
    final rows = await _dao.getAll();
    return rows.map((r) => r.toEntity()).toList();
  }

  @override
  Future<Movie?> getById(String id) async {
    final row = await _dao.getById(id);
    return row?.toEntity();
  }

  @override
  Future<void> save(Movie movie) async {
    await _dao.upsert(movie.toCompanion());
    AppLogger.info('Filme salvo', {'id': movie.id, 'title': movie.title});
  }

  @override
  Future<void> delete(String id) async {
    await _dao.deleteById(id);
    AppLogger.info('Filme removido', {'id': id});
  }
}

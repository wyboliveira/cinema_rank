import '../../domain/entities/movie.dart';
import '../../domain/repositories/movie_repository.dart';

// TODO(implementação): substituir pelo DAO do Drift quando o schema estiver definido.
// 📖 Esta classe concretiza o contrato MovieRepository usando o banco de dados.
// A presentation/ nunca importa esta classe diretamente — ela é injetada via Riverpod.
class MovieRepositoryImpl implements MovieRepository {
  // ignore: unused_field
  // final MovieDao _dao; // será injetado via construtor

  @override
  Future<List<Movie>> getAll() async => [];

  @override
  Future<Movie?> getById(String id) async => null;

  @override
  Future<void> save(Movie movie) async {}

  @override
  Future<void> delete(String id) async {}

  @override
  Stream<List<Movie>> watchAll() => Stream.value([]);
}

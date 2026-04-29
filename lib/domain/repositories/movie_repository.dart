import '../entities/movie.dart';

// 📖 Contrato abstrato — define O QUE pode ser feito com filmes,
// sem dizer COMO. A implementação concreta fica em data/repositories/.
abstract class MovieRepository {
  // Retorna todos os filmes, ordenados por título.
  Future<List<Movie>> getAll();

  // Retorna um filme pelo ID; null se não encontrado.
  Future<Movie?> getById(String id);

  // Insere ou atualiza um filme (upsert por ID).
  Future<void> save(Movie movie);

  // Remove um filme e todos os RankingItems que o referenciam.
  Future<void> delete(String id);

  // 📖 Stream reativo: a UI se atualiza automaticamente quando
  // qualquer filme for inserido, editado ou removido.
  Stream<List<Movie>> watchAll();
}

import '../entities/genre.dart';
import '../entities/subgenre.dart';

abstract class GenreRepository {
  Stream<List<Genre>> watchAll();

  Stream<List<Subgenre>> watchSubgenresByGenre(String genreId);

  // Todos os subgêneros de uma vez — usado para montar o mapa de IDs na UI.
  Stream<List<Subgenre>> watchAllSubgenres();

  Future<void> saveGenre(Genre genre);

  Future<void> deleteGenre(String genreId);

  Future<void> saveSubgenre(Subgenre subgenre);

  Future<void> deleteSubgenre(String subgenreId);
}

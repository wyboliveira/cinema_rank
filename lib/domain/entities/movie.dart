// 📖 Entidade pura — sem dependências de Flutter, Drift ou qualquer lib externa.
// Representa um filme tal como o domínio o enxerga (não como o banco o armazena).
class Movie {
  const Movie({
    required this.id,
    required this.title,
    required this.year,
    required this.genre,
    required this.director,
    required this.synopsis,
    required this.createdAt,
    this.imagePath,
  });

  final String id;
  final String title;
  final int year;
  final String genre;
  final String director;
  final String synopsis;
  final String? imagePath; // caminho absoluto no disco; null se não informado
  final DateTime createdAt;

  Movie copyWith({
    String? id,
    String? title,
    int? year,
    String? genre,
    String? director,
    String? synopsis,
    String? imagePath,
    DateTime? createdAt,
  }) {
    return Movie(
      id: id ?? this.id,
      title: title ?? this.title,
      year: year ?? this.year,
      genre: genre ?? this.genre,
      director: director ?? this.director,
      synopsis: synopsis ?? this.synopsis,
      imagePath: imagePath ?? this.imagePath,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Movie && other.id == id);

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Movie(id: $id, title: $title, year: $year)';
}

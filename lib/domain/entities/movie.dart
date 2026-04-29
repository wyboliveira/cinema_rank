// 📖 Entidade pura — sem dependências de Flutter, Drift ou qualquer lib externa.
class Movie {
  const Movie({
    required this.id,
    required this.title,
    required this.year,
    required this.director,
    required this.synopsis,
    required this.createdAt,
    this.imagePath,
    this.genreId,
    this.subGenreId,
  });

  final String id;
  final String title;
  final int year;
  final String director;
  final String synopsis;
  final String? imagePath;

  // null = "Não selecionado"; o usuário pode preencher depois na edição.
  final String? genreId;
  final String? subGenreId;

  final DateTime createdAt;

  Movie copyWith({
    String? id,
    String? title,
    int? year,
    String? director,
    String? synopsis,
    String? imagePath,
    Object? genreId = _sentinel,
    Object? subGenreId = _sentinel,
    DateTime? createdAt,
  }) {
    return Movie(
      id: id ?? this.id,
      title: title ?? this.title,
      year: year ?? this.year,
      director: director ?? this.director,
      synopsis: synopsis ?? this.synopsis,
      imagePath: imagePath ?? this.imagePath,
      // 📖 _sentinel permite distinguir "não passou o campo" de "passou null"
      // sem precisar de tipos opcionais complexos.
      genreId: genreId == _sentinel ? this.genreId : genreId as String?,
      subGenreId:
          subGenreId == _sentinel ? this.subGenreId : subGenreId as String?,
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

// Objeto sentinela para diferenciar "null explícito" de "não informado".
const _sentinel = Object();

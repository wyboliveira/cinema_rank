import 'package:drift/drift.dart';

import '../../domain/entities/movie.dart';
import '../database/app_database.dart';

extension MovieDataToEntity on MoviesTableData {
  Movie toEntity() => Movie(
    id: id,
    title: title,
    year: year,
    director: director,
    synopsis: synopsis,
    imagePath: imagePath,
    genreId: genreId,
    subGenreId: subGenreId,
    createdAt: DateTime.fromMillisecondsSinceEpoch(createdAt),
  );
}

extension MovieEntityToCompanion on Movie {
  MoviesTableCompanion toCompanion() => MoviesTableCompanion(
    id: Value(id),
    title: Value(title),
    year: Value(year),
    // Coluna legada (v1): NOT NULL sem DEFAULT no banco migrado.
    // Deve ser fornecida explicitamente para evitar constraint failure.
    genre: const Value(''),
    director: Value(director),
    synopsis: Value(synopsis),
    imagePath: Value(imagePath),
    genreId: Value(genreId),
    subGenreId: Value(subGenreId),
    createdAt: Value(createdAt.millisecondsSinceEpoch),
  );
}

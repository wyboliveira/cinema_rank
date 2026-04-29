import 'package:drift/drift.dart';

import '../../domain/entities/movie.dart';
import '../database/app_database.dart';

// 📖 Os tipos MoviesTableData e MoviesTableCompanion são gerados pelo Drift
// em app_database.g.dart (part of app_database.dart), por isso importamos
// app_database.dart e não diretamente o arquivo de tabela.
extension MovieDataToEntity on MoviesTableData {
  Movie toEntity() => Movie(
    id: id,
    title: title,
    year: year,
    genre: genre,
    director: director,
    synopsis: synopsis,
    imagePath: imagePath,
    // Drift armazena DateTime como Unix ms; convertemos de volta aqui.
    createdAt: DateTime.fromMillisecondsSinceEpoch(createdAt),
  );
}

extension MovieEntityToCompanion on Movie {
  MoviesTableCompanion toCompanion() => MoviesTableCompanion(
    id: Value(id),
    title: Value(title),
    year: Value(year),
    genre: Value(genre),
    director: Value(director),
    synopsis: Value(synopsis),
    imagePath: Value(imagePath),
    createdAt: Value(createdAt.millisecondsSinceEpoch),
  );
}

import 'package:drift/drift.dart';

import '../../domain/entities/genre.dart';
import '../../domain/entities/subgenre.dart';
import '../database/app_database.dart';

extension GenreDataToEntity on GenresTableData {
  Genre toEntity() => Genre(id: id, name: name, isDefault: isDefault);
}

extension GenreEntityToCompanion on Genre {
  GenresTableCompanion toCompanion() => GenresTableCompanion(
    id: Value(id),
    name: Value(name),
    isDefault: Value(isDefault),
  );
}

extension SubgenreDataToEntity on SubgenresTableData {
  Subgenre toEntity() =>
      Subgenre(id: id, name: name, genreId: genreId, isDefault: isDefault);
}

extension SubgenreEntityToCompanion on Subgenre {
  SubgenresTableCompanion toCompanion() => SubgenresTableCompanion(
    id: Value(id),
    name: Value(name),
    genreId: Value(genreId),
    isDefault: Value(isDefault),
  );
}

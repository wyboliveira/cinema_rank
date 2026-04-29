import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/logger.dart';
import 'daos/genre_dao.dart';
import 'daos/movie_dao.dart';
import 'daos/ranking_list_dao.dart';
import 'tables/app_settings_table.dart';
import 'tables/genres_table.dart';
import 'tables/movies_table.dart';
import 'tables/ranking_items_table.dart';
import 'tables/ranking_lists_table.dart';
import 'tables/subgenres_table.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    MoviesTable,
    RankingListsTable,
    RankingItemsTable,
    GenresTable,
    SubgenresTable,
    AppSettingsTable,
  ],
  daos: [MovieDao, RankingListDao, GenreDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => AppConstants.kDatabaseVersion;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      AppLogger.info('Criando banco de dados (v${AppConstants.kDatabaseVersion})');
      await m.createAll();
      await _seedDefaultGenres();
    },
    onUpgrade: (m, from, to) async {
      AppLogger.info('Migrando banco', {'de': from, 'para': to});
      if (from < 2) {
        // Adiciona colunas de gênero estruturado na tabela de filmes.
        await m.addColumn(moviesTable, moviesTable.genreId);
        await m.addColumn(moviesTable, moviesTable.subGenreId);
        // Cria as novas tabelas de v2.
        await m.createTable(genresTable);
        await m.createTable(subgenresTable);
        await m.createTable(appSettingsTable);
        await _seedDefaultGenres();
      }
    },
  );

  // Lê/escreve uma preferência simples da tabela app_settings.
  Future<String?> getSetting(String key) async {
    final row = await (select(appSettingsTable)
          ..where((t) => t.key.equals(key)))
        .getSingleOrNull();
    return row?.value;
  }

  Future<void> setSetting(String key, String value) =>
      into(appSettingsTable).insertOnConflictUpdate(
        AppSettingsTableCompanion(
          key: Value(key),
          value: Value(value),
        ),
      );

  // Popula os gêneros e subgêneros padrão na primeira execução.
  Future<void> _seedDefaultGenres() async {
    const uuid = Uuid();

    final seed = <String, List<String>>{
      'Ação': ['Espionagem', 'Artes Marciais', 'Militar', 'Super-heróis', 'Policial'],
      'Animação': ['Infantil', 'Adulta', 'Anime', 'Stop Motion', 'CGI'],
      'Aventura': ['Épico', 'Exploração', 'Sobrevivência', 'Pirataria'],
      'Comédia': ['Pastelão', 'Romântica', 'Satírica', 'Situacional', 'Absurda', 'Stand-up'],
      'Crime / Policial': ['Noir', 'Gangster', 'Julgamento', 'Detetive', 'Assalto'],
      'Documentário': ['Natureza', 'Biográfico', 'Histórico', 'Político', 'Musical', 'Esportivo'],
      'Drama': ['Familiar', 'Social', 'Histórico', 'Psicológico', 'Judicial', 'Adolescente'],
      'Fantasia': ['Alta Fantasia', 'Fantasia Urbana', 'Dark Fantasy', 'Mitológica', 'Steampunk'],
      'Ficção Científica': ['Distopia', 'Space Opera', 'Cyberpunk', 'Viagem no Tempo', 'Pós-apocalíptico', 'IA'],
      'Horror / Terror': ['Sobrenatural', 'Slasher', 'Psicológico', 'Zumbi', 'Gore', 'Gótico'],
      'Musical': ['Comédia Musical', 'Drama Musical', 'Biográfico Musical', 'Ópera', 'Dança'],
      'Mistério': ['Assassinato', 'Paranormal', 'Detetive', 'Whodunit'],
      'Romance': ['Histórico', 'Contemporâneo', 'Drama Romântico', 'Comédia Romântica'],
      'Suspense / Thriller': ['Político', 'Psicológico', 'Tecnológico', 'Espionagem', 'Jurídico'],
      'Western': ['Clássico', 'Spaghetti Western', 'Neo-Western', 'Space Western'],
      'Biografia': ['Artista', 'Político', 'Esportista', 'Científica', 'Musical'],
    };

    for (final entry in seed.entries) {
      final genreId = uuid.v4();
      await into(genresTable).insertOnConflictUpdate(
        GenresTableCompanion(
          id: Value(genreId),
          name: Value(entry.key),
          isDefault: const Value(true),
        ),
      );
      for (final subName in entry.value) {
        await into(subgenresTable).insertOnConflictUpdate(
          SubgenresTableCompanion(
            id: Value(uuid.v4()),
            name: Value(subName),
            genreId: Value(genreId),
            isDefault: const Value(true),
          ),
        );
      }
    }
    AppLogger.info('Seed de gêneros aplicado', {'total': seed.length});
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationSupportDirectory();
    final file = File(p.join(dir.path, AppConstants.kDatabaseFileName));
    AppLogger.debug('Abrindo banco', {'path': file.path});
    return NativeDatabase.createInBackground(file);
  });
}

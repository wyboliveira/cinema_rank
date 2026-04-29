import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/logger.dart';
import 'daos/movie_dao.dart';
import 'daos/ranking_list_dao.dart';
import 'tables/movies_table.dart';
import 'tables/ranking_items_table.dart';
import 'tables/ranking_lists_table.dart';

part 'app_database.g.dart';

// 📖 @DriftDatabase registra as tabelas e DAOs que o build_runner deve
// considerar ao gerar _$AppDatabase (a implementação concreta do banco).
@DriftDatabase(
  tables: [MoviesTable, RankingListsTable, RankingItemsTable],
  daos: [MovieDao, RankingListDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  // 📖 schemaVersion deve ser incrementado a cada alteração de schema.
  // O Drift usa esse número para executar os passos de migração corretos.
  @override
  int get schemaVersion => AppConstants.kDatabaseVersion;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      AppLogger.info('Criando banco de dados (v${AppConstants.kDatabaseVersion})');
      await m.createAll();
    },
    onUpgrade: (m, from, to) async {
      AppLogger.info('Migrando banco', {'de': from, 'para': to});
      // Passos de migração serão adicionados aqui conforme o schema evoluir.
    },
  );
}

// Abre (ou cria) o arquivo SQLite na pasta de dados do app.
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationSupportDirectory();
    final file = File(p.join(dir.path, AppConstants.kDatabaseFileName));
    AppLogger.debug('Abrindo banco', {'path': file.path});
    return NativeDatabase.createInBackground(file);
  });
}

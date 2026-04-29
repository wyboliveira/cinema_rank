import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database/app_database.dart';
import '../../data/repositories/movie_repository_impl.dart';
import '../../data/repositories/ranking_list_repository_impl.dart';
import '../../domain/repositories/movie_repository.dart';
import '../../domain/repositories/ranking_list_repository.dart';

// 📖 Provider singleton do banco de dados: criado uma vez, reutilizado em toda
// a aplicação. O Riverpod garante que só existe uma instância de AppDatabase.
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  // Fecha o banco quando o provider for descartado (ex: hot restart em testes).
  ref.onDispose(db.close);
  return db;
});

// Providers de repositório injetam o banco via appDatabaseProvider.
// A presentation/ só enxerga a interface abstrata (MovieRepository),
// nunca a implementação concreta (MovieRepositoryImpl).
final movieRepositoryProvider = Provider<MovieRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return MovieRepositoryImpl(db.movieDao);
});

final rankingListRepositoryProvider = Provider<RankingListRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return RankingListRepositoryImpl(db.rankingListDao);
});

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database/app_database.dart';
import '../../data/repositories/genre_repository_impl.dart';
import '../../data/repositories/movie_repository_impl.dart';
import '../../data/repositories/ranking_list_repository_impl.dart';
import '../../domain/repositories/genre_repository.dart';
import '../../domain/repositories/movie_repository.dart';
import '../../domain/repositories/ranking_list_repository.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final movieRepositoryProvider = Provider<MovieRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return MovieRepositoryImpl(db.movieDao);
});

final rankingListRepositoryProvider = Provider<RankingListRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return RankingListRepositoryImpl(db.rankingListDao);
});

final genreRepositoryProvider = Provider<GenreRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return GenreRepositoryImpl(db.genreDao);
});

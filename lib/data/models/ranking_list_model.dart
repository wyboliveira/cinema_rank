import 'package:drift/drift.dart';

import '../../domain/entities/ranking_item.dart';
import '../../domain/entities/ranking_list.dart';
import '../database/app_database.dart';

extension RankingListDataToEntity on RankingListsTableData {
  RankingList toEntity() => RankingList(
    id: id,
    title: title,
    category: category,
    createdAt: DateTime.fromMillisecondsSinceEpoch(createdAt),
  );
}

extension RankingListEntityToCompanion on RankingList {
  RankingListsTableCompanion toCompanion() => RankingListsTableCompanion(
    id: Value(id),
    title: Value(title),
    category: Value(category),
    createdAt: Value(createdAt.millisecondsSinceEpoch),
  );
}

extension RankingItemDataToEntity on RankingItemsTableData {
  RankingItem toEntity() => RankingItem(
    id: id,
    listId: listId,
    movieId: movieId,
    position: position,
  );
}

extension RankingItemEntityToCompanion on RankingItem {
  RankingItemsTableCompanion toCompanion() => RankingItemsTableCompanion(
    id: Value(id),
    listId: Value(listId),
    movieId: Value(movieId),
    position: Value(position),
  );
}

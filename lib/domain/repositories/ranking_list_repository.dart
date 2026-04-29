import '../entities/ranking_item.dart';
import '../entities/ranking_list.dart';

// Contrato abstrato para listas de ranking e seus itens.
abstract class RankingListRepository {
  Future<List<RankingList>> getAll();

  Future<void> save(RankingList list);

  Future<void> delete(String listId);

  // Adiciona um filme a uma lista; position = último + 1.
  Future<void> addItem(RankingItem item);

  // Remove um filme de uma lista e reordena as posições restantes.
  Future<void> removeItem(String itemId, String listId);

  // Persiste a nova ordem após um drag-and-drop em transação atômica.
  Future<void> reorderItems(String listId, List<RankingItem> items);

  Stream<List<RankingList>> watchAll();

  Stream<List<RankingItem>> watchItemsByList(String listId);
}

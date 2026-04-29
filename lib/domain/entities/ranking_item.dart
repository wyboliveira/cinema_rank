// Item de uma lista de ranking: associa um filme a uma lista com uma posição.
// position é 1-based para facilitar exibição ao usuário sem conversão.
class RankingItem {
  const RankingItem({
    required this.id,
    required this.listId,
    required this.movieId,
    required this.position,
  });

  final String id;
  final String listId;
  final String movieId;
  final int position;

  RankingItem copyWith({
    String? id,
    String? listId,
    String? movieId,
    int? position,
  }) {
    return RankingItem(
      id: id ?? this.id,
      listId: listId ?? this.listId,
      movieId: movieId ?? this.movieId,
      position: position ?? this.position,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is RankingItem && other.id == id);

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'RankingItem(id: $id, listId: $listId, movieId: $movieId, pos: $position)';
}

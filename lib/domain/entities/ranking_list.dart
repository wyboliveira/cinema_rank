// Lista de ranking criada pelo usuário (ex: "Melhores de 2024", "Top Terror").
class RankingList {
  const RankingList({
    required this.id,
    required this.title,
    required this.category,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String category;
  final DateTime createdAt;

  RankingList copyWith({
    String? id,
    String? title,
    String? category,
    DateTime? createdAt,
  }) {
    return RankingList(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is RankingList && other.id == id);

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'RankingList(id: $id, title: $title)';
}

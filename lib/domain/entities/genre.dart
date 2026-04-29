class Genre {
  const Genre({
    required this.id,
    required this.name,
    this.isDefault = false,
  });

  final String id;
  final String name;
  final bool isDefault;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Genre && other.id == id);

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Genre(id: $id, name: $name)';
}

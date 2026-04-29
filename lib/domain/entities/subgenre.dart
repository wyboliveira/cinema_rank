class Subgenre {
  const Subgenre({
    required this.id,
    required this.name,
    required this.genreId,
    this.isDefault = false,
  });

  final String id;
  final String name;
  final String genreId;
  final bool isDefault;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Subgenre && other.id == id);

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Subgenre(id: $id, name: $name, genreId: $genreId)';
}

class CategoryEntity {
  const CategoryEntity({
    required this.id,
    required this.name,
    this.iconUrl,
    this.colorHex,
    this.sortOrder = 0,
  });

  final String id;
  final String name;
  final String? iconUrl;
  final String? colorHex;
  final int sortOrder;

  factory CategoryEntity.fromJson(Map<String, dynamic> json) {
    return CategoryEntity(
      id: json['id'] as String,
      name: (json['name'] as String?)?.trim() ?? '',
      iconUrl: json['icon_url'] as String?,
      colorHex: json['color_hex'] as String?,
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
    );
  }
}

class Category {
  final String id;
  final String name;
  final int colorValue;
  final int sortOrder;
  final bool isDefault;
  final bool isDeleted;
  final int createdAt;

  const Category({
    required this.id,
    required this.name,
    required this.colorValue,
    this.sortOrder = 0,
    this.isDefault = false,
    this.isDeleted = false,
    required this.createdAt,
  });

  Category copyWith({
    String? id,
    String? name,
    int? colorValue,
    int? sortOrder,
    bool? isDefault,
    bool? isDeleted,
    int? createdAt,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      colorValue: colorValue ?? this.colorValue,
      sortOrder: sortOrder ?? this.sortOrder,
      isDefault: isDefault ?? this.isDefault,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'color_value': colorValue,
      'sort_order': sortOrder,
      'is_default': isDefault ? 1 : 0,
      'is_deleted': isDeleted ? 1 : 0,
      'created_at': createdAt,
    };
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] as String,
      name: map['name'] as String,
      colorValue: map['color_value'] as int,
      sortOrder: map['sort_order'] as int? ?? 0,
      isDefault: (map['is_default'] as int?) == 1,
      isDeleted: (map['is_deleted'] as int?) == 1,
      createdAt: map['created_at'] as int,
    );
  }
}

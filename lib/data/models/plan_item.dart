enum PlanItemType { todo, memo }

class PlanItem {
  final String id;
  final String content;
  final PlanItemType itemType;
  final bool isCompleted;
  final int createdAt;
  final int? completedAt;
  final bool isDeleted;

  const PlanItem({
    required this.id,
    required this.content,
    this.itemType = PlanItemType.todo,
    this.isCompleted = false,
    required this.createdAt,
    this.completedAt,
    this.isDeleted = false,
  });

  PlanItem copyWith({
    String? id,
    String? content,
    PlanItemType? itemType,
    bool? isCompleted,
    int? createdAt,
    int? completedAt,
    bool? isDeleted,
  }) {
    return PlanItem(
      id: id ?? this.id,
      content: content ?? this.content,
      itemType: itemType ?? this.itemType,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'content': content,
      'item_type': itemType.index,
      'is_completed': isCompleted ? 1 : 0,
      'created_at': createdAt,
      'completed_at': completedAt,
      'is_deleted': isDeleted ? 1 : 0,
    };
  }

  factory PlanItem.fromMap(Map<String, dynamic> map) {
    return PlanItem(
      id: map['id'] as String,
      content: map['content'] as String,
      itemType: PlanItemType.values[map['item_type'] as int? ?? 0],
      isCompleted: (map['is_completed'] as int?) == 1,
      createdAt: map['created_at'] as int,
      completedAt: map['completed_at'] as int?,
      isDeleted: (map['is_deleted'] as int?) == 1,
    );
  }
}

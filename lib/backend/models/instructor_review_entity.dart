class InstructorReviewEntity {
  const InstructorReviewEntity({
    required this.id,
    required this.instructorId,
    required this.userId,
    required this.rating,
    this.comment,
    this.authorName = '',
    this.authorAvatarUrl,
    this.createdAt,
  });

  final String id;
  final String instructorId;
  final String userId;
  final double rating;
  final String? comment;
  final String authorName;
  final String? authorAvatarUrl;
  final DateTime? createdAt;

  factory InstructorReviewEntity.fromJson(Map<String, dynamic> json) {
    final profile = json['profiles'];
    String name = '';
    String? avatar;
    if (profile is Map) {
      final map = Map<String, dynamic>.from(profile);
      final first = (map['first_name'] as String?)?.trim() ?? '';
      final last = (map['last_name'] as String?)?.trim() ?? '';
      final userName = (map['user_name'] as String?)?.trim() ?? '';
      name = '$first $last'.trim();
      if (name.isEmpty) name = userName;
      avatar = map['avatar_url'] as String?;
    }

    return InstructorReviewEntity(
      id: json['id'] as String,
      instructorId: json['instructor_id'] as String,
      userId: json['user_id'] as String,
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      comment: json['comment'] as String?,
      authorName: name.isEmpty ? 'Student' : name,
      authorAvatarUrl: avatar,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }
}

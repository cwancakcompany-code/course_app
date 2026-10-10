class InstructorEntity {
  const InstructorEntity({
    required this.id,
    required this.displayName,
    this.title,
    this.bio,
    this.avatarUrl,
    this.coursesCount = 0,
    this.studentsCount = 0,
    this.reviewsCount = 0,
  });

  final String id;
  final String displayName;
  final String? title;
  final String? bio;
  final String? avatarUrl;
  final int coursesCount;
  final int studentsCount;
  final int reviewsCount;

  factory InstructorEntity.fromJson(Map<String, dynamic> json) {
    return InstructorEntity(
      id: json['id'] as String,
      displayName: (json['display_name'] as String?)?.trim() ?? '',
      title: json['title'] as String?,
      bio: json['bio'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      coursesCount: _embeddedCount(json['courses']),
      studentsCount: (json['students_count'] as num?)?.toInt() ?? 0,
      reviewsCount: (json['reviews_count'] as num?)?.toInt() ?? 0,
    );
  }

  static int _embeddedCount(dynamic value) {
    if (value is List && value.isNotEmpty) {
      final first = value.first;
      if (first is Map && first['count'] != null) {
        return (first['count'] as num).toInt();
      }
    }
    if (value is Map && value['count'] != null) {
      return (value['count'] as num).toInt();
    }
    return 0;
  }
}

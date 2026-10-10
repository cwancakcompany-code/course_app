class CourseEntity {
  const CourseEntity({
    required this.id,
    required this.title,
    this.subtitle,
    this.description,
    this.thumbnailUrl,
    this.previewVideoUrl,
    this.price = 0,
    this.currency = 'USD',
    this.ratingAvg = 0,
    this.ratingCount = 0,
    this.lessonsCount = 0,
    this.enrollmentsCount = 0,
    this.isRecommended = false,
    this.isPopular = false,
    this.hasCertificate = true,
    this.level,
    this.categoryId,
    this.instructorId,
    this.instructorName,
    this.instructorAvatarUrl,
    this.instructorTitle,
    this.categoryName,
    this.publishedAt,
  });

  final String id;
  final String title;
  final String? subtitle;
  final String? description;
  final String? thumbnailUrl;
  final String? previewVideoUrl;
  final double price;
  final String currency;
  final double ratingAvg;
  final int ratingCount;
  final int lessonsCount;
  final int enrollmentsCount;
  final bool isRecommended;
  final bool isPopular;
  final bool hasCertificate;
  final String? level;
  final String? categoryId;
  final String? instructorId;
  final String? instructorName;
  final String? instructorAvatarUrl;
  final String? instructorTitle;
  final String? categoryName;
  final DateTime? publishedAt;

  factory CourseEntity.fromJson(Map<String, dynamic> json) {
    final instructor = json['instructors'];
    final category = json['categories'];
    Map<String, dynamic>? instructorMap;
    Map<String, dynamic>? categoryMap;

    if (instructor is Map<String, dynamic>) {
      instructorMap = instructor;
    } else if (instructor is List && instructor.isNotEmpty) {
      instructorMap = Map<String, dynamic>.from(instructor.first as Map);
    }
    if (category is Map<String, dynamic>) {
      categoryMap = category;
    } else if (category is List && category.isNotEmpty) {
      categoryMap = Map<String, dynamic>.from(category.first as Map);
    }

    return CourseEntity(
      id: json['id'] as String,
      title: (json['title'] as String?)?.trim() ?? '',
      subtitle: json['subtitle'] as String?,
      description: json['description'] as String?,
      thumbnailUrl: json['thumbnail_url'] as String?,
      previewVideoUrl: json['preview_video_url'] as String?,
      price: (json['price'] as num?)?.toDouble() ?? 0,
      currency: (json['currency'] as String?) ?? 'USD',
      ratingAvg: (json['rating_avg'] as num?)?.toDouble() ?? 0,
      ratingCount: (json['rating_count'] as num?)?.toInt() ?? 0,
      lessonsCount: (json['lessons_count'] as num?)?.toInt() ?? 0,
      enrollmentsCount: (json['enrollments_count'] as num?)?.toInt() ?? 0,
      isRecommended: json['is_recommended'] as bool? ?? false,
      isPopular: json['is_popular'] as bool? ?? false,
      hasCertificate: json['has_certificate'] as bool? ?? true,
      level: json['level'] as String?,
      categoryId: json['category_id'] as String?,
      instructorId: json['instructor_id'] as String?,
      instructorName: instructorMap?['display_name'] as String?,
      instructorAvatarUrl: instructorMap?['avatar_url'] as String?,
      instructorTitle: instructorMap?['title'] as String?,
      categoryName: categoryMap?['name'] as String?,
      publishedAt: json['published_at'] != null
          ? DateTime.tryParse(json['published_at'].toString())
          : null,
    );
  }
}

import 'lesson_entity.dart';

class CourseSectionEntity {
  const CourseSectionEntity({
    required this.id,
    required this.courseId,
    required this.title,
    this.sortOrder = 0,
    this.durationMinutes = 0,
    this.lessons = const [],
  });

  final String id;
  final String courseId;
  final String title;
  final int sortOrder;
  final int durationMinutes;
  final List<LessonEntity> lessons;

  CourseSectionEntity copyWith({List<LessonEntity>? lessons}) {
    return CourseSectionEntity(
      id: id,
      courseId: courseId,
      title: title,
      sortOrder: sortOrder,
      durationMinutes: durationMinutes,
      lessons: lessons ?? this.lessons,
    );
  }

  factory CourseSectionEntity.fromJson(Map<String, dynamic> json) {
    final rawLessons = json['lessons'];
    final lessons = <LessonEntity>[];
    if (rawLessons is List) {
      for (final item in rawLessons) {
        if (item is Map<String, dynamic>) {
          lessons.add(LessonEntity.fromJson(item));
        } else if (item is Map) {
          lessons.add(LessonEntity.fromJson(Map<String, dynamic>.from(item)));
        }
      }
      lessons.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    }

    return CourseSectionEntity(
      id: json['id'] as String,
      courseId: json['course_id'] as String,
      title: (json['title'] as String?)?.trim() ?? '',
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
      durationMinutes: (json['duration_minutes'] as num?)?.toInt() ?? 0,
      lessons: lessons,
    );
  }
}

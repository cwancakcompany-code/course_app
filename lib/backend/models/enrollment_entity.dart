import '/backend/models/course_entity.dart';

class EnrollmentEntity {
  const EnrollmentEntity({
    required this.id,
    required this.userId,
    required this.courseId,
    required this.status,
    this.progressPercent = 0,
    this.completedLessons = 0,
    this.totalLessons = 0,
    this.enrolledAt,
    this.completedAt,
    this.course,
  });

  final String id;
  final String userId;
  final String courseId;
  final String status; // ongoing | completed | cancelled
  final double progressPercent;
  final int completedLessons;
  final int totalLessons;
  final DateTime? enrolledAt;
  final DateTime? completedAt;
  final CourseEntity? course;

  bool get isOngoing => status == 'ongoing';
  bool get isCompleted => status == 'completed';

  factory EnrollmentEntity.fromJson(Map<String, dynamic> json) {
    CourseEntity? course;
    final rawCourse = json['courses'];
    if (rawCourse is Map<String, dynamic>) {
      course = CourseEntity.fromJson(rawCourse);
    } else if (rawCourse is Map) {
      course = CourseEntity.fromJson(Map<String, dynamic>.from(rawCourse));
    }

    return EnrollmentEntity(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      courseId: json['course_id'] as String,
      status: (json['status'] as String?) ?? 'ongoing',
      progressPercent: (json['progress_percent'] as num?)?.toDouble() ?? 0,
      completedLessons: (json['completed_lessons'] as num?)?.toInt() ?? 0,
      totalLessons: (json['total_lessons'] as num?)?.toInt() ?? 0,
      enrolledAt: _parseDate(json['enrolled_at'] ?? json['created_at']),
      completedAt: _parseDate(json['completed_at']),
      course: course,
    );
  }

  static DateTime? _parseDate(dynamic raw) {
    if (raw is String && raw.isNotEmpty) return DateTime.tryParse(raw);
    return null;
  }
}

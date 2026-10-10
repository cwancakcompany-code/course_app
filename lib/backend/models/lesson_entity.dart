class LessonEntity {
  const LessonEntity({
    required this.id,
    required this.courseId,
    required this.sectionId,
    required this.title,
    this.videoUrl,
    this.durationSeconds = 0,
    this.sortOrder = 0,
    this.isFreePreview = false,
  });

  final String id;
  final String courseId;
  final String sectionId;
  final String title;
  final String? videoUrl;
  final int durationSeconds;
  final int sortOrder;
  final bool isFreePreview;

  factory LessonEntity.fromJson(Map<String, dynamic> json) {
    return LessonEntity(
      id: json['id'] as String,
      courseId: json['course_id'] as String,
      sectionId: json['section_id'] as String,
      title: (json['title'] as String?)?.trim() ?? '',
      videoUrl: json['video_url'] as String?,
      durationSeconds: _parseDurationSeconds(json),
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
      isFreePreview: json['is_free_preview'] as bool? ?? false,
    );
  }

  static int _parseDurationSeconds(Map<String, dynamic> json) {
    final seconds = (json['duration_seconds'] as num?)?.toInt();
    if (seconds != null && seconds > 0) return seconds;

    final minutes = (json['duration_minutes'] as num?)?.toInt();
    if (minutes != null && minutes > 0) return minutes * 60;

    final raw = json['duration'];
    if (raw is num && raw > 0) {
      // Heuristic: values under 1000 are minutes; larger are seconds.
      final n = raw.toInt();
      return n < 1000 ? n * 60 : n;
    }
    if (raw is String) {
      final trimmed = raw.trim();
      // Support "mm:ss" or "hh:mm:ss"
      if (trimmed.contains(':')) {
        final parts = trimmed.split(':').map(int.tryParse).toList();
        if (parts.every((p) => p != null)) {
          if (parts.length == 2) {
            return parts[0]! * 60 + parts[1]!;
          }
          if (parts.length == 3) {
            return parts[0]! * 3600 + parts[1]! * 60 + parts[2]!;
          }
        }
      }
      final asNum = num.tryParse(trimmed);
      if (asNum != null && asNum > 0) {
        final n = asNum.toInt();
        return n < 1000 ? n * 60 : n;
      }
    }
    return 0;
  }
}

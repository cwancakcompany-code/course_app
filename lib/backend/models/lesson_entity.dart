class LessonEntity {
  const LessonEntity({
    required this.id,
    required this.courseId,
    required this.sectionId,
    required this.title,
    this.videoUrl,
    this.pdfUrl,
    this.lessonType = 'video',
    this.durationSeconds = 0,
    this.sortOrder = 0,
    this.isFreePreview = false,
  });

  final String id;
  final String courseId;
  final String sectionId;
  final String title;
  final String? videoUrl;
  /// Storage path (`lesson_resources/...`) or legacy HTTP URL.
  final String? pdfUrl;
  final String lessonType;
  final int durationSeconds;
  final int sortOrder;
  final bool isFreePreview;

  bool get hasPdf {
    final pdf = (pdfUrl ?? '').trim();
    if (pdf.isNotEmpty) return true;
    final video = (videoUrl ?? '').trim().toLowerCase();
    return video.contains('.pdf');
  }

  bool get hasVideo {
    final video = (videoUrl ?? '').trim();
    if (video.isEmpty) return false;
    return !video.toLowerCase().contains('.pdf');
  }

  bool get isPdfLesson =>
      lessonType.toLowerCase() == 'pdf' || (hasPdf && !hasVideo);

  String? get resolvedPdfUrl {
    final pdf = (pdfUrl ?? '').trim();
    if (pdf.isNotEmpty) return pdf;
    final video = (videoUrl ?? '').trim();
    if (video.toLowerCase().contains('.pdf')) return video;
    return null;
  }

  factory LessonEntity.fromJson(Map<String, dynamic> json) {
    return LessonEntity(
      id: json['id'] as String,
      courseId: json['course_id'] as String? ?? '',
      sectionId: json['section_id'] as String? ?? '',
      title: (json['title'] as String?)?.trim() ?? '',
      videoUrl: json['video_url'] as String?,
      pdfUrl: _resolvePdfPath(json),
      lessonType: (json['lesson_type'] as String?)?.trim().isNotEmpty == true
          ? (json['lesson_type'] as String).trim()
          : 'video',
      durationSeconds: _parseDurationSeconds(json),
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
      isFreePreview: json['is_free_preview'] as bool? ?? false,
    );
  }

  /// Admin panel: PDF lives in `lesson_resources.file_url`, not `lessons.pdf_url`.
  static String? _resolvePdfPath(Map<String, dynamic> json) {
    final fromColumn = (json['pdf_url'] as String?)?.trim();
    if (fromColumn != null && fromColumn.isNotEmpty) return fromColumn;

    final resources = json['lesson_resources'];
    final list = <Map<String, dynamic>>[];
    if (resources is List) {
      for (final item in resources) {
        if (item is Map<String, dynamic>) {
          list.add(item);
        } else if (item is Map) {
          list.add(Map<String, dynamic>.from(item));
        }
      }
    } else if (resources is Map) {
      list.add(Map<String, dynamic>.from(resources));
    }

    list.sort((a, b) {
      final ao = (a['sort_order'] as num?)?.toInt() ?? 0;
      final bo = (b['sort_order'] as num?)?.toInt() ?? 0;
      return ao.compareTo(bo);
    });

    for (final r in list) {
      final url = (r['file_url'] as String?)?.trim() ?? '';
      if (url.isEmpty) continue;
      final type = (r['file_type'] as String?)?.toLowerCase() ?? '';
      if (type == 'application/pdf' ||
          url.toLowerCase().endsWith('.pdf') ||
          url.startsWith('lesson_resources/')) {
        return url;
      }
    }

    // Legacy: PDF path was briefly stored in lessons.content
    final content = (json['content'] as String?)?.trim() ?? '';
    if (content.startsWith('lesson_resources/')) return content;

    return null;
  }

  static int _parseDurationSeconds(Map<String, dynamic> json) {
    final seconds = (json['duration_seconds'] as num?)?.toInt();
    if (seconds != null && seconds > 0) return seconds;

    final minutes = (json['duration_minutes'] as num?)?.toInt();
    if (minutes != null && minutes > 0) return minutes * 60;

    final raw = json['duration'];
    if (raw is num && raw > 0) {
      final n = raw.toInt();
      return n < 1000 ? n * 60 : n;
    }
    if (raw is String) {
      final trimmed = raw.trim();
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

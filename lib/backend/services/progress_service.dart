import 'package:flutter/foundation.dart';

import '/backend/repositories/lesson_progress_repository.dart';
import '/backend/services/enrollment_service.dart';

class ProgressService {
  ProgressService({
    LessonProgressRepository? repository,
    EnrollmentService? enrollmentService,
  })  : _repo = repository ?? SupabaseLessonProgressRepository(),
        _enrollments = enrollmentService ?? EnrollmentService();

  final LessonProgressRepository _repo;
  final EnrollmentService _enrollments;

  /// Marks a lesson complete and refreshes My Course lists.
  Future<void> markLessonOpened({
    required String lessonId,
    bool refreshMyCourses = true,
  }) async {
    final id = lessonId.trim();
    if (id.isEmpty) return;
    try {
      await _repo.markLessonCompleted(id);
      if (refreshMyCourses) {
        await _enrollments.loadMyCourses();
      }
    } catch (e) {
      debugPrint('ProgressService.markLessonOpened: $e');
    }
  }
}

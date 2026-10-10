import 'package:flutter/foundation.dart';

import '/app_state.dart';
import '/backend/media/media_url_resolver.dart';
import '/backend/models/enrollment_entity.dart';
import '/backend/repositories/enrollment_repository.dart';
import '/backend/schema/structs/completed_model_struct.dart';
import '/backend/schema/structs/ongoing_model_struct.dart';
import '/backend/schema/structs/recommended_for_you_model_struct.dart';
import '/backend/services/auth_service.dart';
import '/backend/utils/price_formatter.dart';

class EnrollmentService {
  EnrollmentService({EnrollmentRepository? repository})
      : _repo = repository ?? SupabaseEnrollmentRepository();

  final EnrollmentRepository _repo;
  static const _media = MediaUrlResolver();

  Future<bool> isEnrolled(String courseId) => _repo.isEnrolled(courseId);

  Future<EnrollmentEntity?> enrollmentForCourse(String courseId) =>
      _repo.fetchMineForCourse(courseId);

  /// Loads My Course lists from DB into FFAppState.
  Future<({List<EnrollmentEntity> ongoing, List<EnrollmentEntity> completed})>
      loadMyCourses({bool syncAppState = true}) async {
    if (!AuthService().isSignedIn) {
      if (syncAppState) {
        FFAppState().update(() {
          FFAppState().OngoingList = [];
          FFAppState().CompletedList = [];
        });
      }
      return (ongoing: <EnrollmentEntity>[], completed: <EnrollmentEntity>[]);
    }

    try {
      final all = await _repo.fetchMine();
      final ongoing = all.where((e) => e.isOngoing).toList(growable: false);
      final completed = all.where((e) => e.isCompleted).toList(growable: false);

      if (syncAppState) {
        FFAppState().update(() {
          FFAppState().OngoingList =
              ongoing.map(_toOngoingStruct).toList(growable: false);
          FFAppState().CompletedList =
              completed.map(_toCompletedStruct).toList(growable: false);
        });
      }
      return (ongoing: ongoing, completed: completed);
    } catch (e, st) {
      debugPrint('loadMyCourses failed: $e');
      debugPrint('$st');
      rethrow;
    }
  }

  RecommendedForYouModelStruct toCourseCard(EnrollmentEntity e) {
    final c = e.course;
    final thumb = _media.resolveImage(c?.thumbnailUrl);
    final bunny = thumb.isEmpty
        ? _media.bunnyThumbnail(c?.previewVideoUrl)
        : '';
    return RecommendedForYouModelStruct(
      id: e.courseId,
      image: thumb.isNotEmpty ? thumb : bunny,
      title: c?.title ?? 'Course',
      subtitle: c?.subtitle ?? '',
      instructorName: c?.instructorName ?? '',
      profileImage: _media.resolveImage(c?.instructorAvatarUrl),
      price: c == null
          ? ''
          : PriceFormatter.format(c.price, currency: c.currency),
      rating: c?.ratingAvg ?? 0,
      subject: c?.categoryName ?? '',
    );
  }

  OngoingModelStruct _toOngoingStruct(EnrollmentEntity e) {
    final c = e.course;
    final thumb = _media.resolveImage(c?.thumbnailUrl);
    final total = e.totalLessons > 0
        ? e.totalLessons
        : (c?.lessonsCount ?? 0);
    final done = e.completedLessons;
    return OngoingModelStruct(
      id: e.courseId,
      image: thumb,
      title: c?.title ?? 'Course',
      time: _formatDurationMinutes(c?.durationMinutes),
      running: done,
      totalCourse: total > 0 ? total : 1,
    );
  }

  CompletedModelStruct _toCompletedStruct(EnrollmentEntity e) {
    final c = e.course;
    final thumb = _media.resolveImage(c?.thumbnailUrl);
    return CompletedModelStruct(
      id: e.courseId,
      image: thumb,
      title: c?.title ?? 'Course',
      time: _formatDurationMinutes(c?.durationMinutes),
    );
  }

  String _formatDurationMinutes(int? minutes) {
    final m = minutes ?? 0;
    if (m <= 0) return '';
    final h = m ~/ 60;
    final rem = m % 60;
    if (h <= 0) return '$rem min';
    if (rem == 0) return '$h hrs';
    return '$h hrs $rem min';
  }
}

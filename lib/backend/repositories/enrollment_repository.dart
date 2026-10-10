import 'package:supabase_flutter/supabase_flutter.dart';

import '/backend/models/enrollment_entity.dart';
import '/backend/supabase/supabase_bootstrap.dart';

abstract class EnrollmentRepository {
  Future<List<EnrollmentEntity>> fetchMine({String? status});
  Future<bool> isEnrolled(String courseId);
  Future<EnrollmentEntity?> fetchMineForCourse(String courseId);
}

class SupabaseEnrollmentRepository implements EnrollmentRepository {
  SupabaseEnrollmentRepository({SupabaseClient? client})
      : _client = client ?? SupabaseBootstrap.client;

  final SupabaseClient _client;

  /// Live table uses `created_at` (not `enrolled_at`).
  static const _select = '''
id, user_id, course_id, status, progress_percent, completed_lessons,
total_lessons, created_at, completed_at, updated_at,
courses(
  id, title, subtitle, thumbnail_url, preview_video_url, duration_minutes,
  lessons_count, category_id, price, currency, rating_avg,
  rating_count, enrollments_count, is_published, status, level
)
''';

  @override
  Future<List<EnrollmentEntity>> fetchMine({String? status}) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return const [];

    var query = _client.from('enrollments').select(_select).eq('user_id', userId);

    if (status != null && status.isNotEmpty) {
      query = query.eq('status', status);
    } else {
      query = query.inFilter('status', ['ongoing', 'completed']);
    }

    final rows = await query.order('created_at', ascending: false);

    return (rows as List)
        .map((row) => EnrollmentEntity.fromJson(Map<String, dynamic>.from(row)))
        .toList(growable: false);
  }

  @override
  Future<bool> isEnrolled(String courseId) async {
    final row = await fetchMineForCourse(courseId);
    return row != null;
  }

  @override
  Future<EnrollmentEntity?> fetchMineForCourse(String courseId) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null || courseId.isEmpty) return null;

    final row = await _client
        .from('enrollments')
        .select(_select)
        .eq('user_id', userId)
        .eq('course_id', courseId)
        .inFilter('status', ['ongoing', 'completed'])
        .maybeSingle();

    if (row == null) return null;
    return EnrollmentEntity.fromJson(Map<String, dynamic>.from(row));
  }
}

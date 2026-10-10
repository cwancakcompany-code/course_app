import 'package:supabase_flutter/supabase_flutter.dart';

import '/backend/models/review_entity.dart';
import '/backend/supabase/supabase_bootstrap.dart';

abstract class ReviewRepository {
  Future<List<ReviewEntity>> fetchByCourse(String courseId, {int limit = 50});
  Future<ReviewEntity> upsertReview({
    required String courseId,
    required String userId,
    required double rating,
    String? comment,
  });
}

class SupabaseReviewRepository implements ReviewRepository {
  SupabaseReviewRepository({SupabaseClient? client})
      : _client = client ?? SupabaseBootstrap.client;

  final SupabaseClient _client;

  static const _select = '''
id, course_id, user_id, rating, comment, created_at,
profiles(first_name, last_name, user_name, avatar_url)
''';

  @override
  Future<List<ReviewEntity>> fetchByCourse(
    String courseId, {
    int limit = 50,
  }) async {
    final rows = await _client
        .from('reviews')
        .select(_select)
        .eq('course_id', courseId)
        .order('created_at', ascending: false)
        .limit(limit);

    return (rows as List)
        .map((row) => ReviewEntity.fromJson(Map<String, dynamic>.from(row)))
        .toList(growable: false);
  }

  @override
  Future<ReviewEntity> upsertReview({
    required String courseId,
    required String userId,
    required double rating,
    String? comment,
  }) async {
    final clamped = rating.clamp(1.0, 5.0);
    final row = await _client
        .from('reviews')
        .upsert(
          {
            'course_id': courseId,
            'user_id': userId,
            'rating': clamped,
            'comment': comment?.trim().isEmpty == true ? null : comment?.trim(),
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          },
          onConflict: 'course_id,user_id',
        )
        .select(_select)
        .single();

    // Keep denormalized course counters fresh (trigger also does this).
    try {
      await _client.rpc('refresh_course_rating', params: {
        'p_course_id': courseId,
      });
    } catch (_) {
      // Trigger / function may not be deployed yet — ignore.
    }

    return ReviewEntity.fromJson(Map<String, dynamic>.from(row));
  }
}

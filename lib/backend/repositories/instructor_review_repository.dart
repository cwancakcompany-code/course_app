import 'package:supabase_flutter/supabase_flutter.dart';

import '/backend/models/instructor_review_entity.dart';
import '/backend/supabase/supabase_bootstrap.dart';

abstract class InstructorReviewRepository {
  Future<List<InstructorReviewEntity>> fetchByInstructor(
    String instructorId, {
    int limit = 50,
  });

  Future<bool> canReview(String instructorId);

  Future<InstructorReviewEntity> upsertReview({
    required String instructorId,
    required String userId,
    required double rating,
    String? comment,
  });
}

class SupabaseInstructorReviewRepository
    implements InstructorReviewRepository {
  SupabaseInstructorReviewRepository({SupabaseClient? client})
      : _client = client ?? SupabaseBootstrap.client;

  final SupabaseClient _client;

  static const _select = '''
id, instructor_id, user_id, rating, comment, created_at,
profiles(first_name, last_name, user_name, avatar_url)
''';

  @override
  Future<List<InstructorReviewEntity>> fetchByInstructor(
    String instructorId, {
    int limit = 50,
  }) async {
    final rows = await _client
        .from('instructor_reviews')
        .select(_select)
        .eq('instructor_id', instructorId)
        .order('created_at', ascending: false)
        .limit(limit);

    return (rows as List)
        .map(
          (row) => InstructorReviewEntity.fromJson(
            Map<String, dynamic>.from(row),
          ),
        )
        .toList(growable: false);
  }

  @override
  Future<bool> canReview(String instructorId) async {
    try {
      final result = await _client.rpc(
        'user_enrolled_with_instructor',
        params: {'p_instructor_id': instructorId},
      );
      return result == true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<InstructorReviewEntity> upsertReview({
    required String instructorId,
    required String userId,
    required double rating,
    String? comment,
  }) async {
    final clamped = rating.clamp(1.0, 5.0);
    final row = await _client
        .from('instructor_reviews')
        .upsert(
          {
            'instructor_id': instructorId,
            'user_id': userId,
            'rating': clamped,
            'comment':
                comment?.trim().isEmpty == true ? null : comment?.trim(),
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          },
          onConflict: 'instructor_id,user_id',
        )
        .select(_select)
        .single();

    return InstructorReviewEntity.fromJson(Map<String, dynamic>.from(row));
  }
}

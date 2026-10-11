import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '/backend/supabase/supabase_bootstrap.dart';

abstract class LessonProgressRepository {
  Future<Map<String, dynamic>?> markLessonCompleted(String lessonId);
}

class SupabaseLessonProgressRepository implements LessonProgressRepository {
  SupabaseLessonProgressRepository({SupabaseClient? client})
      : _client = client ?? SupabaseBootstrap.client;

  final SupabaseClient _client;

  @override
  Future<Map<String, dynamic>?> markLessonCompleted(String lessonId) async {
    final id = lessonId.trim();
    if (id.isEmpty) return null;
    try {
      final result = await _client.rpc(
        'mark_lesson_completed',
        params: {'p_lesson_id': id},
      );
      if (result is Map) {
        return Map<String, dynamic>.from(result);
      }
      return null;
    } catch (e, st) {
      debugPrint('mark_lesson_completed failed: $e');
      debugPrint('$st');
      rethrow;
    }
  }
}

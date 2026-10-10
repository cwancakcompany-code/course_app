import 'package:supabase_flutter/supabase_flutter.dart';

import '/backend/models/course_section_entity.dart';
import '/backend/models/lesson_entity.dart';
import '/backend/supabase/supabase_bootstrap.dart';

abstract class LessonRepository {
  Future<List<CourseSectionEntity>> fetchSectionsWithLessons(String courseId);
  Future<List<LessonEntity>> fetchByCourse(String courseId);
}

class SupabaseLessonRepository implements LessonRepository {
  SupabaseLessonRepository({SupabaseClient? client})
      : _client = client ?? SupabaseBootstrap.client;

  final SupabaseClient _client;

  @override
  Future<List<CourseSectionEntity>> fetchSectionsWithLessons(
    String courseId,
  ) async {
    final rows = await _client
        .from('course_sections')
        .select('''
id, course_id, title, sort_order, duration_minutes,
lessons(id, course_id, section_id, title, video_url, duration_seconds, sort_order, is_free_preview)
''')
        .eq('course_id', courseId)
        .order('sort_order', ascending: true);

    return (rows as List)
        .map(
          (row) =>
              CourseSectionEntity.fromJson(Map<String, dynamic>.from(row)),
        )
        .toList(growable: false);
  }

  @override
  Future<List<LessonEntity>> fetchByCourse(String courseId) async {
    final rows = await _client
        .from('lessons')
        .select(
          'id, course_id, section_id, title, video_url, duration_seconds, sort_order, is_free_preview',
        )
        .eq('course_id', courseId)
        .order('sort_order', ascending: true);

    return (rows as List)
        .map((row) => LessonEntity.fromJson(Map<String, dynamic>.from(row)))
        .toList(growable: false);
  }
}

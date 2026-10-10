import 'package:supabase_flutter/supabase_flutter.dart';

import '/backend/models/course_entity.dart';
import '/backend/supabase/supabase_bootstrap.dart';

abstract class CourseRepository {
  Future<List<CourseEntity>> fetchPublished({
    int limit = 40,
    int offset = 0,
  });

  Future<List<CourseEntity>> fetchRecommended({int limit = 20});

  Future<List<CourseEntity>> fetchPopular({int limit = 20});

  Future<List<CourseEntity>> fetchByCategory(
    String categoryId, {
    int limit = 40,
  });

  Future<List<CourseEntity>> fetchByInstructor(
    String instructorId, {
    int limit = 40,
  });

  Future<CourseEntity?> fetchById(String id);
}

class SupabaseCourseRepository implements CourseRepository {
  SupabaseCourseRepository({SupabaseClient? client})
      : _client = client ?? SupabaseBootstrap.client;

  final SupabaseClient _client;

  /// Disambiguate: live DB has both courses.instructor_id AND course_instructors.
  static const _select = '''
id, title, subtitle, description, thumbnail_url, preview_video_url,
price, currency, rating_avg, rating_count, lessons_count, enrollments_count,
is_recommended, is_popular, is_published, status, category_id, instructor_id,
level, duration_minutes, published_at, created_at,
categories(name),
instructors!courses_instructor_id_fkey(display_name, avatar_url, title)
''';

  @override
  Future<List<CourseEntity>> fetchPublished({
    int limit = 40,
    int offset = 0,
  }) async {
    final rows = await _client
        .from('courses')
        .select(_select)
        .eq('is_published', true)
        .order('published_at', ascending: false)
        .range(offset, offset + limit - 1);

    return _mapRows(rows);
  }

  @override
  Future<List<CourseEntity>> fetchRecommended({int limit = 20}) async {
    final rows = await _client
        .from('courses')
        .select(_select)
        .eq('is_published', true)
        .eq('is_recommended', true)
        .order('published_at', ascending: false)
        .limit(limit);

    return _mapRows(rows);
  }

  @override
  Future<List<CourseEntity>> fetchPopular({int limit = 20}) async {
    final rows = await _client
        .from('courses')
        .select(_select)
        .eq('is_published', true)
        .eq('is_popular', true)
        .order('enrollments_count', ascending: false)
        .limit(limit);

    return _mapRows(rows);
  }

  @override
  Future<List<CourseEntity>> fetchByCategory(
    String categoryId, {
    int limit = 40,
  }) async {
    final rows = await _client
        .from('courses')
        .select(_select)
        .eq('is_published', true)
        .eq('category_id', categoryId)
        .order('published_at', ascending: false)
        .limit(limit);

    return _mapRows(rows);
  }

  @override
  Future<List<CourseEntity>> fetchByInstructor(
    String instructorId, {
    int limit = 40,
  }) async {
    if (instructorId.isEmpty) return const [];
    final rows = await _client
        .from('courses')
        .select(_select)
        .eq('is_published', true)
        .eq('instructor_id', instructorId)
        .order('published_at', ascending: false)
        .limit(limit);

    return _mapRows(rows);
  }

  @override
  Future<CourseEntity?> fetchById(String id) async {
    final row = await _client
        .from('courses')
        .select(_select)
        .eq('id', id)
        .maybeSingle();
    if (row == null) return null;
    return CourseEntity.fromJson(Map<String, dynamic>.from(row));
  }

  List<CourseEntity> _mapRows(dynamic rows) {
    return (rows as List)
        .map((row) => CourseEntity.fromJson(Map<String, dynamic>.from(row)))
        .toList(growable: false);
  }
}

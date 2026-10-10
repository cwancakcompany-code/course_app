import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '/backend/models/instructor_entity.dart';
import '/backend/supabase/supabase_bootstrap.dart';

abstract class InstructorRepository {
  Future<List<InstructorEntity>> fetchActive({int limit = 50});
  Future<InstructorEntity?> fetchById(String id);
}

class SupabaseInstructorRepository implements InstructorRepository {
  SupabaseInstructorRepository({SupabaseClient? client})
      : _client = client ?? SupabaseBootstrap.client;

  final SupabaseClient _client;

  static const _baseSelect = 'id, display_name, title, bio, avatar_url';

  @override
  Future<List<InstructorEntity>> fetchActive({int limit = 50}) async {
    final rows = await _client
        .from('instructors')
        .select(_baseSelect)
        .eq('is_active', true)
        .order('display_name', ascending: true)
        .limit(limit);

    final instructors = (rows as List)
        .map((row) => InstructorEntity.fromJson(Map<String, dynamic>.from(row)))
        .toList();

    final stats = await _loadStatsMap();
    return instructors
        .map((i) {
          final s = stats[i.id];
          if (s == null) return i;
          return InstructorEntity(
            id: i.id,
            displayName: i.displayName,
            title: i.title,
            bio: i.bio,
            avatarUrl: i.avatarUrl,
            coursesCount: s.courses,
            studentsCount: s.students,
            reviewsCount: s.reviews,
          );
        })
        .toList(growable: false);
  }

  @override
  Future<InstructorEntity?> fetchById(String id) async {
    final row = await _client
        .from('instructors')
        .select(_baseSelect)
        .eq('id', id)
        .maybeSingle();
    if (row == null) return null;

    final base = InstructorEntity.fromJson(Map<String, dynamic>.from(row));
    final stats = await _loadStatsMap();
    final s = stats[id];
    if (s == null) return base;
    return InstructorEntity(
      id: base.id,
      displayName: base.displayName,
      title: base.title,
      bio: base.bio,
      avatarUrl: base.avatarUrl,
      coursesCount: s.courses,
      studentsCount: s.students,
      reviewsCount: s.reviews,
    );
  }

  Future<Map<String, ({int courses, int students, int reviews})>>
      _loadStatsMap() async {
    try {
      final rows = await _client.rpc('list_instructor_stats');
      final map = <String, ({int courses, int students, int reviews})>{};
      for (final raw in (rows as List)) {
        final row = Map<String, dynamic>.from(raw as Map);
        final id = row['instructor_id'] as String?;
        if (id == null) continue;
        map[id] = (
          courses: (row['courses_count'] as num?)?.toInt() ?? 0,
          students: (row['students_count'] as num?)?.toInt() ?? 0,
          reviews: (row['reviews_count'] as num?)?.toInt() ?? 0,
        );
      }
      return map;
    } catch (e) {
      debugPrint('list_instructor_stats failed: $e');
      return {};
    }
  }
}

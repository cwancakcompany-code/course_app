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

  static const _select =
      'id, display_name, title, bio, avatar_url, courses(count)';

  @override
  Future<List<InstructorEntity>> fetchActive({int limit = 50}) async {
    try {
      final rows = await _client
          .from('instructors')
          .select(_select)
          .eq('is_active', true)
          .order('display_name', ascending: true)
          .limit(limit);

      return (rows as List)
          .map(
            (row) => InstructorEntity.fromJson(Map<String, dynamic>.from(row)),
          )
          .toList(growable: false);
    } catch (_) {
      // Fallback when embed count is unavailable (RLS / missing FK).
      final rows = await _client
          .from('instructors')
          .select('id, display_name, title, bio, avatar_url')
          .eq('is_active', true)
          .order('display_name', ascending: true)
          .limit(limit);

      return (rows as List)
          .map(
            (row) => InstructorEntity.fromJson(Map<String, dynamic>.from(row)),
          )
          .toList(growable: false);
    }
  }

  @override
  Future<InstructorEntity?> fetchById(String id) async {
    final row = await _client
        .from('instructors')
        .select(_select)
        .eq('id', id)
        .maybeSingle();
    if (row == null) return null;
    return InstructorEntity.fromJson(Map<String, dynamic>.from(row));
  }
}

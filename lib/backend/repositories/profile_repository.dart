import 'package:supabase_flutter/supabase_flutter.dart';

import '/backend/models/profile_entity.dart';
import '/backend/supabase/supabase_bootstrap.dart';

abstract class ProfileRepository {
  Future<ProfileEntity?> fetchById(String id);
  Future<ProfileEntity> ensureProfile({
    required String id,
    required String email,
    required String firstName,
    required String lastName,
    String? userName,
  });
}

class SupabaseProfileRepository implements ProfileRepository {
  SupabaseProfileRepository({SupabaseClient? client})
      : _client = client ?? SupabaseBootstrap.client;

  final SupabaseClient _client;

  static const _select =
      'id, user_name, first_name, last_name, phone_country_code, phone_number, avatar_url, role, is_active';

  @override
  Future<ProfileEntity?> fetchById(String id) async {
    final row = await _client
        .from('profiles')
        .select(_select)
        .eq('id', id)
        .maybeSingle();
    if (row == null) return null;
    return ProfileEntity.fromJson(Map<String, dynamic>.from(row));
  }

  @override
  Future<ProfileEntity> ensureProfile({
    required String id,
    required String email,
    required String firstName,
    required String lastName,
    String? userName,
  }) async {
    final existing = await fetchById(id);
    if (existing != null) return existing;

    final baseName = (userName?.trim().isNotEmpty == true)
        ? userName!.trim()
        : email.split('@').first.trim();
    final safeName = baseName.isEmpty
        ? 'student_${id.substring(0, 8)}'
        : baseName.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');

    // Fallback when DB trigger is missing. Role defaults to student.
    Future<void> upsert(String name) {
      return _client.from('profiles').upsert({
        'id': id,
        'user_name': name,
        'first_name': firstName.trim(),
        'last_name': lastName.trim(),
        'role': 'student',
        'preferred_currency': 'IQD',
        'is_active': true,
      });
    }

    try {
      await upsert(safeName);
    } catch (_) {
      await upsert('${safeName}_${id.substring(0, 6)}');
    }

    final created = await fetchById(id);
    if (created == null) {
      throw StateError('Profile could not be created for $id');
    }
    return created;
  }
}

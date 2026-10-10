import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '/backend/supabase/supabase_bootstrap.dart';

/// Resolves private lesson PDFs from Supabase Storage (`course-resources`).
/// Admin panel stores paths like `lesson_resources/{courseId}/{lessonId}/file.pdf`.
class CourseResourceStorageService {
  CourseResourceStorageService({SupabaseClient? client})
      : _client = client ?? SupabaseBootstrap.client;

  final SupabaseClient _client;

  static const bucket = 'course-resources';
  static const signedUrlTtlSeconds = 15 * 60;

  /// Returns a downloadable HTTPS URL for [pathOrUrl].
  /// - `https://...` → returned as-is
  /// - `lesson_resources/...` → short-lived signed URL (requires enrollment RLS)
  Future<String?> resolvePlayableUrl(String? pathOrUrl) async {
    final raw = (pathOrUrl ?? '').trim();
    if (raw.isEmpty) return null;

    if (raw.startsWith('http://') || raw.startsWith('https://')) {
      return raw;
    }

    if (!raw.startsWith('lesson_resources/')) {
      debugPrint('Unsupported lesson resource path: $raw');
      return null;
    }

    if (raw.contains('..')) {
      debugPrint('Rejected unsafe storage path');
      return null;
    }

    try {
      final signed = await _client.storage
          .from(bucket)
          .createSignedUrl(raw, signedUrlTtlSeconds);
      return signed;
    } on StorageException catch (e) {
      debugPrint('createSignedUrl failed: ${e.message}');
      rethrow;
    }
  }
}

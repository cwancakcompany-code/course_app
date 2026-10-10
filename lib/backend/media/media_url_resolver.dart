import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'bunny_stream_service.dart';

/// Resolves Supabase Storage paths and Bunny Stream ids into usable URLs.
class MediaUrlResolver {
  const MediaUrlResolver();

  static String get supabaseUrl =>
      (dotenv.env['SUPABASE_URL'] ?? dotenv.env['NEXT_PUBLIC_SUPABASE_URL'] ?? '')
          .trim()
          .replaceAll(RegExp(r'/$'), '');

  /// Turns a DB media value into a network URL when possible.
  String resolveImage(String? raw) {
    if (raw == null) return '';
    final value = raw.trim();
    if (value.isEmpty) return '';

    if (value.startsWith('http://') || value.startsWith('https://')) {
      return value;
    }

    final bunny = BunnyStreamService();
    if (bunny.isVideoGuid(value)) {
      return bunny.thumbnailUrl(value);
    }

    // Already a storage public URL path segment.
    if (value.contains('/storage/v1/object/public/')) {
      return value.startsWith('http') ? value : '$supabaseUrl$value';
    }

    if (value.startsWith('avatars/')) {
      return '$supabaseUrl/storage/v1/object/public/$value';
    }

    if (value.startsWith('public-media/') ||
        value.startsWith('courses/') ||
        value.startsWith('course-thumbnails/') ||
        value.startsWith('thumbnails/') ||
        value.startsWith('instructor_avatars/')) {
      final path = value.startsWith('public-media/')
          ? value
          : 'public-media/$value';
      return '$supabaseUrl/storage/v1/object/public/$path';
    }

    if (value.contains('/')) {
      return '$supabaseUrl/storage/v1/object/public/$value';
    }

    // Bare storage object name — try common public bucket.
    if (supabaseUrl.isNotEmpty && !value.contains(' ')) {
      return '$supabaseUrl/storage/v1/object/public/public-media/$value';
    }

    return '';
  }

  /// Returns a playable reference for the video page:
  /// - Bunny GUID / mediadelivery URL → signed embed URL
  /// - Other https URLs → passthrough
  String resolveVideo(String? raw) {
    if (raw == null) return '';
    final value = raw.trim();
    if (value.isEmpty) return '';

    final bunny = BunnyStreamService();
    final videoId = bunny.extractVideoId(value);
    if (videoId != null) {
      return bunny.signedEmbedUrl(videoId, autoplay: true);
    }

    if (value.startsWith('http://') || value.startsWith('https://')) {
      return value;
    }

    return '';
  }

  String bunnyThumbnail(String? videoGuid) {
    final bunny = BunnyStreamService();
    final id = bunny.extractVideoId(videoGuid);
    if (id == null) return '';
    return bunny.thumbnailUrl(id);
  }
}

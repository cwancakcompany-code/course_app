import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Bunny Stream playback helpers — same signing rules as admin_panel_course_app.
///
/// Embed signature: SHA256(token_key + videoId + expires)
/// URL: https://iframe.mediadelivery.net/embed/{libraryId}/{videoId}?token=&expires=
class BunnyStreamService {
  BunnyStreamService();

  static final _guidRe = RegExp(
    r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
    caseSensitive: false,
  );

  String get libraryId =>
      (dotenv.env['BUNNY_STREAM_LIBRARY_ID'] ?? '').trim();

  String get tokenKey =>
      (dotenv.env['BUNNY_STREAM_TOKEN_KEY'] ?? '').trim();

  String get cdnHostname =>
      (dotenv.env['BUNNY_STREAM_CDN_HOSTNAME'] ?? '')
          .trim()
          .replaceAll(RegExp(r'^https?://'), '');

  bool get isConfigured => libraryId.isNotEmpty && tokenKey.isNotEmpty;

  bool isVideoGuid(String? value) {
    final v = value?.trim() ?? '';
    return _guidRe.hasMatch(v);
  }

  /// Extract GUID from a raw DB value or an existing mediadelivery embed URL.
  String? extractVideoId(String? raw) {
    final value = raw?.trim() ?? '';
    if (value.isEmpty) return null;
    if (isVideoGuid(value)) return value;

    final uri = Uri.tryParse(value);
    if (uri == null) return null;
    final host = uri.host.toLowerCase();
    if (host == 'iframe.mediadelivery.net' ||
        host == 'player.mediadelivery.net' ||
        host.endsWith('.mediadelivery.net')) {
      final parts = uri.pathSegments.where((p) => p.isNotEmpty).toList();
      // /embed/{libraryId}/{videoId}
      if (parts.length >= 3 && parts[0] == 'embed' && isVideoGuid(parts[2])) {
        return parts[2];
      }
      if (parts.isNotEmpty && isVideoGuid(parts.last)) {
        return parts.last;
      }
    }
    return null;
  }

  /// Signed iframe URL (same as admin `generateSignedPlayerUrl`).
  String signedEmbedUrl(
    String videoId, {
    Duration ttl = const Duration(hours: 2),
    bool autoplay = true,
  }) {
    final id = videoId.trim();
    if (!isVideoGuid(id)) {
      throw ArgumentError('Invalid Bunny video id: $videoId');
    }
    if (!isConfigured) {
      throw StateError(
        'Bunny Stream is not configured. Set BUNNY_STREAM_LIBRARY_ID and BUNNY_STREAM_TOKEN_KEY.',
      );
    }

    final expiresAt =
        (DateTime.now().millisecondsSinceEpoch ~/ 1000) + ttl.inSeconds;
    final token =
        sha256.convert(utf8.encode('$tokenKey$id$expiresAt')).toString();

    return Uri.https(
      'iframe.mediadelivery.net',
      '/embed/$libraryId/$id',
      <String, String>{
        'token': token,
        'expires': '$expiresAt',
        'autoplay': autoplay ? 'true' : 'false',
        'preload': 'true',
        'responsive': 'true',
      },
    ).toString();
  }

  String thumbnailUrl(String videoId) {
    final id = videoId.trim();
    if (!isVideoGuid(id)) return '';
    // Prefer CDN hostname (public thumbnails); fall back to iframe endpoint.
    if (cdnHostname.isNotEmpty) {
      return 'https://$cdnHostname/$id/thumbnail.jpg';
    }
    if (libraryId.isEmpty) return '';
    return 'https://iframe.mediadelivery.net/thumbnail/$libraryId/$id';
  }
}

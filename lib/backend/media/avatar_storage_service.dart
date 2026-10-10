import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image/image.dart' as img;
import 'package:supabase_flutter/supabase_flutter.dart';

import '/backend/supabase/supabase_bootstrap.dart';

class AvatarUploadException implements Exception {
  AvatarUploadException(this.message);
  final String message;

  @override
  String toString() => message;
}

/// Secure avatar upload: compress client-side, store in Storage (not DB blob).
class AvatarStorageService {
  AvatarStorageService({SupabaseClient? client})
      : _client = client ?? SupabaseBootstrap.client;

  final SupabaseClient _client;

  static const bucket = 'avatars';
  static const maxEdge = 512;
  static const maxBytesAfterCompress = 400 * 1024; // 400 KB
  static const maxBytesBeforeCompress = 10 * 1024 * 1024; // 10 MB
  static const allowedMime = {
    'image/jpeg',
    'image/jpg',
    'image/png',
    'image/webp',
  };

  /// Uploads avatar for [userId]. Returns public URL (path stored in profiles).
  Future<String> uploadAvatar({
    required String userId,
    required Uint8List bytes,
    String? mimeType,
    String? fileName,
  }) async {
    final uid = userId.trim();
    if (uid.isEmpty) {
      throw AvatarUploadException('User not signed in');
    }
    if (bytes.isEmpty) {
      throw AvatarUploadException('Empty image');
    }
    if (bytes.lengthInBytes > maxBytesBeforeCompress) {
      throw AvatarUploadException('Image is too large (max 10 MB)');
    }

    final mime = (mimeType ?? _guessMime(fileName)).toLowerCase();
    if (!allowedMime.contains(mime)) {
      throw AvatarUploadException('Only JPEG, PNG, or WebP images are allowed');
    }

    final compressed = await _compress(bytes);
    if (compressed.lengthInBytes > maxBytesAfterCompress) {
      throw AvatarUploadException(
        'Could not compress image under 400 KB. Try another photo.',
      );
    }

    // Fixed path per user — overwrite safely; no random filenames in public list.
    final objectPath = '$uid/avatar.jpg';

    try {
      await _client.storage.from(bucket).uploadBinary(
            objectPath,
            compressed,
            fileOptions: const FileOptions(
              contentType: 'image/jpeg',
              upsert: true,
              cacheControl: '3600',
            ),
          );
    } on StorageException catch (e) {
      debugPrint('avatar upload StorageException: ${e.message}');
      throw AvatarUploadException(
        e.statusCode == '403' || e.statusCode == '401'
            ? 'Not allowed to upload avatar'
            : 'Avatar upload failed',
      );
    } catch (e) {
      debugPrint('avatar upload failed: $e');
      throw AvatarUploadException('Avatar upload failed');
    }

    // Store relative path in DB (small, portable). UI adds cache-buster.
    return '$bucket/$objectPath';
  }

  Future<Uint8List> _compress(Uint8List input) async {
    for (final quality in const [82, 70, 58, 45]) {
      try {
        final result = await FlutterImageCompress.compressWithList(
          input,
          minWidth: maxEdge,
          minHeight: maxEdge,
          quality: quality,
          format: CompressFormat.jpeg,
        );
        if (result.isNotEmpty &&
            result.lengthInBytes <= maxBytesAfterCompress) {
          return Uint8List.fromList(result);
        }
        if (result.isNotEmpty && quality == 45) {
          return Uint8List.fromList(result);
        }
      } catch (e) {
        debugPrint('flutter_image_compress q=$quality failed: $e');
      }
    }
    return _compressWithImagePackage(input);
  }

  Uint8List _compressWithImagePackage(Uint8List input) {
    final decoded = img.decodeImage(input);
    if (decoded == null) {
      throw AvatarUploadException('Invalid or corrupted image file');
    }
    final resized = img.copyResize(
      decoded,
      width: decoded.width >= decoded.height ? maxEdge : null,
      height: decoded.height > decoded.width ? maxEdge : null,
      interpolation: img.Interpolation.linear,
    );
    for (final quality in const [82, 70, 58, 45]) {
      final jpg = img.encodeJpg(resized, quality: quality);
      if (jpg.length <= maxBytesAfterCompress || quality == 45) {
        return Uint8List.fromList(jpg);
      }
    }
    return Uint8List.fromList(img.encodeJpg(resized, quality: 40));
  }

  String _guessMime(String? name) {
    final lower = (name ?? '').toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) return 'image/jpeg';
    return 'image/jpeg';
  }
}

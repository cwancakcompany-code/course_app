import 'dart:typed_data';

import 'package:flutter/foundation.dart';

import '/app_state.dart';
import '/backend/media/avatar_storage_service.dart';
import '/backend/media/media_url_resolver.dart';
import '/backend/models/profile_entity.dart';
import '/backend/repositories/profile_repository.dart';
import '/backend/schema/structs/login_model_struct.dart';
import '/backend/services/auth_service.dart';
import '/backend/supabase/supabase_bootstrap.dart';

class ProfileUpdateException implements Exception {
  ProfileUpdateException(this.message);
  final String message;

  @override
  String toString() => message;
}

class ProfileService {
  ProfileService({
    ProfileRepository? profiles,
    AvatarStorageService? avatars,
  })  : _profiles = profiles ?? SupabaseProfileRepository(),
        _avatars = avatars ?? AvatarStorageService();

  final ProfileRepository _profiles;
  final AvatarStorageService _avatars;
  static const _media = MediaUrlResolver();

  Future<ProfileEntity?> loadCurrentProfile() async {
    final user = AuthService().currentUser;
    if (user == null) return null;
    return _profiles.fetchById(user.id);
  }

  /// Updates name + phone. Optional compressed avatar bytes → Storage only.
  Future<ProfileEntity> updateProfile({
    required String firstName,
    required String lastName,
    required String phoneCountryCode,
    required String phoneNumber,
    Uint8List? avatarBytes,
    String? avatarMimeType,
    String? avatarFileName,
  }) async {
    final user = AuthService().currentUser;
    if (user == null) {
      throw ProfileUpdateException('Please sign in first');
    }

    final f = firstName.trim();
    final l = lastName.trim();
    if (f.isEmpty || l.isEmpty) {
      throw ProfileUpdateException('First and last name are required');
    }

    final dial = _normalizeDialCode(phoneCountryCode);
    final phone = _normalizePhone(phoneNumber);
    if (phone.isNotEmpty && (phone.length < 7 || phone.length > 15)) {
      throw ProfileUpdateException('Phone number must be 7–15 digits');
    }

    try {
      String? avatarPath;
      if (avatarBytes != null && avatarBytes.isNotEmpty) {
        avatarPath = await _avatars.uploadAvatar(
          userId: user.id,
          bytes: avatarBytes,
          mimeType: avatarMimeType,
          fileName: avatarFileName,
        );
      }

      final patch = <String, dynamic>{
        'first_name': f,
        'last_name': l,
        'phone_country_code': dial.isEmpty ? null : dial,
        'phone_number': phone.isEmpty ? null : phone,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      };
      if (avatarPath != null) {
        // Path only — never store image bytes in Postgres.
        patch['avatar_url'] = avatarPath;
      }

      // Never allow role / id changes from client.
      await SupabaseBootstrap.client
          .from('profiles')
          .update(patch)
          .eq('id', user.id);

      final profile = await _profiles.fetchById(user.id);
      if (profile == null) {
        throw ProfileUpdateException('Profile not found');
      }

      syncAppState(profile, user.email ?? '');
      return profile;
    } on AvatarUploadException catch (e) {
      throw ProfileUpdateException(e.message);
    } on ProfileUpdateException {
      rethrow;
    } catch (e) {
      debugPrint('updateProfile failed: $e');
      throw ProfileUpdateException('Could not update profile');
    }
  }

  /// Syncs FFAppState after login / profile edit.
  void syncAppState(ProfileEntity profile, String email) {
    final app = FFAppState();
    final dial = (profile.phoneCountryCode ?? '').replaceAll('+', '');
    final resolvedAvatar = _media.resolveImage(profile.avatarUrl);
    final avatarUi = resolvedAvatar.isEmpty
        ? ''
        : '$resolvedAvatar${resolvedAvatar.contains('?') ? '&' : '?'}v=${DateTime.now().millisecondsSinceEpoch}';

    app.update(() {
      app.userDetail = LoginModelStruct(
        userName: profile.userName,
        firstName: profile.firstName,
        lastName: profile.lastName,
        email: email,
        countryCode: profile.phoneCountryCode,
        phoneNumber: profile.phoneNumber,
      );
      if (dial.isNotEmpty) {
        app.countryCodeEdit = dial;
        app.countryCode = dial;
      }
      if ((profile.phoneNumber ?? '').isNotEmpty) {
        app.phone = profile.phoneNumber!;
      }
      app.profileAvatarUrl = avatarUi;
    });
  }

  String _normalizeDialCode(String raw) {
    final digits = raw.replaceAll(RegExp(r'[^\d+]'), '');
    if (digits.isEmpty) return '';
    return digits.startsWith('+') ? digits : '+$digits';
  }

  String _normalizePhone(String raw) {
    return raw.replaceAll(RegExp(r'\D'), '');
  }
}

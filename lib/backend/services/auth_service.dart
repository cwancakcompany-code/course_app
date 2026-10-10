import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '/app_state.dart';
import '/backend/models/profile_entity.dart';
import '/backend/repositories/profile_repository.dart';
import '/backend/schema/structs/login_model_struct.dart';
import '/backend/supabase/supabase_bootstrap.dart';

class AuthFailure implements Exception {
  AuthFailure(this.message);
  final String message;

  @override
  String toString() => message;
}

/// Supabase Auth + profiles (default role: student).
class AuthService {
  AuthService({
    SupabaseClient? client,
    ProfileRepository? profiles,
  })  : _client = client ?? SupabaseBootstrap.client,
        _profiles = profiles ?? SupabaseProfileRepository();

  final SupabaseClient _client;
  final ProfileRepository _profiles;

  User? get currentUser => _client.auth.currentUser;
  Session? get currentSession => _client.auth.currentSession;
  bool get isSignedIn => currentSession != null;

  Future<ProfileEntity> signIn({
    required String email,
    required String password,
  }) async {
    final trimmedEmail = email.trim().toLowerCase();
    if (trimmedEmail.isEmpty || password.isEmpty) {
      throw AuthFailure('ئیمەیڵ و وشەی نهێنی پێویستن');
    }

    try {
      final res = await _client.auth.signInWithPassword(
        email: trimmedEmail,
        password: password,
      );
      final user = res.user;
      if (user == null) {
        throw AuthFailure('چوونەژوورەوە سەرکەوتوو نەبوو');
      }

      final meta = user.userMetadata ?? {};
      final profile = await _profiles.ensureProfile(
        id: user.id,
        email: user.email ?? trimmedEmail,
        firstName: (meta['first_name'] as String?) ?? '',
        lastName: (meta['last_name'] as String?) ?? '',
        userName: meta['user_name'] as String?,
      );

      if (!profile.isActive) {
        await _client.auth.signOut();
        throw AuthFailure('ئەم هەژمارە ناچالاکە');
      }

      _applySession(profile, user.email ?? trimmedEmail);
      return profile;
    } on AuthFailure {
      rethrow;
    } on AuthException catch (e) {
      throw AuthFailure(_mapAuthError(e.message));
    } catch (e) {
      debugPrint('signIn failed: $e');
      throw AuthFailure('چوونەژوورەوە سەرکەوتوو نەبوو. دووبارە هەوڵ بدەوە');
    }
  }

  Future<ProfileEntity> signUp({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    final trimmedEmail = email.trim().toLowerCase();
    final f = firstName.trim();
    final l = lastName.trim();
    if (f.isEmpty || l.isEmpty) {
      throw AuthFailure('ناوی یەکەم و دووەم پێویستن');
    }
    if (trimmedEmail.isEmpty || password.length < 6) {
      throw AuthFailure('وشەی نهێنی دەبێت لانیکەم ٦ پیت بێت');
    }

    final userName = _buildUserName(trimmedEmail, f, l);

    try {
      final res = await _client.auth.signUp(
        email: trimmedEmail,
        password: password,
        data: {
          'first_name': f,
          'last_name': l,
          'user_name': userName,
          'role': 'student',
        },
      );

      var user = res.user;
      var session = res.session;

      // Skip verification UI — sign in immediately when confirm-email is off.
      if (session == null && user != null) {
        try {
          final signInRes = await _client.auth.signInWithPassword(
            email: trimmedEmail,
            password: password,
          );
          user = signInRes.user ?? user;
          session = signInRes.session;
        } on AuthException catch (_) {
          // Confirm email still enabled in Supabase project settings.
        }
      }

      if (user == null || session == null) {
        throw AuthFailure(
          'هەژمار دروست بوو. لە Supabase: Authentication → Email → '
          'Confirm email بکە Off بۆ چوونەژوورەوەی ڕاستەوخۆ',
        );
      }

      final profile = await _profiles.ensureProfile(
        id: user.id,
        email: user.email ?? trimmedEmail,
        firstName: f,
        lastName: l,
        userName: userName,
      );

      _applySession(profile, user.email ?? trimmedEmail);
      return profile;
    } on AuthFailure {
      rethrow;
    } on AuthException catch (e) {
      throw AuthFailure(_mapAuthError(e.message));
    } catch (e) {
      debugPrint('signUp failed: $e');
      throw AuthFailure('خۆتۆمارکردن سەرکەوتوو نەبوو. دووبارە هەوڵ بدەوە');
    }
  }

  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      debugPrint('signOut error: $e');
    }
    final app = FFAppState();
    app.update(() {
      app.isLogin = false;
      app.currentPassword = '';
      app.deleteCurrentPassword();
      app.userDetail = LoginModelStruct();
      app.deleteUserDetail();
      app.homePageIndex = 0;
    });
  }

  /// Restore FFAppState from an existing Supabase session (app launch).
  Future<bool> restoreSession() async {
    final user = currentUser;
    if (user == null) {
      FFAppState().update(() {
        FFAppState().isLogin = false;
      });
      return false;
    }

    try {
      final meta = user.userMetadata ?? {};
      final profile = await _profiles.ensureProfile(
        id: user.id,
        email: user.email ?? '',
        firstName: (meta['first_name'] as String?) ?? '',
        lastName: (meta['last_name'] as String?) ?? '',
        userName: meta['user_name'] as String?,
      );
      if (!profile.isActive) {
        await signOut();
        return false;
      }
      _applySession(profile, user.email ?? '');
      return true;
    } catch (e) {
      debugPrint('restoreSession failed: $e');
      return false;
    }
  }

  void _applySession(ProfileEntity profile, String email) {
    final app = FFAppState();
    app.update(() {
      app.isLogin = true;
      app.currentPassword = '';
      app.deleteCurrentPassword();
      app.userDetail = LoginModelStruct(
        userName: profile.userName,
        firstName: profile.firstName,
        lastName: profile.lastName,
        email: email,
        countryCode: profile.phoneCountryCode,
        phoneNumber: profile.phoneNumber,
      );
    });
  }

  String _buildUserName(String email, String firstName, String lastName) {
    final fromEmail = email.split('@').first.trim();
    if (fromEmail.isNotEmpty) {
      return fromEmail
          .replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_')
          .toLowerCase();
    }
    final base = '$firstName$lastName'.toLowerCase();
    return base.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
  }

  String _mapAuthError(String raw) {
    final msg = raw.toLowerCase();
    if (msg.contains('invalid login credentials')) {
      return 'ئیمەیڵ یان وشەی نهێنی هەڵەیە';
    }
    if (msg.contains('user already registered') ||
        msg.contains('already been registered')) {
      return 'ئەم ئیمەیڵە پێشتر تۆمارکراوە';
    }
    if (msg.contains('password')) {
      return 'وشەی نهێنی لاوازە یان نادروستە';
    }
    if (msg.contains('email')) {
      return 'ئیمەیڵ نادروستە';
    }
    if (msg.contains('network') || msg.contains('socket')) {
      return 'کێشەی ئینتەرنێت';
    }
    return raw.isNotEmpty ? raw : 'هەڵەیەک ڕوویدا';
  }
}

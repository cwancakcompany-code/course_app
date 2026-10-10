import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '/app_state.dart';
import '/backend/media/media_url_resolver.dart';
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

class PendingSignUp {
  const PendingSignUp({
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
    required this.userName,
  });

  final String email;
  final String password;
  final String firstName;
  final String lastName;
  final String userName;
}

/// Supabase Auth + profiles (default role: student).
///
/// Free Tier uses built-in email → Magic Link (template not editable without SMTP).
/// Account is finalized only after the link is opened / verified.
class AuthService {
  AuthService({
    SupabaseClient? client,
    ProfileRepository? profiles,
  })  : _client = client ?? SupabaseBootstrap.client,
        _profiles = profiles ?? SupabaseProfileRepository();

  final SupabaseClient _client;
  final ProfileRepository _profiles;

  /// In-memory only — cleared after verify or cancel. Never persisted.
  static PendingSignUp? _pendingSignUp;

  static PendingSignUp? get pendingSignUp => _pendingSignUp;

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

  /// Sends Free Tier magic-link email. No login until link is verified.
  Future<void> sendSignUpOtp({
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
    _pendingSignUp = PendingSignUp(
      email: trimmedEmail,
      password: password,
      firstName: f,
      lastName: l,
      userName: userName,
    );

    if (_client.auth.currentSession != null) {
      await _client.auth.signOut();
    }
    FFAppState().update(() {
      FFAppState().isLogin = false;
    });

    try {
      await _client.auth.signInWithOtp(
        email: trimmedEmail,
        shouldCreateUser: true,
        emailRedirectTo: SupabaseBootstrap.authRedirectUrl,
        data: {
          'first_name': f,
          'last_name': l,
          'user_name': userName,
          'role': 'student',
        },
      );

      // Magic link must not leave a session until the user opens it.
      if (_client.auth.currentSession != null) {
        await _client.auth.signOut();
        FFAppState().update(() {
          FFAppState().isLogin = false;
        });
      }
    } on AuthException catch (e) {
      _pendingSignUp = null;
      debugPrint('sendSignUpOtp AuthException: ${e.statusCode} ${e.message}');
      throw AuthFailure(_mapAuthError(e.message));
    } catch (e) {
      _pendingSignUp = null;
      debugPrint('sendSignUpOtp failed: $e');
      throw AuthFailure('ناردنی ئیمەیڵی پشتڕاستکردنەوە سەرکەوتوو نەبوو');
    }
  }

  Future<void> resendSignUpOtp() async {
    final pending = _pendingSignUp;
    if (pending == null) {
      throw AuthFailure('هیچ خۆتۆمارکردنێکی چاوەڕوان نییە');
    }
    await sendSignUpOtp(
      firstName: pending.firstName,
      lastName: pending.lastName,
      email: pending.email,
      password: pending.password,
    );
  }

  /// After magic link opens the app (or session appears), finish signup.
  Future<ProfileEntity> finalizePendingSignUp() async {
    final pending = _pendingSignUp;
    final user = _client.auth.currentUser;
    final session = _client.auth.currentSession;
    if (pending == null) {
      throw AuthFailure('سەرەتا Sign Up بکەوە');
    }
    if (user == null || session == null) {
      throw AuthFailure(
        'لینکی ئیمەیڵ لەم مۆبایلەدا بکەرەوە، یان لینکەکە لێرە بلکێنە',
      );
    }

    return _completeSignUp(user: user, email: user.email ?? pending.email);
  }

  /// Paste the full email link (or token_hash) when deep link fails.
  Future<ProfileEntity> verifySignUpFromEmailLink(String rawLinkOrToken) async {
    final pending = _pendingSignUp;
    if (pending == null) {
      throw AuthFailure('سەرەتا Sign Up بکەوە');
    }

    final input = rawLinkOrToken.trim();
    if (input.isEmpty) {
      throw AuthFailure('لینکی ئیمەیڵ بلکێنە');
    }

    try {
      final tokenHash = _extractTokenHash(input);
      if (tokenHash == null) {
        throw AuthFailure('لینکەکە نادروستە — هەموو لینکەکە کۆپی بکە');
      }

      AuthResponse? res;
      for (final type in [OtpType.email, OtpType.signup, OtpType.magiclink]) {
        try {
          res = await _client.auth.verifyOTP(
            tokenHash: tokenHash,
            type: type,
          );
          if (res.session != null) break;
        } on AuthException {
          continue;
        }
      }

      final user = res?.user;
      final session = res?.session;
      if (user == null || session == null) {
        throw AuthFailure('لینکەکە بەسەرچووە یان نادروستە');
      }

      return _completeSignUp(user: user, email: user.email ?? pending.email);
    } on AuthFailure {
      rethrow;
    } on AuthException catch (e) {
      throw AuthFailure(_mapAuthError(e.message));
    } catch (e) {
      debugPrint('verifySignUpFromEmailLink failed: $e');
      throw AuthFailure('پشتڕاستکردنەوە سەرکەوتوو نەبوو');
    }
  }

  /// Optional 6-digit OTP (only if custom SMTP template uses {{ .Token }}).
  Future<ProfileEntity> verifySignUpOtp({
    required String email,
    required String otpCode,
  }) async {
    final pending = _pendingSignUp;
    final trimmedEmail = email.trim().toLowerCase();
    final token = otpCode.trim();

    if (token.isEmpty) {
      throw AuthFailure('کۆدی پشتڕاستکردنەوە بنووسە');
    }
    if (pending == null || pending.email != trimmedEmail) {
      throw AuthFailure('سەرەتا Sign Up بکەوە و ئیمەیڵێکی نوێ وەربگرە');
    }

    try {
      final res = await _client.auth.verifyOTP(
        email: trimmedEmail,
        token: token,
        type: OtpType.email,
      );

      final user = res.user;
      final session = res.session;
      if (user == null || session == null) {
        throw AuthFailure('کۆدەکە نادروستە یان بەسەرچووە');
      }

      return _completeSignUp(user: user, email: user.email ?? trimmedEmail);
    } on AuthFailure {
      rethrow;
    } on AuthException catch (e) {
      throw AuthFailure(_mapAuthError(e.message));
    } catch (e) {
      debugPrint('verifySignUpOtp failed: $e');
      throw AuthFailure('کۆدەکە نادروستە. دووبارە هەوڵ بدەوە');
    }
  }

  Future<ProfileEntity> _completeSignUp({
    required User user,
    required String email,
  }) async {
    final pending = _pendingSignUp;
    if (pending == null) {
      throw AuthFailure('سەرەتا Sign Up بکەوە');
    }

    try {
      await _client.auth.updateUser(
        UserAttributes(password: pending.password),
      );
    } catch (e) {
      debugPrint('updateUser password after verify: $e');
    }

    final profile = await _profiles.ensureProfile(
      id: user.id,
      email: email,
      firstName: pending.firstName,
      lastName: pending.lastName,
      userName: pending.userName,
    );

    _pendingSignUp = null;
    _applySession(profile, email);
    return profile;
  }

  String? _extractTokenHash(String input) {
    if (!input.contains('://') && !input.contains('?') && input.length > 20) {
      return input;
    }
    final uri = Uri.tryParse(input);
    if (uri == null) return null;

    final fromQuery = uri.queryParameters['token_hash'] ??
        uri.queryParameters['token'];
    if (fromQuery != null && fromQuery.isNotEmpty) return fromQuery;

    // Some clients put params after #
    final frag = uri.fragment;
    if (frag.isNotEmpty) {
      final q = Uri.splitQueryString(frag);
      final fromFrag = q['token_hash'] ?? q['token'];
      if (fromFrag != null && fromFrag.isNotEmpty) return fromFrag;
    }
    return null;
  }

  void clearPendingSignUp() {
    _pendingSignUp = null;
  }

  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      debugPrint('signOut error: $e');
    }
    _pendingSignUp = null;
    final app = FFAppState();
    app.update(() {
      app.isLogin = false;
      app.currentPassword = '';
      app.deleteCurrentPassword();
      app.userDetail = LoginModelStruct();
      app.deleteUserDetail();
      app.profileAvatarUrl = '';
      app.phone = '';
      app.homePageIndex = 0;
    });
  }

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
    final dial = (profile.phoneCountryCode ?? '').replaceAll('+', '');
    final avatar = const MediaUrlResolver().resolveImage(profile.avatarUrl);
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
      if (dial.isNotEmpty) {
        app.countryCodeEdit = dial;
        app.countryCode = dial;
      }
      if ((profile.phoneNumber ?? '').isNotEmpty) {
        app.phone = profile.phoneNumber!;
      }
      app.profileAvatarUrl = avatar;
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
    final msg = raw.toLowerCase().trim();
    if (msg.isEmpty) return 'هەڵەیەک ڕوویدا';

    // Keep specific checks FIRST — never treat every "email" string as invalid.
    if (msg.contains('invalid login credentials')) {
      return 'ئیمەیڵ یان وشەی نهێنی هەڵەیە';
    }
    if (msg.contains('email rate limit') ||
        msg.contains('over_email_send_rate_limit') ||
        msg.contains('you can only request this after') ||
        msg.contains('security purposes')) {
      // Free Tier: ~1 email / 60s per address (earlier tests also count).
      return 'سنووری ناردنی ئیمەیڵی Free Tier: دوای هەر ناردنێک ٦٠ چرکە چاوەڕێ بکە، '
          'پاشان Resend / Sign Up دووبارە بکە';
    }
    if (msg.contains('redirect') &&
        (msg.contains('not allowed') ||
            msg.contains('whitelist') ||
            msg.contains('allow list') ||
            msg.contains('invalid'))) {
      return 'Redirect URL ڕێگەپێدراو نییە. لە Supabase → Auth → URL Configuration '
          'زیاد بکە: edumaster://login-callback/';
    }
    if (msg.contains('error sending') ||
        msg.contains('unable to send') ||
        msg.contains('smtp') ||
        msg.contains('mail')) {
      return 'ناردنی ئیمەیڵ سەرکەوتوو نەبوو. دووبارە هەوڵ بدە یان چەند خولەک چاوەڕێ بکە';
    }
    if (msg.contains('user already registered') ||
        msg.contains('already been registered') ||
        msg.contains('already exists')) {
      return 'ئەم ئیمەیڵە پێشتر تۆمارکراوە — Sign In بکە';
    }
    if (msg.contains('invalid') &&
        (msg.contains('token') || msg.contains('otp') || msg.contains('code'))) {
      return 'کۆد/لینکی پشتڕاستکردنەوە نادروستە یان بەسەرچووە';
    }
    if (msg.contains('expired')) {
      return 'لینک/کۆد بەسەرچووە — Resend بکە';
    }
    // Only true email-format problems
    if (msg.contains('unable to validate email') ||
        msg.contains('invalid email') ||
        msg.contains('email address is invalid') ||
        msg.contains('is invalid: email')) {
      return 'فۆرماتی ئیمەیڵ نادروستە';
    }
    if (msg.contains('password') &&
        (msg.contains('weak') ||
            msg.contains('short') ||
            msg.contains('least') ||
            msg.contains('characters'))) {
      return 'وشەی نهێنی لاوازە — لانیکەم ٦ پیت';
    }
    if (msg.contains('network') || msg.contains('socket') || msg.contains('timed out')) {
      return 'کێشەی ئینتەرنێت';
    }

    // Show real server message so the issue is visible (Kurdish UI + original).
    return raw;
  }
}

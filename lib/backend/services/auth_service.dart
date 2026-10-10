import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
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

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
        'first_name': firstName,
        'last_name': lastName,
        'user_name': userName,
      };

  factory PendingSignUp.fromJson(Map<String, dynamic> json) {
    return PendingSignUp(
      email: (json['email'] as String?) ?? '',
      password: (json['password'] as String?) ?? '',
      firstName: (json['first_name'] as String?) ?? '',
      lastName: (json['last_name'] as String?) ?? '',
      userName: (json['user_name'] as String?) ?? '',
    );
  }
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
  static const _storage = FlutterSecureStorage();
  static const _pendingKey = 'edumaster_pending_signup';

  /// Kept in memory + secure storage so magic-link cold starts still work.
  static PendingSignUp? _pendingSignUp;

  /// Client guard so we do not hammer Free Tier email quota.
  static DateTime? _lastEmailSentAt;
  static const _minEmailGap = Duration(seconds: 60);
  static StreamSubscription<AuthState>? _authLinkSub;
  static bool _finalizingLink = false;

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

  /// Creates account immediately (no email OTP / magic-link verification).
  ///
  /// Requires Supabase → Authentication → Providers → Email →
  /// **Confirm email = OFF**.
  Future<ProfileEntity> signUp({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    String? phoneCountryCode,
    String? phoneNumber,
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
    await _clearPendingSignUp();

    if (_client.auth.currentSession != null) {
      await _client.auth.signOut();
    }

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

      // If Confirm email is still ON, session is null — try password login.
      if (session == null && user != null) {
        try {
          final login = await _client.auth.signInWithPassword(
            email: trimmedEmail,
            password: password,
          );
          user = login.user ?? user;
          session = login.session;
        } on AuthException catch (e) {
          final msg = e.message.toLowerCase();
          if (msg.contains('confirm') ||
              msg.contains('email not confirmed') ||
              msg.contains('not confirmed')) {
            throw AuthFailure(
              'لە Supabase → Authentication → Providers → Email '
              'هەڵیبکە: Confirm email = OFF',
            );
          }
          rethrow;
        }
      }

      if (user == null || session == null) {
        throw AuthFailure(
          'هەژمار دروست نەبوو. Confirm email لە Supabase ناکارا بکە',
        );
      }

      final profile = await _profiles.ensureProfile(
        id: user.id,
        email: user.email ?? trimmedEmail,
        firstName: f,
        lastName: l,
        userName: userName,
      );

      if (!profile.isActive) {
        await _client.auth.signOut();
        throw AuthFailure('ئەم هەژمارە ناچالاکە');
      }

      final dial = (phoneCountryCode ?? '').trim();
      final phone = (phoneNumber ?? '').replaceAll(RegExp(r'\D'), '');
      if (dial.isNotEmpty || phone.isNotEmpty) {
        try {
          await _client.from('profiles').update({
            'phone_country_code': dial.isEmpty
                ? null
                : (dial.startsWith('+') ? dial : '+$dial'),
            'phone_number': phone.isEmpty ? null : phone,
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          }).eq('id', user.id);
        } catch (e) {
          debugPrint('signup phone update skipped: $e');
        }
      }

      final fresh = await _profiles.fetchById(user.id) ?? profile;
      _applySession(fresh, user.email ?? trimmedEmail);
      return fresh;
    } on AuthFailure {
      rethrow;
    } on AuthException catch (e) {
      debugPrint('signUp AuthException: ${e.statusCode} ${e.message}');
      throw AuthFailure(_mapAuthError(e.message));
    } catch (e) {
      debugPrint('signUp failed: $e');
      throw AuthFailure('خۆتۆمارکردن سەرکەوتوو نەبوو');
    }
  }

  /// @Deprecated — verification flow removed; use [signUp].
  Future<void> sendSignUpOtp({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    await signUp(
      firstName: firstName,
      lastName: lastName,
      email: email,
      password: password,
    );
  }

  Future<void> resendSignUpOtp() async {
    final pending = await _ensurePendingLoaded();
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
    await _ensurePendingLoaded();
    final user = _client.auth.currentUser;
    final session = _client.auth.currentSession;
    if (user == null || session == null) {
      throw AuthFailure(
        'لینکی ئیمەیڵ لەم مۆبایلەدا بکەرەوە، یان لینکەکە لێرە بلکێنە. '
        'لە Supabase → Auth → URL Configuration زیاد بکە: edumaster://login-callback/',
      );
    }

    return _completeSignUp(user: user, email: user.email ?? '');
  }

  /// Paste the full email / callback link when deep link UI looks empty.
  Future<ProfileEntity> verifySignUpFromEmailLink(String rawLinkOrToken) async {
    await _ensurePendingLoaded();

    final input = rawLinkOrToken.trim();
    if (input.isEmpty) {
      throw AuthFailure('لینکی ئیمەیڵ بلکێنە');
    }

    try {
      final uri = Uri.tryParse(input);
      // PKCE / session callback: ?code=… or #access_token=…
      if (uri != null && _looksLikeAuthCallback(uri)) {
        final res = await _client.auth.getSessionFromUrl(uri);
        final session = res.session;
        final user = session.user;
        return _completeSignUp(user: user, email: user.email ?? '');
      }

      final tokenHash = _extractTokenHash(input);
      if (tokenHash == null) {
        throw AuthFailure(
          'لینکەکە نادروستە — هەموو لینکەکە کۆپی بکە '
          '(لە https:// دەست پێدەکات یان edumaster://login-callback)',
        );
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

      return _completeSignUp(user: user, email: user.email ?? '');
    } on AuthFailure {
      rethrow;
    } on AuthException catch (e) {
      throw AuthFailure(_mapAuthError(e.message));
    } catch (e) {
      debugPrint('verifySignUpFromEmailLink failed: $e');
      throw AuthFailure('پشتڕاستکردنەوە سەرکەوتوو نەبوو');
    }
  }

  /// Call once after Supabase.initialize — finishes signup when magic link opens app.
  void startAuthLinkWatcher() {
    _authLinkSub?.cancel();
    _authLinkSub = _client.auth.onAuthStateChange.listen((data) async {
      if (data.event != AuthChangeEvent.signedIn) return;
      if (_finalizingLink) return;
      await _ensurePendingLoaded();
      if (_pendingSignUp == null && data.session == null) return;
      // Only auto-finish when we still have a pending signup.
      if (_pendingSignUp == null) return;
      _finalizingLink = true;
      try {
        await finalizePendingSignUp();
        debugPrint('Auth link watcher: signup finalized');
      } catch (e) {
        debugPrint('Auth link watcher finalize failed: $e');
      } finally {
        _finalizingLink = false;
      }
    });
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
    await _ensurePendingLoaded();
    final pending = _pendingSignUp;
    final meta = user.userMetadata ?? {};

    final firstName = (pending?.firstName.isNotEmpty == true)
        ? pending!.firstName
        : ((meta['first_name'] as String?) ?? '').trim();
    final lastName = (pending?.lastName.isNotEmpty == true)
        ? pending!.lastName
        : ((meta['last_name'] as String?) ?? '').trim();
    final userName = (pending?.userName.isNotEmpty == true)
        ? pending!.userName
        : ((meta['user_name'] as String?) ??
            _buildUserName(email, firstName, lastName));

    if (pending != null && pending.password.isNotEmpty) {
      try {
        await _client.auth.updateUser(
          UserAttributes(password: pending.password),
        );
      } catch (e) {
        debugPrint('updateUser password after verify: $e');
      }
    }

    final profile = await _profiles.ensureProfile(
      id: user.id,
      email: email.isNotEmpty ? email : (user.email ?? pending?.email ?? ''),
      firstName: firstName,
      lastName: lastName,
      userName: userName,
    );

    await _clearPendingSignUp();
    _applySession(profile, email.isNotEmpty ? email : (user.email ?? ''));
    return profile;
  }

  bool _looksLikeAuthCallback(Uri uri) {
    final frag = Uri.splitQueryString(uri.fragment);
    return uri.queryParameters.containsKey('code') ||
        uri.queryParameters.containsKey('access_token') ||
        frag.containsKey('access_token') ||
        frag.containsKey('refresh_token');
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

  Future<void> clearPendingSignUp() => _clearPendingSignUp();

  Future<void> _setPendingSignUp(PendingSignUp pending) async {
    _pendingSignUp = pending;
    try {
      await _storage.write(key: _pendingKey, value: jsonEncode(pending.toJson()));
    } catch (e) {
      debugPrint('persist pending signup failed: $e');
    }
  }

  Future<PendingSignUp?> _ensurePendingLoaded() async {
    if (_pendingSignUp != null) return _pendingSignUp;
    try {
      final raw = await _storage.read(key: _pendingKey);
      if (raw == null || raw.isEmpty) return null;
      final map = jsonDecode(raw);
      if (map is Map<String, dynamic>) {
        _pendingSignUp = PendingSignUp.fromJson(map);
      } else if (map is Map) {
        _pendingSignUp =
            PendingSignUp.fromJson(Map<String, dynamic>.from(map));
      }
    } catch (e) {
      debugPrint('load pending signup failed: $e');
    }
    return _pendingSignUp;
  }

  Future<void> _clearPendingSignUp() async {
    _pendingSignUp = null;
    try {
      await _storage.delete(key: _pendingKey);
    } catch (e) {
      debugPrint('clear pending signup failed: $e');
    }
  }

  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      debugPrint('signOut error: $e');
    }
    await _clearPendingSignUp();
    final app = FFAppState();
    app.update(() {
      app.isLogin = false;
      app.currentPassword = '';
      app.deleteCurrentPassword();
      app.userDetail = LoginModelStruct();
      app.deleteUserDetail();
      app.profileAvatarUrl = '';
      app.phone = '';
      app.OngoingList = [];
      app.CompletedList = [];
      app.homePageIndex = 0;
    });
  }

  Future<bool> restoreSession() async {
    await _ensurePendingLoaded();
    final user = currentUser;
    if (user == null) {
      FFAppState().update(() {
        FFAppState().isLogin = false;
      });
      return false;
    }

    try {
      // Magic link may open a cold start with a session + pending signup.
      if (_pendingSignUp != null) {
        await _completeSignUp(user: user, email: user.email ?? '');
        return true;
      }

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
        msg.contains('security purposes') ||
        msg.contains('429')) {
      // Built-in SMTP is project-wide (not per click). Earlier tests count.
      return 'سنووری ئیمەیڵی Free Tierی پڕۆژەکە تەواو بووە '
          '(تاقیکردنەوەکانی پێشوو هەژمار دەکرێن، تەنها کلیکەکەی ئێستا نا). '
          '١–٢ کاتژمێر چاوەڕێ بکە یان SMTPی خۆت دابنێ.';
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

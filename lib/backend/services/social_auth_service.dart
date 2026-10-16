import 'dart:async';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '/backend/models/profile_entity.dart';
import '/backend/repositories/profile_repository.dart';
import '/backend/services/auth_service.dart';
import '/backend/supabase/supabase_bootstrap.dart';

/// Clean Architecture contract for third-party social authentication.
abstract class SocialAuthService {
  Future<ProfileEntity?> signInWithGoogle();
  Future<ProfileEntity?> signInWithApple();
}

/// Supabase-only Social Authentication implementation.
/// No Firebase is used or required.
class SupabaseSocialAuthService implements SocialAuthService {
  SupabaseSocialAuthService({
    SupabaseClient? client,
    ProfileRepository? profiles,
    void Function(ProfileEntity profile, String email)? onApplySession,
  })  : _client = client ?? SupabaseBootstrap.client,
        _profiles = profiles ?? SupabaseProfileRepository(),
        _onApplySession = onApplySession;

  final SupabaseClient _client;
  final ProfileRepository _profiles;
  final void Function(ProfileEntity profile, String email)? _onApplySession;

  static bool _googleInitialized = false;

  /// Returns the configured Web Client ID from .env (for Google IdToken verification).
  static String? get googleWebClientId {
    final id = dotenv.env['GOOGLE_WEB_CLIENT_ID']?.trim();
    return (id != null && id.isNotEmpty) ? id : null;
  }

  /// Returns the configured iOS Client ID from .env.
  static String? get googleIosClientId {
    final id = dotenv.env['GOOGLE_IOS_CLIENT_ID']?.trim();
    return (id != null && id.isNotEmpty) ? id : null;
  }

  /// Native or OAuth Google Sign-In via Supabase.
  @override
  Future<ProfileEntity?> signInWithGoogle() async {
    try {
      final webClientId = googleWebClientId;
      final iosClientId = googleIosClientId;

      // 1. Try Native Google Sign-In if client IDs or native environment is configured
      if (!kIsWeb && (webClientId != null || iosClientId != null)) {
        try {
          return await _signInWithGoogleNative(
            serverClientId: webClientId,
            clientId: iosClientId,
          );
        } catch (e) {
          debugPrint('Native Google Sign-In attempt failed: $e. Falling back to OAuth.');
        }
      }

      // 2. Fallback to Supabase Browser/Deep-Link OAuth
      final launched = await _client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: kIsWeb ? null : SupabaseBootstrap.authRedirectUrl,
      );

      if (!launched) {
        throw AuthFailure('Google sign-in could not be started.');
      }

      // In browser OAuth on mobile, the redirect callback will finish session sync.
      final currentUser = _client.auth.currentUser;
      if (currentUser != null) {
        return await _provisionSocialProfile(currentUser);
      }
      return null;
    } on AuthFailure {
      rethrow;
    } on AuthException catch (e) {
      throw AuthFailure(e.message);
    } catch (e) {
      debugPrint('signInWithGoogle error: $e');
      throw AuthFailure('Google sign-in failed. Please try again.');
    }
  }

  /// Native Google Sign-In using GoogleSignIn package + Supabase signInWithIdToken
  Future<ProfileEntity?> _signInWithGoogleNative({
    String? serverClientId,
    String? clientId,
  }) async {
    if (!_googleInitialized) {
      await GoogleSignIn.instance.initialize(
        serverClientId: serverClientId,
        clientId: clientId,
      );
      _googleInitialized = true;
    }

    final GoogleSignInAccount account = await GoogleSignIn.instance.authenticate();
    final idToken = account.authentication.idToken;

    if (idToken == null || idToken.isEmpty) {
      throw AuthFailure('Google ID Token was not returned.');
    }

    // Pass the native ID token directly to Supabase Auth
    final res = await _client.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
    );

    final user = res.user ?? _client.auth.currentUser;
    if (user == null) {
      throw AuthFailure('Supabase authentication with Google failed.');
    }

    final nameParts = (account.displayName ?? '').trim().split(' ');
    final firstName = nameParts.isNotEmpty ? nameParts.first : '';
    final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

    return await _provisionSocialProfile(
      user,
      fallbackFirstName: firstName,
      fallbackLastName: lastName,
      fallbackAvatarUrl: account.photoUrl,
    );
  }

  /// Native Apple Sign-In (iOS/macOS) or OAuth fallback (Android/Web) via Supabase.
  @override
  Future<ProfileEntity?> signInWithApple() async {
    try {
      final isApplePlatform = !kIsWeb &&
          (defaultTargetPlatform == TargetPlatform.iOS ||
              defaultTargetPlatform == TargetPlatform.macOS);

      if (isApplePlatform && await SignInWithApple.isAvailable()) {
        return await _signInWithAppleNative();
      }

      // Android/Web fallback: Supabase hosted Apple OAuth flow
      final launched = await _client.auth.signInWithOAuth(
        OAuthProvider.apple,
        redirectTo: kIsWeb ? null : SupabaseBootstrap.authRedirectUrl,
      );

      if (!launched) {
        throw AuthFailure('Apple sign-in could not be started.');
      }

      final currentUser = _client.auth.currentUser;
      if (currentUser != null) {
        return await _provisionSocialProfile(currentUser);
      }
      return null;
    } on AuthFailure {
      rethrow;
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        throw AuthFailure('Apple sign-in was canceled.');
      }
      throw AuthFailure('Apple authentication error: ${e.message}');
    } on AuthException catch (e) {
      throw AuthFailure(e.message);
    } catch (e) {
      debugPrint('signInWithApple error: $e');
      throw AuthFailure('Apple sign-in failed. Please try again.');
    }
  }

  /// Native Apple Sign-In with cryptographic nonce and Supabase ID token exchange
  Future<ProfileEntity?> _signInWithAppleNative() async {
    final rawNonce = _client.auth.generateRawNonce();
    final hashedNonce = sha256.convert(utf8.encode(rawNonce)).toString();

    final credential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      nonce: hashedNonce,
    );

    final idToken = credential.identityToken;
    if (idToken == null || idToken.isEmpty) {
      throw AuthFailure('Apple identity token could not be retrieved.');
    }

    final res = await _client.auth.signInWithIdToken(
      provider: OAuthProvider.apple,
      idToken: idToken,
      nonce: rawNonce,
    );

    final user = res.user ?? _client.auth.currentUser;
    if (user == null) {
      throw AuthFailure('Supabase authentication with Apple failed.');
    }

    return await _provisionSocialProfile(
      user,
      fallbackFirstName: credential.givenName ?? '',
      fallbackLastName: credential.familyName ?? '',
    );
  }

  /// Creates/updates the user's profile in Supabase profiles table and syncs app session.
  Future<ProfileEntity> _provisionSocialProfile(
    User user, {
    String? fallbackFirstName,
    String? fallbackLastName,
    String? fallbackAvatarUrl,
  }) async {
    final meta = user.userMetadata ?? {};
    final email = user.email ?? (meta['email'] as String?) ?? '';

    // Extract name from metadata or fallbacks
    String firstName = (meta['given_name'] as String?) ??
        (meta['first_name'] as String?) ??
        (fallbackFirstName ?? '');
    String lastName = (meta['family_name'] as String?) ??
        (meta['last_name'] as String?) ??
        (fallbackLastName ?? '');

    if (firstName.isEmpty && meta['full_name'] != null) {
      final parts = (meta['full_name'] as String).trim().split(' ');
      firstName = parts.isNotEmpty ? parts.first : '';
      if (lastName.isEmpty && parts.length > 1) {
        lastName = parts.sublist(1).join(' ');
      }
    } else if (firstName.isEmpty && meta['name'] != null) {
      final parts = (meta['name'] as String).trim().split(' ');
      firstName = parts.isNotEmpty ? parts.first : '';
      if (lastName.isEmpty && parts.length > 1) {
        lastName = parts.sublist(1).join(' ');
      }
    }

    if (firstName.isEmpty && lastName.isEmpty) {
      firstName = email.split('@').first;
    }

    final userName = (meta['user_name'] as String?) ??
        email.split('@').first.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');

    final profile = await _profiles.ensureProfile(
      id: user.id,
      email: email,
      firstName: firstName,
      lastName: lastName,
      userName: userName,
    );

    // Save avatar if available and not yet set
    final avatar = (meta['avatar_url'] as String?) ??
        (meta['picture'] as String?) ??
        fallbackAvatarUrl;
    if (avatar != null && avatar.isNotEmpty && (profile.avatarUrl == null || profile.avatarUrl!.isEmpty)) {
      try {
        await _client.from('profiles').update({
          'avatar_url': avatar,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        }).eq('id', user.id);
      } catch (e) {
        debugPrint('Social avatar update skipped: $e');
      }
    }

    final freshProfile = await _profiles.fetchById(user.id) ?? profile;

    if (_onApplySession != null) {
      _onApplySession!(freshProfile, email);
    }

    return freshProfile;
  }
}

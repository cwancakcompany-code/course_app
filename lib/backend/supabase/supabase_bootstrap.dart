import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Bootstraps Supabase using public env keys only (never the secret key).
class SupabaseBootstrap {
  SupabaseBootstrap._();

  static bool _initialized = false;

  static bool get isInitialized => _initialized;

  static Future<void> initialize() async {
    if (_initialized) return;

    await dotenv.load(fileName: '.env');

    final url = _requireEnv(const [
      'SUPABASE_URL',
      'NEXT_PUBLIC_SUPABASE_URL',
    ]);
    final anonKey = _requireEnv(const [
      'SUPABASE_PUBLISHABLE_KEY',
      'NEXT_PUBLIC_SUPABASE_ANON_KEY',
    ]);

    // PKCE + deep link so Free Tier magic-link emails can open the app.
    await Supabase.initialize(
      url: url,
      publishableKey: anonKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
        // Catch edumaster://login-callback/?code=… from the email link.
        detectSessionInUri: true,
      ),
    );
    _initialized = true;
  }

  /// Must also be allow-listed in Supabase → Authentication → URL Configuration.
  static String get authRedirectUrl {
    final fromEnv = (dotenv.env['SUPABASE_AUTH_REDIRECT_URL'] ?? '').trim();
    if (fromEnv.isNotEmpty) return fromEnv;
    return 'edumaster://login-callback/';
  }

  static SupabaseClient get client {
    if (!_initialized) {
      throw StateError('SupabaseBootstrap.initialize() must run first.');
    }
    return Supabase.instance.client;
  }

  static String _requireEnv(List<String> keys) {
    for (final key in keys) {
      final value = dotenv.env[key]?.trim();
      if (value != null && value.isNotEmpty) {
        return value;
      }
    }
    throw StateError(
      'Missing env value. Expected one of: ${keys.join(', ')}',
    );
  }
}

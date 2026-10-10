import '/backend/services/auth_service.dart';

/// Restores app login state from Supabase Auth session (if any).
Future<bool> syncAuthSession() async {
  return AuthService().restoreSession();
}

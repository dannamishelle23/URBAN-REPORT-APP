import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<void> login({
    required String email,
    required String password,
  }) async {
    await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> register({
  required String email,
  required String password,
  String? fullName,
  String? telefono,
}) async {
  await _supabase.auth.signUp(
    email: email,
    password: password,
    emailRedirectTo: 'urbanreport://login-callback',
    data: {
      'full_name': fullName,
      'telefono': telefono,
    },
  );
}

  Future<void> resetPassword(String email) async {
    await _supabase.auth.resetPasswordForEmail(
      email,
      redirectTo: 'urbanreport://login-callback',
    );
  }

  Future<void> logout() async {
    await _supabase.auth.signOut();
  }
}
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
    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
    );

    // Guardar nombre y teléfono en la tabla profiles
    if (response.user != null && (fullName != null || telefono != null)) {
      await _supabase.from('profiles').upsert({
        'id': response.user!.id,
        'email': email,
        'full_name': fullName,
        'telefono': telefono,
      });
    }
  }

  Future<void> resetPassword(String email) async {
    await _supabase.auth.resetPasswordForEmail(email);
  }

  Future<void> logout() async {
    await _supabase.auth.signOut();
  }
}

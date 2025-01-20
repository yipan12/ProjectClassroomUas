import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final _supabase = Supabase.instance.client;

  // Register tanpa email confirmation
  Future<void> signUp(String email, String password) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        // Verifikasi email dinonaktifkan di dashboard Supabase
      );
      if (response.user != null) {
        print('Registrasi berhasil: ${response.user!.email}');
      }
    } catch (e) {
      throw Exception('Gagal registrasi: $e');
    }
  }

  // Login
  Future<void> signIn(String email, String password) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (response.user != null) {
        print('Login berhasil: ${response.user!.email}');
      }
    } catch (e) {
      throw Exception('Gagal login: $e');
    }
  }

  // Logout
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
      print('Logout berhasil');
    } catch (e) {
      throw Exception('Gagal logout: $e');
    }
  }

  // Mendapatkan user yang sedang login
  User? getCurrentUser() {
    return _supabase.auth.currentUser;
  }
}

import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRemoteDataSource {
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  // 1. E-posta, Şifre ve Ekstra Profil Detaylarıyla Kayıt Olma
  Future<User?> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
    required DateTime birthDate,
    required List<String> goals,
    required String experienceLevel,
    required String? gymId,
  }) async {
    try {
      // Önce ana kimlik (Auth) kaydını yapıyoruz
      final response = await _supabaseClient.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName},
      );

      final user = response.user;

      // Kayıt başarılıysa, ekstra detayları 'profiles' tablosuna ekliyoruz
      if (user != null) {
        await _supabaseClient.from('profiles').insert({
          'auth_id': user.id,
          'full_name': fullName,
          'birth_date': birthDate.toIso8601String().split('T').first,
          'experience_level': experienceLevel,
          'goals': goals,
          'gym_id': gymId,
          'is_online': true, // Yeni kayıt olan biri anında çevrimiçi görünür
        });
      }

      return user;
    } on AuthException catch (e) {
      if (e.message.contains('User already registered')) {
        throw Exception('Bu e-posta adresi zaten kullanımda.');
      }
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Beklenmeyen bir hata oluştu: $e');
    }
  }

  // 2. E-posta ve Şifre ile Giriş Yapma
  Future<User?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response.user;
    } on AuthException catch (e) {
      if (e.message.contains('Invalid login credentials')) {
        throw Exception('E-posta veya şifre geçersiz.');
      }
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Beklenmeyen bir hata oluştu: $e');
    }
  }

  // 3. Çıkış Yapma
  Future<void> signOut() async {
    await _supabaseClient.auth.signOut();
  }

  // 4. Aktif Kullanıcıyı Getirme
  User? get currentUser => _supabaseClient.auth.currentUser;
}

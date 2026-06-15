import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:gym_buddy/data/datasources/auth_remote_data_source.dart';

// 1. Veri kaynağımızı sağlayan temel provider
final authDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSource();
});

// 2. Arayüzde göstereceğimiz durumları tutan sınıf (Aynı kalıyor)
class AuthState {
  final bool isLoading;
  final String? error;
  final User? user;

  AuthState({this.isLoading = false, this.error, this.user});

  AuthState copyWith({bool? isLoading, String? error, User? user}) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      user: user ?? this.user,
    );
  }
}

// 3. MODERN YAPI: StateNotifier yerine Notifier kullanıyoruz
class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    // Uygulama açıldığında ilk tetiklenen state (durum)
    final dataSource = ref.read(authDataSourceProvider);
    return AuthState(user: dataSource.currentUser);
  }

  Future<bool> signIn(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // ref objesine doğrudan erişebiliyoruz
      final user = await ref
          .read(authDataSourceProvider)
          .signInWithEmail(email: email, password: password);
      state = state.copyWith(isLoading: false, user: user);
      return true; // Başarılı
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      state = state.copyWith(isLoading: false, error: e.toString().replaceAll('Exception: ', ''));
      return false; // Başarısız
    }
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String fullName,
    required DateTime birthDate,
    required List<String> goals,
    required String experienceLevel,
    required String? gymId,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await ref
          .read(authDataSourceProvider)
          .signUpWithEmail(
            email: email,
            password: password,
            fullName: fullName,
            birthDate: birthDate,
            goals: goals,
            experienceLevel: experienceLevel,
            gymId: gymId,
          );
      state = state.copyWith(isLoading: false, user: user);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      state = state.copyWith(isLoading: false, error: e.toString().replaceAll('Exception: ', ''));
      return false;
    }
  }

  Future<void> signOut() async {
    state = state.copyWith(isLoading: true);
    await ref.read(authDataSourceProvider).signOut();
    state = AuthState(); // Temiz state'e dön
  }
}

// 4. MODERN YAPI: StateNotifierProvider yerine NotifierProvider
final authProvider = NotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});

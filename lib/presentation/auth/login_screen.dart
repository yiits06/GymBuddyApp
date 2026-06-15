import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../home/main_layout.dart';
import 'register_screen.dart';
import 'register_controller.dart';
import 'forgot_password_screen.dart';

// Riverpod state'lerini okuyabilmek için ConsumerStatefulWidget kullanıyoruz
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Giriş Yapma Tetikleyicisi
  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'login.enter_email_password'.tr(),
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    // AuthProvider üzerinden Supabase'e giriş isteği atıyoruz
    final success = await ref
        .read(authProvider.notifier)
        .signIn(email, password);

    if (mounted) {
      if (success) {
        // Giriş başarılıysa ana sayfaya yönlendir
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const MainLayout()),
          (route) => false, // Geri dönme butonunu iptal et
        );
      } else {
        // Başarısızsa Riverpod'daki hatayı ekrana bas
        final error = ref.read(authProvider).error;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              error ?? 'login.login_failed'.tr(),
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // AuthProvider'ın o anki durumunu (Yükleniyor mu? Hata var mı?) canlı izliyoruz
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              // Geri Butonu
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
                padding: EdgeInsets.zero,
                alignment: Alignment.centerLeft,
              ),
              const SizedBox(height: 40),
              Text(
                'login.welcome_back'.tr(),
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w900,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'login.partner_waiting'.tr(),
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),

              const SizedBox(height: 60),

              // E-posta Kutusu
              TextField(
                controller: _emailController,
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'auth.email'.tr(),
                  hintStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: const Color(0xFF1E1E1E),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(
                    Icons.email_outlined,
                    color: Colors.grey,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Şifre Kutusu
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'auth.password'.tr(),
                  hintStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: const Color(0xFF1E1E1E),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(
                    Icons.lock_outline,
                    color: Colors.grey,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Şifremi Unuttum
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ForgotPasswordScreen(),
                      ),
                    );
                  },
                  child: Text(
                    'login.forgot_password'.tr(),
                    style: const TextStyle(
                      color: AppTheme.neonLime,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Giriş Yap Butonu (Canlı Yüklenme Efektli)
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.neonLime,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: authState.isLoading ? null : _handleLogin,
                  child: authState.isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.black,
                            strokeWidth: 3,
                          ),
                        )
                      : Text(
                          'welcome.login'.tr(),
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 40),

              // Kayıt Ol Yönlendirmesi
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'login.no_account'.tr(),
                    style: const TextStyle(color: Colors.grey),
                  ),
                  GestureDetector(
                    onTap: () {
                      // ÇÖZÜM 1: Kayıt ekranına girmeden hemen önce hafızayı zorla sıfırlıyoruz
                      ref.read(registerProvider.notifier).reset();

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RegisterScreen(),
                        ),
                      );
                    },
                    child: Text(
                      'login.register'.tr(),
                      style: const TextStyle(
                        color: AppTheme.neonLime,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

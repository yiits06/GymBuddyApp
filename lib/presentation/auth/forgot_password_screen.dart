import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../core/theme/app_theme.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('forgot_password.enter_registered_email'.tr(), style: const TextStyle(color: Colors.white)),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Supabase ile e-postaya şifre sıfırlama bağlantısı gönderiyoruz
      await Supabase.instance.client.auth.resetPasswordForEmail(email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'forgot_password.link_sent'.tr(),
              style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
            backgroundColor: AppTheme.neonLime,
          ),
        );
        Navigator.pop(context); // İşlem başarılıysa giriş ekranına geri dön
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('forgot_password.error_occurred'.tr(), style: const TextStyle(color: Colors.white)),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                'forgot_password.title'.tr(),
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w900,
                  height: 1.1,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'forgot_password.instruction'.tr(),
                style: const TextStyle(color: Colors.grey, fontSize: 16),
              ),
              const SizedBox(height: 60),
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
                  prefixIcon: const Icon(Icons.email_outlined, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.neonLime,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: _isLoading ? null : _resetPassword,
                  child: _isLoading
                      ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 3))
                      : Text('forgot_password.send_link'.tr(), style: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

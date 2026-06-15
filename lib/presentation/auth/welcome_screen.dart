import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/gym_buddy_button.dart';
import 'login_screen.dart';
import 'register_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Arka Plan Ağırlık İtme Görseli
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(
                  'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?q=80&w=1000&auto=format&fit=crop',
                ), // Sled itme görseli
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Karartma Gradient (Yazıların okunması için)
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.4),
                  Colors.black.withValues(alpha: 0.85),
                ],
              ),
            ),
          ),
          // İçerik Katmanı
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'GYMBUDDY',
                    style: TextStyle(
                      fontSize: 42,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.neonLime,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(width: 60, height: 4, color: AppTheme.neonLime),
                  const SizedBox(height: 40),
                  Text(
                    'welcome.subtitle'.tr(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'welcome.premium_community'.tr(),
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Hemen Başla Butonu (Kayıt Ekranına Gider)
                  GymBuddyButton(
                    text: 'welcome.start_now'.tr(),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RegisterScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  // Giriş Yap Butonu
                  GymBuddyButton(
                    text: 'welcome.login'.tr(),
                    isSecondary: true,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 32),

                  // Alt Canlı İstatistik Barları
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildFooterInfo(Colors.green, 'welcome.online_partners'.tr()),
                      const SizedBox(width: 24),
                      _buildFooterInfo(
                        AppTheme.neonLime,
                        'welcome.verified_profiles'.tr(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterInfo(Color dotColor, String text) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

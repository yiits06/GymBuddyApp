import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:easy_localization/easy_localization.dart';
import 'core/theme/app_theme.dart';
import 'presentation/auth/welcome_screen.dart';

// main fonksiyonunu async (asenkron) yapıyoruz
Future<void> main() async {
  // Supabase'in düzgün çalışması için Flutter motorunu başlatıyoruz
  WidgetsFlutterBinding.ensureInitialized();

  // Dil motorunu başlatıyoruz
  await EasyLocalization.ensureInitialized();

  // Supabase veritabanı bağlantımızı kuruyoruz
  await Supabase.initialize(
    url: 'https://rzokelhimzfacvwewxcj.supabase.co',
    publishableKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJ6b2tlbGhpbXpmYWN2d2V3eGNqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODEwNjQ4NjUsImV4cCI6MjA5NjY0MDg2NX0.vA-cCHUmq0k5wy_7tJAlG58rm-5I5yLJe0HiX7q64C0', // Kopyaladığın o uzun şifreyi buraya yapıştır
  );

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('tr'), Locale('en')],
      path: 'assets/translations', // JSON dosyalarımızın olduğu yol
      fallbackLocale: const Locale('tr'), // Varsayılan dil
      child: const ProviderScope(child: MyApp()),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      title: 'GymBuddy',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const WelcomeScreen(), // İlk açılışta Karşılama Ekranı gelecek
    );
  }
}

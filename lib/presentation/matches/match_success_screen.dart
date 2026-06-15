import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../chat/chat_detail_screen.dart';

class MatchSuccessScreen extends StatelessWidget {
  final String matchedUserId;
  final String matchedUserName;
  final String matchedUserImage;
  final String currentUserImage;

  const MatchSuccessScreen({
    super.key,
    required this.matchedUserId,
    required this.matchedUserName,
    required this.matchedUserImage,
    required this.currentUserImage,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212).withValues(alpha: 0.95), // Yarı saydam arka plan hissi
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'EŞLEŞTİNİZ!',
                style: TextStyle(
                  fontFamily: 'Impact', // Kalın ve dikkat çekici bir font için
                  fontSize: 46,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.neonLime,
                  letterSpacing: 2.0,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Sen ve $matchedUserName birbirinizi beğendiniz.\nŞimdi antrenman planlama zamanı!',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 48),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Align(
                    widthFactor: 0.8,
                    child: CircleAvatar(
                      radius: 64,
                      backgroundColor: AppTheme.neonLime,
                      child: CircleAvatar(
                        radius: 60,
                        backgroundImage: NetworkImage(
                          currentUserImage.isNotEmpty
                              ? currentUserImage
                              : 'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?q=80&w=200',
                        ),
                      ),
                    ),
                  ),
                  Align(
                    widthFactor: 0.8,
                    child: CircleAvatar(
                      radius: 64,
                      backgroundColor: AppTheme.neonLime,
                      child: CircleAvatar(
                        radius: 60,
                        backgroundImage: NetworkImage(
                          matchedUserImage.isNotEmpty
                              ? matchedUserImage
                              : 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?q=80&w=200',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 64),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.neonLime,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  onPressed: () {
                    // Mesaj gönder butonuna basınca eşleşme ekranını kapatıp mesaj detayına yönlendirir
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatDetailScreen(
                          userId: matchedUserId,
                          userName: matchedUserName,
                          userImage: matchedUserImage,
                        ),
                      ),
                    );
                  },
                  child: const Text(
                    'Mesaj Gönder',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.grey),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Keşfetmeye Devam Et',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
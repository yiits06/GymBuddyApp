import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/user_model.dart';
import '../chat/chat_detail_screen.dart';
import '../providers/like_provider.dart';

class MatchProfileScreen extends ConsumerWidget {
  final UserModel user;

  const MatchProfileScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          user.fullName,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: [
          PopupMenuButton<String>(
            color: const Color(0xFF1E1E1E),
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) async {
              if (value == 'unmatch') {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: const Color(0xFF1E1E1E),
                    title: const Text('Eşleşmeyi Kaldır', style: TextStyle(color: Colors.white)),
                    content: Text(
                      '${user.fullName} ile olan eşleşmeni kaldırmak istediğine emin misin?',
                      style: const TextStyle(color: Colors.grey),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('İptal', style: TextStyle(color: Colors.grey)),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Kaldır', style: TextStyle(color: Colors.redAccent)),
                      ),
                    ],
                  ),
                );

                if (confirm == true) {
                  await ref.read(likeRepositoryProvider).unmatchUser(user.id);
                  ref.invalidate(myMatchesProvider); // Eşleşmeler listesini güncelle
                  if (context.mounted) {
                    Navigator.pop(context); // Profil sayfasından çıkıp listeye dön
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Eşleşme kaldırıldı.'),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                  }
                }
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'unmatch',
                child: Text('Eşleşmeyi Kaldır', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Profil Resmi
            if (user.avatarUrl != null && user.avatarUrl!.isNotEmpty)
              Image.network(
                user.avatarUrl!,
                height: 400,
                fit: BoxFit.cover,
              )
            else
              Container(
                height: 400,
                color: const Color(0xFF1E1E1E),
                child: const Icon(Icons.person, size: 100, color: Colors.grey),
              ),
            
            // Detaylar
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${user.fullName}${user.age != null ? ', ${user.age}' : ''}',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow(
                    Icons.fitness_center, 
                    user.experienceLevel ?? 'Seviye Belirtilmedi'
                  ),
                  const SizedBox(height: 10),
                  _buildInfoRow(
                    Icons.location_on, 
                    (user.gymId != null && user.gymId!.isNotEmpty) ? user.gymId! : 'Salon Belirtilmedi'
                  ),
                  const SizedBox(height: 24),
                  
                  const Text(
                    'Odak Hedefler',
                    style: TextStyle(
                      fontSize: 18, 
                      fontWeight: FontWeight.bold, 
                      color: AppTheme.neonLime,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: user.goals.map((goal) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E1E),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
                      ),
                      child: Text(goal, style: const TextStyle(color: Colors.white)),
                    )).toList(),
                  ),
                  const SizedBox(height: 80), // Butonun içeriği kapatmaması için boşluk
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.neonLime,
        onPressed: () => Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ChatDetailScreen(
              userId: user.id,
              userName: user.fullName,
              userImage: user.avatarUrl ?? '',
            ),
          ),
        ),
        icon: const Icon(Icons.chat_bubble, color: Colors.black),
        label: const Text('Mesaj Gönder', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey, size: 22),
        const SizedBox(width: 12),
        Text(text, style: const TextStyle(color: Colors.grey, fontSize: 16)),
      ],
    );
  }
}
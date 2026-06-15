import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme/app_theme.dart';
import '../providers/profile_provider.dart';
import '../chat/chat_detail_screen.dart';
import '../../data/models/user_model.dart'; // Modelini kullanıyoruz!

class MatchesScreen extends ConsumerWidget {
  const MatchesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authUid = Supabase.instance.client.auth.currentUser?.id ?? '';
    final profilesAsync = ref.watch(profilesProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Eşleşmelerim',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20),
        ),
      ),
      body: profilesAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppTheme.neonLime),
        ),
        error: (err, _) => Center(
          child: Text(
            'Yüklenemedi: $err',
            style: const TextStyle(color: Colors.red),
          ),
        ),
        data: (rawProfiles) {
          // FutureBuilder ile eşleşmeleri view'dan çekiyoruz
          return FutureBuilder(
            future: Supabase.instance.client
                .from('matches_view')
                .select('*')
                .or('user1_id.eq.$authUid,user2_id.eq.$authUid'),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(color: AppTheme.neonLime),
                );
              }

              final List<dynamic> matches = snapshot.data as List<dynamic>;

              // Eşleştiğimiz ID'leri al
              final matchedIds = matches
                  .map(
                    (m) => m['user1_id'] == authUid
                        ? m['user2_id']
                        : m['user1_id'],
                  )
                  .toList();

              // Eşleştiğimiz kullanıcıları modelleyerek filtrele
              final matchedUsers = rawProfiles
                  .where((p) => matchedIds.contains(p['id'].toString()))
                  .map((p) => UserModel.fromJson(p))
                  .toList();

              if (matchedUsers.isEmpty) {
                return const Center(
                  child: Text(
                    'Henüz bir eşleşmen yok, keşfetmeye devam et!',
                    style: TextStyle(color: Colors.grey),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                itemCount: matchedUsers.length,
                itemBuilder: (context, index) {
                  final user = matchedUsers[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        radius: 28,
                        backgroundImage: NetworkImage(
                          user.avatarUrl ??
                              'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?q=80&w=200',
                        ),
                      ),
                      title: Text(
                        user.fullName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        'Seviye: ${user.experienceLevel ?? 'Belirtilmedi'}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.chat_bubble,
                          color: AppTheme.neonLime,
                        ),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatDetailScreen(
                              userId: user.id,
                              userName: user.fullName,
                              userImage: user.avatarUrl ?? '',
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme/app_theme.dart';
import '../providers/chat_provider.dart';
import '../providers/profile_provider.dart';
import '../providers/like_provider.dart';
import 'chat_detail_screen.dart';

class MessagesScreen extends ConsumerStatefulWidget {
  const MessagesScreen({super.key});

  @override
  ConsumerState<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends ConsumerState<MessagesScreen> {
  // Zaman damgasını saat:dakika formatına çeviren yardımcı fonksiyon
  String _formatTime(String? timestamp) {
    if (timestamp == null) return '';
    try {
      final date = DateTime.parse(timestamp).toLocal();
      final hour = date.hour.toString().padLeft(2, '0');
      final minute = date.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentProfileIdAsync = ref.watch(currentProfileIdProvider);
    final currentProfileId = currentProfileIdAsync.value;

    // Hem tüm mesajları hem de topluluk profillerini aynı anda izliyoruz
    final messagesAsync = ref.watch(allMessagesStreamProvider);
    final profilesAsync = ref.watch(allProfilesProvider);
    final matchesAsync = ref.watch(myMatchesProvider);

    // Profil ID'si yüklenene kadar bekle
    if (currentProfileId == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: AppTheme.neonLime)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'GymBuddy',
          style: TextStyle(
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: messagesAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppTheme.neonLime),
        ),
        error: (err, _) => Center(
          child: Text(
            'Mesajlar yüklenemedi: $err',
            style: const TextStyle(color: Colors.red),
          ),
        ),
        data: (messages) {
          return profilesAsync.when(
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppTheme.neonLime),
            ),
            error: (err, _) => Center(
              child: Text(
                'Profiller yüklenemedi: $err',
                style: const TextStyle(color: Colors.red),
              ),
            ),
            data: (profiles) {
              // GELEN MESAJLARI KİŞİLERE GÖRE GRUPLAMA ALGORİTMASI
              final Map<String, Map<String, dynamic>> targetChats = {};

              for (var msg in messages) {
                final senderId = msg['sender_id'].toString();
                final receiverId = msg['receiver_id'].toString();

                // KESİN ÇÖZÜM: Kendi kendine gönderilen bozuk test mesajlarını tamamen yoksay
                if (senderId == receiverId) continue;

                // Mesajlaşma ortağımızın gerçek ID'sini buluyoruz
                final partnerId = senderId == currentProfileId
                    ? receiverId
                    : senderId;
                    
                // Mesajın benim için okunmamış olup olmadığını kontrol et
                final isUnreadForMe = receiverId == currentProfileId && msg['is_read'] != true;

                // Eğer bu kişiyle olan sohbeti daha önce eklemediysek ekle (İlk gelen en güncelidir)
                if (!targetChats.containsKey(partnerId)) {
                  // Ortak ID'sine sahip kullanıcının profil bilgilerini buluyoruz
                  final partnerProfile = profiles.firstWhere(
                    (p) => p['id'].toString() == partnerId,
                    orElse: () => <String, dynamic>{},
                  );

                  if (partnerProfile.isNotEmpty) {
                    targetChats[partnerId] = {
                      'id': partnerId,
                      'name': partnerProfile['full_name'] ?? 'İsimsiz Sporcu',
                      'img':
                          partnerProfile['avatar_url'] ??
                          'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?q=80&w=100',
                      'lastMsg': msg['content'] ?? '',
                      'time': _formatTime(msg['created_at'].toString()),
                      'unreadCount': isUnreadForMe ? 1 : 0,
                    };
                  }
                } else {
                  // Sohbet daha önce eklendiyse ve yeni incelenen mesaj da okunmamışsa sayacı artır
                  if (isUnreadForMe && targetChats[partnerId] != null) {
                    targetChats[partnerId]!['unreadCount'] = (targetChats[partnerId]!['unreadCount'] as int) + 1;
                  }
                }
              }

              final dynamicChatList = targetChats.values.toList();

              return Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  _buildMatchesSection(matchesAsync),
                  const SizedBox(height: 24),
                    const Text(
                      'Mesajlar',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Expanded(child: buildChatListView(dynamicChatList)),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildMatchesSection(AsyncValue<List<Map<String, dynamic>>> matchesAsync) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Eşleşmeler',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 100,
          child: matchesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.neonLime)),
            error: (err, _) => Text('Hata: $err', style: const TextStyle(color: Colors.red)),
            data: (matches) {
              if (matches.isEmpty) {
                return const Center(
                  child: Text('Henüz eşleşmeniz yok. Keşfetmeye devam!', style: TextStyle(color: Colors.grey)),
                );
              }
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: matches.length,
                itemBuilder: (context, index) {
                  final match = matches[index];
                  return GestureDetector(
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatDetailScreen(
                            userId: match['id'].toString(),
                            userName: match['full_name'] ?? 'İsimsiz',
                            userImage: match['avatar_url'] ?? 'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?q=80&w=100',
                          ),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 32,
                            backgroundColor: AppTheme.neonLime,
                            child: CircleAvatar(
                              radius: 30,
                              backgroundImage: NetworkImage(match['avatar_url'] ?? 'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?q=80&w=100'),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            (match['full_name'] ?? '').split(' ').first,
                            style: const TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget buildChatListView(List<Map<String, dynamic>> list) {
    if (list.isEmpty) {
      return const Center(
        child: Text(
          'Henüz hiç mesajınız yok.\nEşleşmeler sekmesinden bir sohbet başlatın!',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey, height: 1.5),
        ),
      );
    }

    return ListView.builder(
      itemCount: list.length,
      itemBuilder: (context, index) {
        final chat = list[index];

        return GestureDetector(
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatDetailScreen(
                  userId: chat['id'].toString(),
                  userName: chat['name'].toString(),
                  userImage: chat['img'].toString(),
                ),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundImage: NetworkImage(chat['img'].toString()),
                ),
                const SizedBox(width: 14),
                // BURADA EXPANDED İLE TAŞMA HATASINI ÖNLÜYORUZ
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            // İsim de taşmasın diye
                            child: Text(
                              chat['name'].toString(),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            chat['time'].toString(),
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              chat['lastMsg'].toString(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: (chat['unreadCount'] as int? ?? 0) > 0 ? Colors.white : Colors.grey,
                                fontWeight: (chat['unreadCount'] as int? ?? 0) > 0 ? FontWeight.bold : FontWeight.normal,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          if ((chat['unreadCount'] as int? ?? 0) > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.redAccent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                chat['unreadCount'].toString(),
                                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

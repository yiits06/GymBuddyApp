import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme/app_theme.dart';
import '../providers/like_provider.dart';
import '../chat/chat_detail_screen.dart';
import '../../data/models/user_model.dart'; // Modelini kullanıyoruz!
import 'match_profile_screen.dart'; // Yeni oluşturduğumuz Profil Detay Sayfası

class MatchesScreen extends ConsumerStatefulWidget {
  const MatchesScreen({super.key});

  @override
  ConsumerState<MatchesScreen> createState() => _MatchesScreenState();
}

class _MatchesScreenState extends ConsumerState<MatchesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final matchesAsync = ref.watch(myMatchesProvider);

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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Eşleşmelerde ara...',
                hintStyle: const TextStyle(color: Colors.grey),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: const Color(0xFF1E1E1E),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: matchesAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppTheme.neonLime),
              ),
              error: (err, _) => Center(
                child: Text(
                  'Yüklenemedi: $err',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
              data: (matchedProfiles) {
                if (matchedProfiles.isEmpty) {
                  return const Center(
                    child: Text(
                      'Henüz bir eşleşmen yok, keşfetmeye devam et!',
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                // Modeli kullanarak eşleşmeleri dönüştürüyoruz ve arama metnine göre filtreliyoruz
                final matchedUsers = matchedProfiles
                    .map((p) => UserModel.fromJson(p))
                    .where((user) => user.fullName
                        .toLowerCase()
                        .contains(_searchQuery.toLowerCase()))
                    .toList();

                if (matchedUsers.isEmpty && _searchQuery.isNotEmpty) {
                  return const Center(
                    child: Text(
                      'Aradığınız kişi bulunamadı.',
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
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MatchProfileScreen(user: user),
                          ),
                        );
                      },
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
            ),
          ),
        ],
      ),
    );
  }
}

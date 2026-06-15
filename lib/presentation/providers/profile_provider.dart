import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/auth_provider.dart';

class ProfileNotifier
    extends StateNotifier<AsyncValue<List<Map<String, dynamic>>>> {
  ProfileNotifier() : super(const AsyncValue.loading()) {
    fetch();
  }

  Future<void> fetch() async {
    if (!mounted) return;
    state = const AsyncValue.loading();

    try {
      final client = Supabase.instance.client;
      final currentUserId = client.auth.currentUser?.id;

      if (currentUserId == null) {
        throw Exception('Kullanici oturumu bulunamadi!');
      }

      // 1. Kendi profil ID'mizi alalım
      final myProfileData = await client
          .from('profiles')
          .select('id')
          .or('auth_id.eq.$currentUserId,id.eq.$currentUserId')
          .limit(1);
          
      final myProfileId = myProfileData.isNotEmpty ? myProfileData.first['id']?.toString() : null;

      // 2. Beğendiğimiz kullanıcıların listesini alalım
      final likesData = myProfileId != null 
          ? await client.from('likes').select('liked_id').eq('liker_id', myProfileId)
          : [];
      final likedIds = (likesData as List).map((e) => e['liked_id'].toString()).toSet();

      final data = await client.from('profiles').select('*');

      // 3. Kendimizi tutalım (UI için gerekli), ama beğendiklerimizi filtreleyelim
      final filteredData = (data as List).where((p) {
        final pId = p['id'].toString();
        if (pId == myProfileId) return true; // Kendi profilimiz kalmalı
        if (likedIds.contains(pId)) return false; // Beğendiklerimizi çıkar
        return true;
      }).toList();

      if (!mounted) return;
      state = AsyncValue.data(List<Map<String, dynamic>>.from(filteredData));
    } catch (e, stack) {
      if (!mounted) return;
      state = AsyncValue.error(e, stack);
    }
  }
}

final profilesProvider =
    StateNotifierProvider.autoDispose<
      ProfileNotifier,
      AsyncValue<List<Map<String, dynamic>>>
    >((ref) {
      // Auth (Giriş/Çıkış) durumu değiştiğinde bu sağlayıcı sıfırlanacak
      ref.watch(authProvider);
      return ProfileNotifier();
    });

class ProfileRepository {
  final _supabase = Supabase.instance.client;

  Future<void> updateCurrentProfile({
    required String name,
    required String experienceLevel,
    required List<String> goals,
  }) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('Kullanici bulunamadi!');

    await _supabase
        .from('profiles')
        .update({
          'full_name': name,
          'experience_level': experienceLevel,
          'goals': goals,
        })
        .eq('auth_id', userId);
  }
}

final profileRepositoryProvider = Provider((ref) => ProfileRepository());

// This provider fetches ALL user profiles without any filtering.
// It's useful for looking up user info in chats, matches, etc.
final allProfilesProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  // Auth (Giriş/Çıkış) durumu değiştiğinde bu sağlayıcı sıfırlanacak
  ref.watch(authProvider);
  final client = Supabase.instance.client;
  final data = await client.from('profiles').select('*');
  return List<Map<String, dynamic>>.from(data);
});

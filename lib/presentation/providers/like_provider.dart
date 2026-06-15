import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/auth_provider.dart';

final supabase = Supabase.instance.client;
final likeRepositoryProvider = Provider((ref) => LikeRepository());

class LikeRepository {
  // Hem beğenen hem beğenilen için sadece profil tablosundaki saf 'id' değerlerini kullanıyoruz
  Future<bool> likeUser({
    required String myProfileId,
    required String likedProfileId,
  }) async {
    if (myProfileId.isEmpty || likedProfileId.isEmpty) return false;

    try {
      await supabase.from('likes').insert({
        'liker_id': myProfileId,
        'liked_id': likedProfileId,
      });
    } catch (e) {
      // Duplicate likes are tolerated; the match check below still determines the result.
    }

    // Karşı taraf da benim profil ID'mi beğenmiş mi sorgusu
    final checkMatch = await supabase
        .from('likes')
        .select('id')
        .eq('liker_id', likedProfileId)
        .eq('liked_id', myProfileId);

    return checkMatch.isNotEmpty;
  }
}

// Eşleştiğim kişilerin ID listesini getiren Provider
final myMatchesProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  // Auth (Giriş/Çıkış) durumu değiştiğinde bu sağlayıcı sıfırlanacak
  ref.watch(authProvider);
  final myId = Supabase.instance.client.auth.currentUser?.id;
  if (myId == null) return [];

  final profileData = await Supabase.instance.client.from('profiles').select('id').or('auth_id.eq.$myId,id.eq.$myId').limit(1);
  final myProfileId = profileData.isNotEmpty ? profileData.first['id']?.toString() : null;
  if (myProfileId == null) return [];

  final myLikes = await Supabase.instance.client.from('likes').select('liked_id').eq('liker_id', myProfileId);
  final myLikedIds = (myLikes as List).map((e) => e['liked_id'].toString()).toList();
  if (myLikedIds.isEmpty) return [];

  final matches = await Supabase.instance.client.from('likes').select('liker_id').inFilter('liker_id', myLikedIds).eq('liked_id', myProfileId);
  final matchedIds = (matches as List).map((e) => e['liker_id'].toString()).toList();
  if (matchedIds.isEmpty) return [];

  final matchedProfiles = await Supabase.instance.client.from('profiles').select('*').inFilter('id', matchedIds);
  return List<Map<String, dynamic>>.from(matchedProfiles);
});

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

  // Eşleşmeyi kaldırmak için kullanılan fonksiyon
  Future<bool> unmatchUser(String matchedProfileId) async {
    try {
      final myId = supabase.auth.currentUser?.id;
      if (myId == null) return false;

      final profileData = await supabase.from('profiles').select('id').or('auth_id.eq.$myId,id.eq.$myId').limit(1);
      final myProfileId = profileData.isNotEmpty ? profileData.first['id']?.toString() : null;
      if (myProfileId == null) return false;

      // Karşılıklı beğenileri (likes tablosundaki kayıtları) sil
      await supabase.from('likes').delete().match({'liker_id': myProfileId, 'liked_id': matchedProfileId});
      await supabase.from('likes').delete().match({'liker_id': matchedProfileId, 'liked_id': myProfileId});
      
      // Eşleşme tamamen kalksın diye aralarındaki sohbet geçmişini (messages tablosunu) de sil
      await supabase.from('messages').delete().match({'sender_id': myProfileId, 'receiver_id': matchedProfileId});
      await supabase.from('messages').delete().match({'sender_id': matchedProfileId, 'receiver_id': myProfileId});
      
      return true;
    } catch (e) {
      return false;
    }
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

  final matchedIds = <String>{};

  // 1. KESİN ÇÖZÜM: Karşılıklı Beğenileri (Eşleşmeleri) Bul
  try {
    final allLikes = await Supabase.instance.client
        .from('likes')
        .select('liker_id, liked_id')
        .or('liker_id.eq.$myProfileId,liked_id.eq.$myProfileId');

    final iLiked = <String>{};
    final likedMe = <String>{};

    for (var row in allLikes as List) {
      final liker = row['liker_id'].toString();
      final liked = row['liked_id'].toString();
      
      if (liker == myProfileId) iLiked.add(liked);
      if (liked == myProfileId) likedMe.add(liker);
    }
    
    matchedIds.addAll(iLiked.intersection(likedMe));
  } catch (_) {}

  // 2. KESİN ÇÖZÜM: Mesajlaşılan Kişileri (Sohbette olanları) Eşleşme Kabul Et
  try {
    final messages = await Supabase.instance.client
        .from('messages')
        .select('sender_id, receiver_id')
        .or('sender_id.eq.$myProfileId,receiver_id.eq.$myProfileId');

    for (var msg in messages as List) {
      final sender = msg['sender_id'].toString();
      final receiver = msg['receiver_id'].toString();
      
      if (sender != myProfileId) matchedIds.add(sender);
      if (receiver != myProfileId) matchedIds.add(receiver);
    }
  } catch (_) {}

  if (matchedIds.isEmpty) return [];

  // 4. Eşleşilen profilleri getir
  final matchedProfiles = await Supabase.instance.client.from('profiles').select('*').inFilter('id', matchedIds.toList());
  return List<Map<String, dynamic>>.from(matchedProfiles);
});

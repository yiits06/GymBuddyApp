import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/auth_provider.dart';

class ChatRepository {
  final SupabaseClient supabase;

  ChatRepository(this.supabase);

  Future<String?> getCurrentProfileId() async {
    final authId = supabase.auth.currentUser?.id;
    if (authId == null) return null;

    final profile = await supabase
        .from('profiles')
        .select('id')
        .or('id.eq.$authId,auth_id.eq.$authId')
        .limit(1);

    return profile.isNotEmpty ? profile.first['id']?.toString() : null;
  }

  Future<void> sendMessage({
    required String receiverId,
    required String content,
  }) async {
    final currentProfileId = await getCurrentProfileId();
    if (currentProfileId == null) return;

    await supabase.from('messages').insert({
      'sender_id': currentProfileId,
      'receiver_id': receiverId,
      'content': content,
      'is_read': false,
    });
  }

  Future<void> markMessagesAsRead(String senderId) async {
    final currentProfileId = await getCurrentProfileId();
    if (currentProfileId == null) return;

    try {
      final result = await supabase
          .from('messages')
          .update({'is_read': true})
          .eq('sender_id', senderId)
          .eq('receiver_id', currentProfileId)
          .eq('is_read', false)
          .select(); // Güncellenen satırları döndürür
          
      if (result.isEmpty) {
        throw Exception('RLS Kuralları güncellemeyi engelledi veya mesaj bulunamadı!');
      }
    } catch (e) {
      throw Exception('Supabase Update Hatası: $e');
    }
  }
}

final chatRepositoryProvider = Provider.autoDispose(
  (ref) => ChatRepository(Supabase.instance.client),
);

final currentProfileIdProvider = FutureProvider.autoDispose<String?>((ref) {
  // Auth (Giriş/Çıkış) durumu değiştiğinde otomatik tetiklenip veriyi yenileyecek
  ref.watch(authProvider);
  return ref.read(chatRepositoryProvider).getCurrentProfileId();
});

final allMessagesStreamProvider = StreamProvider.autoDispose<List<Map<String, dynamic>>>(
  (ref) async* {
    final supabase = Supabase.instance.client;
    final currentProfileId = await ref.watch(currentProfileIdProvider.future);
    if (currentProfileId == null) {
      yield [];
      return;
    }

    yield* supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .map(
          (messages) {
            final list = messages
                .where(
                  (message) {
                    final sId = message['sender_id'].toString();
                    final rId = message['receiver_id'].toString();
                    if (sId == rId) return false; // Bozuk veriyi yoksay
                    return sId == currentProfileId || rId == currentProfileId;
                  }
                )
                .toList();
            // En yeni mesajların daima ilk sırada olmasını Dart tarafında kesinleştiriyoruz
            list.sort((a, b) {
              final aTime = DateTime.parse(a['created_at'].toString());
              final bTime = DateTime.parse(b['created_at'].toString());
              return bTime.compareTo(aTime);
            });
            return list;
          },
        );
  },
);

final chatStreamProvider =
    StreamProvider.autoDispose.family<List<Map<String, dynamic>>, String>((
      ref,
      receiverId,
    ) async* {
      final supabase = Supabase.instance.client;
      final currentProfileId = await ref.watch(currentProfileIdProvider.future);
      if (currentProfileId == null) {
        yield [];
        return;
      }

      yield* supabase
          .from('messages')
          .stream(primaryKey: ['id'])
          .map(
            (messages) {
              final list = messages.where((message) {
                final senderId = message['sender_id'].toString();
                final messageReceiverId = message['receiver_id'].toString();

                if (senderId == messageReceiverId) return false; // Bozuk veriyi yoksay

                return (senderId == currentProfileId &&
                        messageReceiverId == receiverId) ||
                    (senderId == receiverId &&
                        messageReceiverId == currentProfileId);
              }).toList();
              // Sohbet içi mesajların eskiden yeniye olmasını garanti altına alıyoruz
              list.sort((a, b) {
                final aTime = DateTime.parse(a['created_at'].toString());
                final bTime = DateTime.parse(b['created_at'].toString());
                return aTime.compareTo(bTime);
              });
              return list;
            },
          );
    });

// Toplam okunmamış mesaj sayısını getiren stream provider
final unreadMessagesCountProvider = StreamProvider.autoDispose<int>((ref) async* {
  final supabase = Supabase.instance.client;
  final currentProfileId = await ref.watch(currentProfileIdProvider.future);
  
  if (currentProfileId == null) {
    yield 0;
    return;
  }

  yield* supabase
      .from('messages')
      .stream(primaryKey: ['id'])
      .map((messages) => messages
          .where((msg) => 
              msg['receiver_id'].toString() == currentProfileId && 
              msg['is_read'] == false)
          .length);
});

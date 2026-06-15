import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme/app_theme.dart';
import '../providers/chat_provider.dart';

class ChatDetailScreen extends ConsumerStatefulWidget {
  final String userId;
  final String userName;
  final String userImage;

  const ChatDetailScreen({
    super.key,
    required this.userId,
    required this.userName,
    required this.userImage,
  });

  @override
  ConsumerState<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends ConsumerState<ChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _messageController.clear();

    try {
      await ref
          .read(chatRepositoryProvider)
          .sendMessage(receiverId: widget.userId, content: text);
      _scrollToBottom();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Mesaj gönderilemedi: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Burada chatStreamProvider'ı kullanıyoruz (Artık tanımlı)
    final chatAsync = ref.watch(chatStreamProvider(widget.userId));
    final currentProfileIdAsync = ref.watch(currentProfileIdProvider);
    final currentProfileId = currentProfileIdAsync.value;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(widget.userImage),
              radius: 18,
            ),
            const SizedBox(width: 12),
            Text(widget.userName, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: chatAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppTheme.neonLime),
              ),
              error: (err, _) => Center(
                child: Text(
                  'Hata: $err',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
              data: (messages) {
                final unreadMessages = messages.where((msg) => 
                    msg['sender_id'].toString() == widget.userId && 
                    msg['is_read'] != true).toList();
                    
                if (unreadMessages.isNotEmpty) {
                  Future.microtask(() async {
                    try {
                      await ref.read(chatRepositoryProvider).markMessagesAsRead(widget.userId);
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('HATA: Mesaj "okundu" yapılamadı. Lütfen Supabase SQL RLS ayarlarınızı kontrol edin!'),
                          backgroundColor: Colors.red,
                        ));
                      }
                    }
                  });
                }

                WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

                return ListView.builder(
                  controller: _scrollController,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isMe = msg['sender_id'].toString() == currentProfileId;
                    return Align(
                      alignment: isMe
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isMe
                              ? AppTheme.neonLime
                              : const Color(0xFF1E1E1E),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          msg['content'],
                          style: TextStyle(
                            color: isMe ? Colors.black : Colors.white,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: 'Mesaj yaz...',
                      hintStyle: TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: Color(0xFF1E1E1E),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _sendMessage,
                  icon: const Icon(Icons.send, color: AppTheme.neonLime),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

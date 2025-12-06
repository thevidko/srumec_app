import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:srumec_app/auth/providers/auth_provider.dart';
import 'package:srumec_app/chat/models/chat_message.dart';
import 'package:srumec_app/chat/providers/chat_provider.dart';
import 'package:srumec_app/users/widgets/user_name_label.dart';

class ChatDetailScreen extends StatefulWidget {
  final String roomId;
  final String otherUserId;

  const ChatDetailScreen({
    super.key,
    required this.roomId,
    required this.otherUserId,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Vstoupíme do roomky (načte historii a nastaví activeRoomId)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatProvider>().enterRoom(widget.roomId);
    });
  }

  @override
  void dispose() {
    // Opustíme roomku (vyčistí zprávy v paměti)
    // Poznámka: context.read v dispose může být risky, ale s listen:false ok
    // Bezpečnější je to udělat v deactivate nebo použít uloženou referenci,
    // ale pro jednoduchost:
    super.dispose();
  }

  // Řešení pro bezpečné opuštění roomky
  @override
  void deactivate() {
    context.read<ChatProvider>().leaveRoom();
    super.deactivate();
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

  Future<void> _sendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    final myUserId = context.read<AuthProvider>().userId;
    if (myUserId == null) return;

    _textController.clear();

    // Odeslání přes Provider
    await context.read<ChatProvider>().sendMessage(text, myUserId);

    // Scroll dolů po odeslání
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    // Sledujeme změny v chatu (příchozí zprávy)
    final chatProvider = context.watch<ChatProvider>();
    final myUserId = context.read<AuthProvider>().userId;

    return Scaffold(
      appBar: AppBar(title: UserNameLabel(userId: widget.otherUserId)),
      body: Column(
        children: [
          // 1. SEZNAM ZPRÁV
          Expanded(
            child: chatProvider.isLoadingMessages
                ? const Center(child: CircularProgressIndicator())
                : chatProvider.messages.isEmpty
                ? const Center(child: Text("Žádné zprávy. Napište první!"))
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: chatProvider.messages.length,
                    itemBuilder: (context, index) {
                      final msg = chatProvider.messages[index];
                      final isMe = msg.authorId == myUserId;
                      return _buildMessageBubble(msg, isMe);
                    },
                  ),
          ),

          // 2. VSTUPNÍ POLE
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: InputDecoration(
                      hintText: "Napsat zprávu...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _sendMessage,
                  icon: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage msg, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isMe ? Colors.blue : Colors.grey[300],
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isMe ? const Radius.circular(16) : Radius.zero,
            bottomRight: isMe ? Radius.zero : const Radius.circular(16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              msg.content,
              style: TextStyle(
                color: isMe ? Colors.white : Colors.black,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "${msg.createdAt.hour}:${msg.createdAt.minute.toString().padLeft(2, '0')}",
              style: TextStyle(
                color: isMe ? Colors.white70 : Colors.black54,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

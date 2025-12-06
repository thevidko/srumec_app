import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:srumec_app/auth/providers/auth_provider.dart';
import 'package:srumec_app/chat/providers/chat_provider.dart';
import 'package:srumec_app/chat/screens/chat_detail_screen.dart';
import 'package:srumec_app/users/widgets/user_name_label.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  @override
  void initState() {
    super.initState();
    // Načteme seznam chatů při otevření obrazovky
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatProvider>().loadRooms();
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = context.watch<ChatProvider>();
    final myUserId = context.read<AuthProvider>().userId;

    return Scaffold(
      body: chatProvider.isLoadingRooms
          ? const Center(child: CircularProgressIndicator())
          : chatProvider.rooms.isEmpty
          ? const Center(child: Text("Zatím nemáte žádné zprávy"))
          : ListView.separated(
              itemCount: chatProvider.rooms.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final room = chatProvider.rooms[index];

                // Zjistíme ID toho druhého (pro zobrazení jména)
                final otherUserId = room.getOtherUserId(myUserId ?? '');

                return ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: UserNameLabel(
                    userId: otherUserId,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatDetailScreen(
                          roomId: room.id,
                          otherUserId: otherUserId,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}

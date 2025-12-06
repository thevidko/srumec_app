import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:srumec_app/chat/models/chat_message.dart';

class ChatSocketService {
  // Stream controller, do kterého budeme posílat příchozí zprávy
  final _messageController = StreamController<ChatMessage>.broadcast();

  // Public stream, který bude poslouchat Provider
  Stream<ChatMessage> get messageStream => _messageController.stream;

  void connect(String token) {
    debugPrint("🔌 Připojuji k WebSocket serveru...");
    // ZDE BUDE KÓD PRO PŘIPOJENÍ (např. package socket_io_client)
    // socket.on('new_message', (data) {
    //    final msg = ChatMessage.fromJson(data);
    //    _messageController.add(msg);
    // });
  }

  void joinRoom(String roomId) {
    debugPrint("🔌 Vstupuji do roomky: $roomId");
    // socket.emit('join_room', roomId);
  }

  void leaveRoom(String roomId) {
    debugPrint("🔌 Opouštím roomku: $roomId");
    // socket.emit('leave_room', roomId);
  }

  void disconnect() {
    debugPrint("🔌 Odpojuji WebSocket...");
    // socket.disconnect();
  }

  // Pro testovací účely (simulace příchozí zprávy)
  void simulateIncomingMessage(ChatMessage msg) {
    _messageController.add(msg);
  }
}

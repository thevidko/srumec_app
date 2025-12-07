import 'dart:async';
import 'package:flutter/material.dart';
import 'package:srumec_app/chat/data/repositories/chat_repository.dart';
import 'package:srumec_app/chat/models/chat_message.dart';
import 'package:srumec_app/chat/models/chat_room.dart';
import 'package:srumec_app/core/models/socket_events.dart';
import 'package:srumec_app/core/services/web_socket_service.dart';

class ChatProvider extends ChangeNotifier {
  final ChatRepository repository;
  final WebSocketService socketService;

  ChatProvider(this.repository, this.socketService) {
    _socketSubscription = socketService.eventStream.listen(_onSocketEvent);
  }

  // STAV
  List<ChatRoom> _rooms = [];
  List<ChatMessage> _currentRoomMessages = [];
  bool _isLoadingRooms = false;
  bool _isLoadingMessages = false;
  String? _activeRoomId;

  StreamSubscription? _socketSubscription;

  List<ChatRoom> get rooms => _rooms;
  List<ChatMessage> get messages => _currentRoomMessages;
  bool get isLoadingRooms => _isLoadingRooms;
  bool get isLoadingMessages => _isLoadingMessages;

  Future<void> loadRooms() async {
    _isLoadingRooms = true;
    notifyListeners();
    try {
      _rooms = await repository.fetchMyRooms();
    } catch (e) {
      debugPrint("Chyba loadRooms: $e");
    } finally {
      _isLoadingRooms = false;
      notifyListeners();
    }
  }

  // 2. Vstup do místnosti (Load history)
  Future<void> enterRoom(String roomId) async {
    _activeRoomId = roomId;
    _currentRoomMessages = [];
    _isLoadingMessages = true;
    notifyListeners();

    try {
      final history = await repository.fetchHistory(roomId);
      _currentRoomMessages = history;

      //od nejstarších po nejnovější
      _currentRoomMessages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    } catch (e) {
      debugPrint("Chyba enterRoom: $e");
    } finally {
      _isLoadingMessages = false;
      notifyListeners();
    }
  }

  // 3. Opuštění místnosti
  void leaveRoom() {
    _activeRoomId = null;
    _currentRoomMessages = [];
    notifyListeners();
  }

  // 4. Odeslání zprávy
  Future<void> sendMessage(String content, String authorId) async {
    if (_activeRoomId == null) return;

    try {
      final newMessage = await repository.sendMessage(
        _activeRoomId!,
        content,
        authorId,
      );

      if (!_currentRoomMessages.any((m) => m.id == newMessage.id)) {
        _currentRoomMessages.add(newMessage);
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Chyba sendMessage: $e");
      rethrow;
    }
  }

  //Handler pro příchozí WebSocket události
  void _onSocketEvent(SocketEvent event) {
    // Reagujeme pouze na vytvoření zprávy
    if (event.event == 'chat.message.created') {
      _handleNewMessageNotification(event.data);
    }
  }

  Future<void> _handleNewMessageNotification(Map<String, dynamic> data) async {
    final roomId = data['room_ref'];
    if (_activeRoomId == roomId) {
      debugPrint(
        "🔔 Nová zpráva v aktuálním chatu ($roomId). Obnovuji data...",
      );

      try {
        final updatedMessages = await repository.fetchHistory(roomId);

        // Seřadit
        updatedMessages.sort((a, b) => a.createdAt.compareTo(b.createdAt));

        _currentRoomMessages = updatedMessages;
        notifyListeners();
      } catch (e) {
        debugPrint("Chyba při aktualizaci chatu přes socket: $e");
      }
    } else {
      debugPrint("📩 Zpráva na pozadí do roomky: $roomId");
    }
  }

  @override
  void dispose() {
    _socketSubscription?.cancel();
    super.dispose();
  }
}

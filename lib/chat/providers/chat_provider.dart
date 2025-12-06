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
    // Posloucháme globální stream událostí z WebSocketService
    _socketSubscription = socketService.eventStream.listen(_onSocketEvent);
  }

  // STAV
  List<ChatRoom> _rooms = [];
  List<ChatMessage> _currentRoomMessages = [];
  bool _isLoadingRooms = false;
  bool _isLoadingMessages = false;
  String? _activeRoomId; // ID právě otevřené místnosti

  StreamSubscription? _socketSubscription;

  // GETTERS
  List<ChatRoom> get rooms => _rooms;
  List<ChatMessage> get messages => _currentRoomMessages;
  bool get isLoadingRooms => _isLoadingRooms;
  bool get isLoadingMessages => _isLoadingMessages;

  // 1. Načtení seznamu místností
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
    _currentRoomMessages = []; // Vyčistit staré zprávy
    _isLoadingMessages = true;
    notifyListeners();

    // Poznámka: joinRoom/leaveRoom na socketu nevoláme,
    // protože API podle dokumentace funguje globálně přes token.

    try {
      // Stáhneme historii přes REST
      final history = await repository.fetchHistory(roomId);
      _currentRoomMessages = history;

      // Seřadíme od nejstarších po nejnovější (aby byly dole)
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
      // Pošleme přes REST
      final newMessage = await repository.sendMessage(
        _activeRoomId!,
        content,
        authorId,
      );

      // Optimisticky přidáme do seznamu (pokud by server neposlal WS notifikaci hned)
      // Kontrolujeme duplicitu pro jistotu
      if (!_currentRoomMessages.any((m) => m.id == newMessage.id)) {
        _currentRoomMessages.add(newMessage);
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Chyba sendMessage: $e");
      rethrow; // Pošleme chybu do UI, aby se zobrazila uživateli
    }
  }

  // 5. Handler pro příchozí WebSocket události
  void _onSocketEvent(SocketEvent event) {
    // Reagujeme pouze na vytvoření zprávy
    if (event.event == 'chat.message.created') {
      _handleNewMessageNotification(event.data);
    }
  }

  Future<void> _handleNewMessageNotification(Map<String, dynamic> data) async {
    final roomId = data['room_ref'];
    // final msgType = data['msg_type']; // Můžeme využít pro logiku

    // Pokud uživatel zrovna kouká do této roomky
    if (_activeRoomId == roomId) {
      debugPrint(
        "🔔 Nová zpráva v aktuálním chatu ($roomId). Obnovuji data...",
      );

      try {
        // Protože WS posílá jen ID zprávy, musíme si dotáhnout data.
        // Nejjednodušší cesta pro konzistenci je obnovit historii.
        // (Ideálně v budoucnu endpoint getOneMessage(id))
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
      // Zde je místo pro logiku "Nepřečtené zprávy" (červený puntík v seznamu)
      // Např: loadRooms(); // Pro obnovení seznamu s indikátory
    }
  }

  @override
  void dispose() {
    _socketSubscription?.cancel();
    super.dispose();
  }
}

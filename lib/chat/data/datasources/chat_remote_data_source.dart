import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:srumec_app/chat/models/chat_message.dart';
import 'package:srumec_app/chat/models/chat_room.dart';
import 'package:srumec_app/core/network/api_endpoints.dart';

class ChatRemoteDataSource {
  final Dio dio;

  ChatRemoteDataSource(this.dio);

  // 1. Získat všechny moje místnosti
  Future<List<ChatRoom>> getMyRooms() async {
    final url = '${ApiEndpoints.baseUrl}${ChatEndpoints.getAllMyDirectRooms}';

    try {
      // Předpokládám POST (protože get-my-events byl POST)
      final response = await dio.post(url, data: {});
      final List<dynamic> data = response.data;
      return data.map((json) => ChatRoom.fromJson(json)).toList();
    } catch (e) {
      debugPrint("Chyba při načítání chatů: $e");
      rethrow;
    }
  }

  // 2. Vytvořit novou místnost (nebo získat existující)
  Future<ChatRoom> createRoom(String targetUserId) async {
    final url = '${ApiEndpoints.baseUrl}${ChatEndpoints.createDirectRoom}';

    try {
      final response = await dio.post(
        url,
        data: {
          'target_user_ref': targetUserId, // Klíč záleží na BE
        },
      );
      return ChatRoom.fromJson(response.data);
    } catch (e) {
      debugPrint("Chyba při vytváření chatu: $e");
      rethrow;
    }
  }

  // 3. Načíst zprávy pro konkrétní místnost
  Future<List<ChatMessage>> getMessages(String roomId) async {
    final url = '${ApiEndpoints.baseUrl}${ChatEndpoints.getAllMessages}';

    try {
      final response = await dio.post(url, data: {'room_ref': roomId});
      final List<dynamic> data = response.data;
      return data.map((json) => ChatMessage.fromJson(json)).toList();
    } catch (e) {
      debugPrint("Chyba při stahování zpráv: $e");
      rethrow;
    }
  }

  // 4. Odeslat zprávu (REST fallback, pokud nepošleme přes Socket)
  Future<ChatMessage> sendMessage(
    String roomId,
    String content,
    String authorId,
  ) async {
    final url = '${ApiEndpoints.baseUrl}${ChatEndpoints.createMessage}';

    try {
      final response = await dio.post(
        url,
        data: {'room_ref': roomId, 'user_ref': authorId, 'message': content},
      );
      return ChatMessage.fromJson(response.data);
    } catch (e) {
      debugPrint("Chyba při odesílání zprávy: $e");
      rethrow;
    }
  }
}

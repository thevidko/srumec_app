import 'package:srumec_app/chat/data/datasources/chat_remote_data_source.dart';
import 'package:srumec_app/chat/models/chat_message.dart';
import 'package:srumec_app/chat/models/chat_room.dart';

class ChatRepository {
  final ChatRemoteDataSource remoteDataSource;

  ChatRepository(this.remoteDataSource);

  Future<List<ChatRoom>> fetchMyRooms() async {
    return await remoteDataSource.getMyRooms();
  }

  Future<ChatRoom> initiateChat(String targetUserId) async {
    return await remoteDataSource.createRoom(targetUserId);
  }

  Future<List<ChatMessage>> fetchHistory(String roomId) async {
    return await remoteDataSource.getMessages(roomId);
  }

  Future<ChatMessage> sendMessage(
    String roomId,
    String content,
    String authorId,
  ) async {
    return await remoteDataSource.sendMessage(roomId, content, authorId);
  }
}

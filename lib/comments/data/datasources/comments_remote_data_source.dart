import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:srumec_app/core/network/api_endpoints.dart';
import 'package:srumec_app/comments/models/comment.dart';

class CommentsRemoteDataSource {
  final Dio dio;

  CommentsRemoteDataSource(this.dio);

  Future<List<Comment>> getComments(String eventId) async {
    final url = '${ApiEndpoints.baseUrl}${CommentsEndpoints.getByEvent}';
    try {
      debugPrint("📤 Odesílám ID: $eventId");
      final response = await dio.post(url, data: {"event_ref": eventId});
      final List<dynamic> data = response.data;
      return data.map((json) => Comment.fromJson(json)).toList();
    } catch (e) {
      debugPrint("Chyba při stahování komentářů: $e");
      rethrow;
    }
  }

  Future<void> createComment(
    String eventId,
    String userId,
    String content,
  ) async {
    final url = '${ApiEndpoints.baseUrl}${CommentsEndpoints.create}';

    try {
      await dio.post(
        url,
        data: {
          'event_ref': eventId,
          'user_ref': userId,
          'content': content,
          // ID uživatele si server vytáhne z Tokenu ???
        },
      );
    } catch (e) {
      debugPrint("Chyba při odesílání komentáře: $e");
      rethrow;
    }
  }
}

import 'package:srumec_app/comments/data/datasources/comments_remote_data_source.dart';
import 'package:srumec_app/comments/models/comment.dart';

class CommentsRepository {
  final CommentsRemoteDataSource remoteDataSource;

  CommentsRepository(this.remoteDataSource);

  Future<List<Comment>> fetchComments(String eventId) async {
    return await remoteDataSource.getComments(eventId);
  }

  Future<void> addComment(String eventId, String userId, String content) async {
    return await remoteDataSource.createComment(eventId, userId, content);
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:srumec_app/comments/data/repositories/comments_repository.dart';
import 'package:srumec_app/comments/models/comment.dart';

class CommentsProvider extends ChangeNotifier {
  final CommentsRepository repository;
  final _storage = const FlutterSecureStorage();
  CommentsProvider(this.repository);

  List<Comment> _comments = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Comment> get comments => _comments;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Načtení komentářů
  Future<void> loadComments(String eventId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _comments = await repository.fetchComments(eventId);
      // Seřadíme od nejnovějších
      _comments.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      _errorMessage = "Nepodařilo se načíst komentáře";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Přidání komentáře
  Future<bool> sendComment(String eventId, String content) async {
    try {
      // 1. NAČTENÍ ID UŽIVATELE Z LOCAL STORAGE
      final userId = await _storage.read(key: 'user_uuid');

      if (userId == null) {
        debugPrint("Chyba: UserId nenalezeno v úložišti.");
        return false;
      }

      // 2. VOLÁNÍ REPO S ID
      await repository.addComment(eventId, userId, content);

      // 3. RELOAD
      await loadComments(eventId);
      return true;
    } catch (e) {
      debugPrint("Provider error: $e");
      return false;
    }
  }
}

import 'package:flutter/foundation.dart';
import 'package:srumec_app/users/data/repositories/users_repository.dart';
import 'package:srumec_app/users/models/user_profile.dart';

class UsersProvider extends ChangeNotifier {
  final UsersRepository repository;

  UsersProvider(this.repository);
  final Map<String, UserProfile> _usersCache = {};
  final Set<String> _pendingRequests = {};

  UserProfile? getUser(String userId) {
    if (_usersCache.containsKey(userId)) {
      return _usersCache[userId];
    }

    if (!_pendingRequests.contains(userId)) {
      _fetchUser(userId);
    }

    return null;
  }

  Future<void> _fetchUser(String userId) async {
    _pendingRequests.add(userId);

    try {
      final userProfile = await repository.getUser(userId);
      _usersCache[userId] = userProfile;
    } catch (e) {
      debugPrint("Nepodařilo se načíst uživatele $userId");
    } finally {
      _pendingRequests.remove(userId);
      notifyListeners();
    }
  }
}

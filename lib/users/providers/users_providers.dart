import 'package:flutter/foundation.dart';
import 'package:srumec_app/users/data/repositories/users_repository.dart';
import 'package:srumec_app/users/models/user_profile.dart';

class UsersProvider extends ChangeNotifier {
  final UsersRepository repository;

  UsersProvider(this.repository);

  // CACHE: Mapování ID -> Profil
  final Map<String, UserProfile> _usersCache = {};

  // OCHRANA: Abychom nestahovali stejné ID 5x najednou
  final Set<String> _pendingRequests = {};

  // Hlavní metoda pro UI
  UserProfile? getUser(String userId) {
    // 1. Pokud uživatele máme v cache, vrátíme ho
    if (_usersCache.containsKey(userId)) {
      return _usersCache[userId];
    }

    // 2. Pokud ho nemáme a zrovna ho nestahujeme, spustíme stahování
    if (!_pendingRequests.contains(userId)) {
      _fetchUser(userId);
    }

    // 3. Zatím vrátíme null (UI zobrazí loader nebo ID)
    return null;
  }

  Future<void> _fetchUser(String userId) async {
    _pendingRequests.add(userId);
    // notifyListeners(); // Volitelné, pokud chceme překreslit UI do "loading" stavu

    try {
      final userProfile = await repository.getUser(userId);
      _usersCache[userId] = userProfile;
    } catch (e) {
      debugPrint("Nepodařilo se načíst uživatele $userId");
    } finally {
      _pendingRequests.remove(userId);
      notifyListeners(); // DŮLEŽITÉ: Řekneme UI, že data dorazila
    }
  }
}

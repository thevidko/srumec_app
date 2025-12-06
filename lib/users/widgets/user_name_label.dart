import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:srumec_app/users/providers/users_providers.dart';

class UserNameLabel extends StatelessWidget {
  final String userId;
  final TextStyle? style;

  const UserNameLabel({super.key, required this.userId, this.style});

  @override
  Widget build(BuildContext context) {
    // Sledujeme UsersProvider
    final usersProvider = context.watch<UsersProvider>();

    // Zkusíme získat profil z cache (pokud tam není, Provider ho začne stahovat)
    final user = usersProvider.getUser(userId);

    if (user != null) {
      // Máme jméno!
      return Text(user.name, style: style);
    } else {
      // Ještě nemáme jméno -> Zobrazíme ID nebo "..."
      return Text(
        "Načítám...", // nebo userId.substring(0, 5)
        style:
            style?.copyWith(color: Colors.grey) ??
            const TextStyle(color: Colors.grey),
      );
    }
  }
}

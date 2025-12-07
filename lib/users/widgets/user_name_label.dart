import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:srumec_app/users/providers/users_providers.dart';

class UserNameLabel extends StatelessWidget {
  final String userId;
  final TextStyle? style;

  const UserNameLabel({super.key, required this.userId, this.style});

  @override
  Widget build(BuildContext context) {
    final usersProvider = context.watch<UsersProvider>();

    final user = usersProvider.getUser(userId);

    if (user != null) {
      return Text(user.name, style: style);
    } else {
      return Text(
        "Načítám...",
        style:
            style?.copyWith(color: Colors.grey) ??
            const TextStyle(color: Colors.grey),
      );
    }
  }
}

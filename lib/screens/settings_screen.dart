import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nastavení')),
      body: ListView(
        children: [
          const SizedBox(height: 8),
          SwitchListTile(
            title: const Text('Tmavý režim'),
            subtitle: const Text('Přepnout světlý / tmavý vzhled (ukázka)'),
            value: false,
            onChanged: (v) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Tmavý režim – zatím ukázka')),
              );
            },
          ),
          const Divider(height: 0),
          ListTile(
            leading: const Icon(Icons.notifications_outlined),
            title: const Text('Notifikace'),
            subtitle: const Text('Správa upozornění (ukázka)'),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notifikace – zatím ukázka')),
              );
            },
          ),
          const Divider(height: 0),
          ListTile(
            leading: const Icon(Icons.lock_outline),
            title: const Text('Soukromí a zabezpečení'),
            subtitle: const Text('Přístupová práva (ukázka)'),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Soukromí – zatím ukázka')),
              );
            },
          ),
          const Divider(height: 0),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('O aplikaci'),
            subtitle: const Text('Licenční informace (ukázka)'),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

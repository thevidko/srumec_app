import 'package:flutter/material.dart';
import 'package:srumec_app/screens/settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: true,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Hlavička profilu
          Row(
            children: [
              const CircleAvatar(
                radius: 36,
                child: Icon(Icons.person, size: 36),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Uživatelské jméno',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    SizedBox(height: 4),
                    Text('user@example.com', style: TextStyle(color: Colors.black54)),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Upravit profil (ukázka)',
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Editace profilu – zatím ukázka')),
                  );
                },
                icon: const Icon(Icons.edit_outlined),
              ),
            ],
          ),

          const SizedBox(height: 24),
          const Divider(),

          // Sekce akcí
          const SizedBox(height: 8),
          const Text('Moje sekce', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.event_available_outlined),
            title: const Text('Moje akce'),
            subtitle: const Text('Přehled vámi vytvořených akcí'),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Moje akce – zatím ukázka')),
              );
            },
          ),

          // Odkaz na Nastavení
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('Nastavení'),
            subtitle: const Text('Upravit aplikaci a účet'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),

          const SizedBox(height: 8),
          const Divider(),

          // Další placeholdery
          const SizedBox(height: 8),
          const Text('O aplikaci', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Verze aplikace'),
            subtitle: const Text('1.0.0 (ukázka)'),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────
// WALKER SIDE DRAWER
// Displays user info and provides deep-link access to all 
// major features of the walker application. Easy to maintain.
// ─────────────────────────────────────────────────────────

class WalkerDrawer extends StatelessWidget {
  final String name;
  const WalkerDrawer({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: Text(name),
            accountEmail: const Text('Walker'),
            currentAccountPicture: Image.network('https://static.vecteezy.com/system/resources/thumbnails/035/857/779/small/people-face-avatar-icon-cartoon-character-png.png'),
            decoration: const BoxDecoration(color: Colors.blue),
          ),
          _buildMenuItem(context, Icons.house, 'Dashboard', '/walker-home'),
          _buildMenuItem(context, Icons.date_range, 'Booking Requests', '/walker-requests'),
          _buildMenuItem(context, Icons.contacts, 'My Schedule', '/walker-schedule'),
          _buildMenuItem(context, Icons.attach_money, 'Earnings', '/walker-earnings'),
          _buildMenuItem(context, Icons.person, 'Edit Profile', '/walker-profile'),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () {
              // Add logout logic here
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, IconData icon, String title, String? route) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        Navigator.pop(context); // Close drawer
        if (route != null) {
          Navigator.pushNamed(context, route);
        }
      },
    );
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pawwalk/screens/walker/earnings_screen.dart';
import 'package:pawwalk/screens/walker/notification_screen.dart';
import 'package:pawwalk/screens/walker/request_screen.dart';
import 'package:pawwalk/screens/walker/schedule_screen.dart';
import 'package:pawwalk/screens/walker/walker_home_screen.dart';
import 'package:pawwalk/screens/walker/walker_profile_edit_screen.dart';
import '../chat/chat_list_screen.dart';

import '../auth/login_screen.dart';

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
          _buildMenuItem(context, Icons.house, 'Dashboard', WalkerHomeScreen()),
          _buildMenuItem(context, Icons.date_range, 'Booking Requests', RequestScreen()),
          _buildMenuItem(context, Icons.contacts, 'My Schedule', ScheduleScreen()),
          _buildMenuItem(context, Icons.attach_money, 'Earnings', EarningsScreen()),
          _buildMenuItem(context, Icons.person, 'Edit Profile', ProfileEditScreen()),
          _buildMenuItem(context, Icons.notifications_none, 'View Notifications', NotificationScreen()),
          _buildMenuItem(context, Icons.chat_bubble_outline, 'View Chat', ChatListScreen()),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () async {
              // 1. Log out
              await FirebaseAuth.instance.signOut();

              // 2. CHECK THE ASYNC GAP: Make sure the screen is still active
              if (!context.mounted) return;

              // 3. Now it is safe to navigate
              Navigator.pop(context); // Close drawer
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) => const LoginScreen(),
                  transitionDuration: Duration.zero,
                  reverseTransitionDuration: Duration.zero,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, IconData icon, String title, Widget nextScreen) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) => nextScreen,
            transitionDuration: Duration.zero, // Instant transition for smooth nav feel
            reverseTransitionDuration: Duration.zero,
          ),
        );
      },
    );
  }
}

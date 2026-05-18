import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../auth/login_screen.dart';
import 'admin_home_tab_screen.dart';
import 'admin_users_tab_screen.dart';
import 'admin_bookings_tab_screen.dart';
import 'admin_disputes_tabs_screen.dart';
import 'admin_more_tab_screen.dart';
import '../../l10n/generated/app_localizations.dart';

// ─────────────────────────────────────────────────────────
// ADMIN DASHBOARD SCREEN
// holds bottom nav and switches between tabs
// ─────────────────────────────────────────────────────────

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _currentIndex = 0;

  void _goTo(Widget screen) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    _goTo(const LoginScreen());
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: _buildCurrentTab(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF2563EB), // Admin consistent blue
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white54,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        items: [
          BottomNavigationBarItem(icon: const Icon(Icons.house_outlined), activeIcon: const Icon(Icons.house), label: loc.dashboard),
          BottomNavigationBarItem(icon: const Icon(Icons.people_outlined), activeIcon: const Icon(Icons.people), label: loc.users),
          BottomNavigationBarItem(icon: const Icon(Icons.book_outlined), activeIcon: const Icon(Icons.book), label: loc.bookings),
          BottomNavigationBarItem(icon: const Icon(Icons.report_outlined), activeIcon: const Icon(Icons.report), label: loc.disputes),
          BottomNavigationBarItem(icon: const Icon(Icons.menu), activeIcon: const Icon(Icons.menu_open), label: loc.more),
        ],
      ),
    );
  }

  Widget _buildCurrentTab() {
    switch (_currentIndex) {
      case 0: return AdminHomeTab();
      case 1: return const AdminUsersTab();
      case 2: return const AdminBookingsTab();
      case 3: return AdminDisputesTab();
      case 4: return AdminMoreTab(onLogout: _logout);
      default: return AdminHomeTab();
    }
  }
}

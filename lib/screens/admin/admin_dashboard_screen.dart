import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../auth/login_screen.dart';
import 'admin_home_tab_screen.dart';
import 'admin_users_tab_screen.dart';
import 'admin_bookings_tab_screen.dart';
import 'admin_disputes_tabs_screen.dart';
import 'admin_more_tab_screen.dart';

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

  //Current selected bottom nav tab
  int _currentIndex = 0;

  //Navigate with slide animation
  void _goTo(Widget screen) {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: Duration(milliseconds: 300),
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
            child: child,
          );
        },
      ),
    );
  }

  // ── Logout ─────────────────────────────────────────────
  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    _goTo(LoginScreen());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFF7ED),

      //Switch between tabs based on selected index
      body: _buildCurrentTab(),

      //Bottom navigation bar
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Color(0xFF7C2D12),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white54,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.house_outlined),        activeIcon: Icon(Icons.house),        label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.people_outlined),       activeIcon: Icon(Icons.people),       label: 'Users'),
          BottomNavigationBarItem(icon: Icon(Icons.book_outlined),         activeIcon: Icon(Icons.book),         label: 'Bookings'),
          BottomNavigationBarItem(icon: Icon(Icons.report_outlined),       activeIcon: Icon(Icons.report),       label: 'Disputes'),
          BottomNavigationBarItem(icon: Icon(Icons.menu),                  activeIcon: Icon(Icons.menu_open),    label: 'More'),
        ],
      ),
    );
  }

  // ── Return the right tab widget ────────────────────────
  Widget _buildCurrentTab() {
    switch (_currentIndex) {
      case 0: return AdminHomeTab();
      case 1: return AdminUsersTab();
      case 2: return AdminBookingsTab();
      case 3: return AdminDisputesTab();
      case 4: return AdminMoreTab(onLogout: _logout);
      default: return AdminHomeTab();
    }
  }
}
import 'package:flutter/material.dart';
import 'package:pawwalk/screens/walker/walker_profile_edit_screen.dart';

import '../walker/earnings_screen.dart';
import '../walker/request_screen.dart';
import '../walker/schedule_screen.dart';
import '../walker/walker_home_screen.dart';

// ─────────────────────────────────────────────────────────
// WALKER BOTTOM NAVIGATION BAR
// Provides quick access to main screens: Home, Request, 
// Schedule, Earnings, and Profile. Easy to maintain for developing.
// ─────────────────────────────────────────────────────────

class WalkerBottomNavBar extends StatelessWidget {
  final int currentIndex;
  const WalkerBottomNavBar({super.key, required this.currentIndex});

  void _onItemTapped(BuildContext context, int index) {
    if (index == currentIndex) return;

    Widget nextScreen;

    switch (index) {
      case 0:
        nextScreen = const WalkerHomeScreen();
        break;
      case 1:
        nextScreen = const RequestScreen();
        break;
      case 2:
        nextScreen = const ScheduleScreen();
        break;
      case 3:
        nextScreen = const EarningsScreen();
        break;
      case 4:
        nextScreen = const ProfileEditScreen();
        break;
      default:
        return;
    }

    // Use pushReplacement to prevent back-button loops between nav items
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation1, animation2) => nextScreen,
        transitionDuration: Duration.zero, // Instant transition for smooth nav feel
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: const Color(0xFF2563EB),
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.white70,
      currentIndex: currentIndex,
      onTap: (index) => _onItemTapped(context, index),
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'Request'),
        BottomNavigationBarItem(icon: Icon(Icons.schedule), label: 'Schedule'),
        BottomNavigationBarItem(icon: Icon(Icons.attach_money), label: 'Earnings'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
      iconSize: 30, // Reduced size slightly for better fit with labels
      elevation: 5,
    );
  }
}

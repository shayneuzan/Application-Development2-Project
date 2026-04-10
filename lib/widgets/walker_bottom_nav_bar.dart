import 'package:flutter/material.dart';

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

    String route = '/walker-home';
    switch (index) {
      case 0: route = '/walker-home'; break;
      case 1: route = '/walker-requests'; break;
      case 2: route = '/walker-schedule'; break;
      case 3: route = '/walker-earnings'; break;
      case 4: route = '/walker-profile'; break;
    }
    Navigator.pushReplacementNamed(context, route);
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: Colors.blue,
      type: BottomNavigationBarType.fixed,
      currentIndex: currentIndex,
      onTap: (index) => _onItemTapped(context, index),
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'Request'),
        BottomNavigationBarItem(icon: Icon(Icons.schedule), label: 'Schedule'),
        BottomNavigationBarItem(icon: Icon(Icons.attach_money), label: 'Earnings'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
      iconSize: 40,
      elevation: 5,
    );
  }
}

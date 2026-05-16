import 'package:flutter/material.dart';
// Import your screens here
import '../../l10n/generated/app_localizations.dart';
import '../owner/browse_walkers_list_screen.dart';
import '../owner/booking_history_screen.dart';
import '../owner/explore_map_screen.dart';
import '../owner/profile_screen.dart';
import '../owner/owner_home_screen.dart';

class OwnerBottomNavBar extends StatelessWidget {
  final int currentIndex;

  const OwnerBottomNavBar({
    super.key,
    required this.currentIndex,
  });

  void _onTap(BuildContext context, int index) {
    if (index == currentIndex) return;

    Widget nextScreen;
    switch (index) {
      case 0:
        nextScreen = const OwnerHomeScreen();
        break;
      case 1:
        nextScreen = const BrowseWalkersListScreen();
        break;
      case 2:
        nextScreen = const BookingHistoryScreen();
        break;
      case 3:
        nextScreen = const ExploreMapScreen();
        break;
      case 4:
        nextScreen = const ProfileScreen();
        break;
      default:
        return;
    }

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, anim1, anim2) => nextScreen,
        transitionDuration: Duration.zero, // Instant transition for nav bars
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    const primaryBlue = Color(0xFF2563EB);

    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white54,
        backgroundColor: primaryBlue,
        onTap: (index) => _onTap(context, index),
        items: [
          BottomNavigationBarItem(icon: const Icon(Icons.home_outlined), label: l10n.home),
          BottomNavigationBarItem(icon: const Icon(Icons.search), label: l10n.walkers),
          BottomNavigationBarItem(icon: const Icon(Icons.calendar_month_outlined), label: l10n.bookings),
          BottomNavigationBarItem(icon: const Icon(Icons.map_outlined), label: l10n.map),
          BottomNavigationBarItem(icon: const Icon(Icons.person_outline), label: l10n.profile),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../auth/login_screen.dart';
import 'admin_home_tab_screen.dart';
import 'admin_users_tab_screen.dart';
import 'admin_bookings_tab_screen.dart';
import 'admin_disputes_tabs_screen.dart';
import 'admin_more_tab_screen.dart';
import '../../i18n/app_localizations.dart';

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
  Locale _locale = const Locale('en');
  bool _isDarkMode = false;

  static final ThemeData _lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: const Color(0xFF2563EB),
    scaffoldBackgroundColor: const Color(0xFFF8FAFC),
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF2563EB),
      surface: Colors.white,
      onSurface: Color(0xFF1E293B),
    ),
    cardColor: Colors.white,
    dividerColor: const Color(0xFFE2E8F0),
    textTheme: const TextTheme(
      bodySmall: TextStyle(color: Color(0xFF64748B)),
    ),
  );

  static final ThemeData _darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: const Color(0xFF2563EB),
    scaffoldBackgroundColor: const Color(0xFF1E293B),
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF2563EB),
      surface: Color(0xFF334155),
      onSurface: Color(0xFFF1F5F9),
    ),
    cardColor: const Color(0xFF334155),
    dividerColor: const Color(0xFF475569),
    textTheme: const TextTheme(
      bodySmall: TextStyle(color: Color(0xFF94A3B8)),
    ),
  );

  void _goTo(Widget screen) {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
            child: child,
          );
        },
      ),
    );
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    _goTo(LoginScreen());
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: _isDarkMode ? _darkTheme : _lightTheme,
      child: Localizations.override(
        context: context,
        locale: _locale,
        delegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        child: Builder(
          builder: (ctx) {
            final loc = AppLocalizations.of(ctx)!;
            return Scaffold(
              backgroundColor: Theme.of(ctx).scaffoldBackgroundColor,
              body: _buildCurrentTab(),
              bottomNavigationBar: BottomNavigationBar(
                currentIndex: _currentIndex,
                onTap: (index) => setState(() => _currentIndex = index),
                type: BottomNavigationBarType.fixed,
                backgroundColor: const Color(0xFF2563EB),
                selectedItemColor: Colors.white,
                unselectedItemColor: Colors.white54,
                selectedFontSize: 11,
                unselectedFontSize: 11,
                items: [
                  BottomNavigationBarItem(icon: const Icon(Icons.house_outlined),  activeIcon: const Icon(Icons.house),      label: loc.dashboard),
                  BottomNavigationBarItem(icon: const Icon(Icons.people_outlined),  activeIcon: const Icon(Icons.people),     label: loc.users),
                  BottomNavigationBarItem(icon: const Icon(Icons.book_outlined),    activeIcon: const Icon(Icons.book),       label: loc.bookings),
                  BottomNavigationBarItem(icon: const Icon(Icons.report_outlined),  activeIcon: const Icon(Icons.report),     label: loc.disputes),
                  BottomNavigationBarItem(icon: const Icon(Icons.menu),             activeIcon: const Icon(Icons.menu_open),  label: loc.more),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCurrentTab() {
    switch (_currentIndex) {
      case 0: return AdminHomeTab();
      case 1: return AdminUsersTab();
      case 2: return const AdminBookingsTab();
      case 3: return AdminDisputesTab();
      case 4: return AdminMoreTab(
        onLogout: _logout,
        locale: _locale,
        isDarkMode: _isDarkMode,
        onLocaleChanged: (locale) => setState(() => _locale = locale),
        onThemeChanged: (isDark) => setState(() => _isDarkMode = isDark),
      );
      default: return AdminHomeTab();
    }
  }
}
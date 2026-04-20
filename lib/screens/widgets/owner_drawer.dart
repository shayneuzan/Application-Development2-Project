import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../owner/owner_home_screen.dart';
import '../owner/booking_history_screen.dart';
import '../owner/profile_screen.dart';
import '../owner/pet_profile_screen.dart';
import '../owner/notifications_screen.dart';
import '../owner/browse_walkers_list_screen.dart';
import '../auth/login_screen.dart';

class OwnerDrawer extends StatelessWidget {
  final String currentPage;

  const OwnerDrawer({super.key, required this.currentPage});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
            color: const Color(0xFF1E3A5F),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white24,
                  child: Icon(Icons.person, color: Colors.white, size: 35),
                ),
                const SizedBox(width: 15),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'John Smith',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Owner',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          
          // Menu Items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(
                  context,
                  icon: Icons.home_outlined,
                  title: 'Home',
                  isSelected: currentPage == 'Home',
                  onTap: () => _navigateTo(context, const OwnerHomeScreen()),
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.search,
                  title: 'Browse Walkers',
                  isSelected: currentPage == 'Walkers',
                  onTap: () => _navigateTo(context, const BrowseWalkersListScreen()),
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.calendar_month_outlined,
                  title: 'My Bookings',
                  isSelected: currentPage == 'Bookings',
                  onTap: () => _navigateTo(context, const BookingHistoryScreen()),
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.location_on_outlined,
                  title: 'Track Walk',
                  isSelected: currentPage == 'Track',
                  onTap: () {}, // TODO: Map screen
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.pets_outlined,
                  title: 'My Pets',
                  isSelected: currentPage == 'Pets',
                  onTap: () => _navigateTo(context, const PetProfileScreen()),
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.notifications_none,
                  title: 'Notifications',
                  isSelected: currentPage == 'Notifications',
                  onTap: () => _navigateTo(context, const NotificationsScreen()),
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.person_outline,
                  title: 'Profile',
                  isSelected: currentPage == 'Profile',
                  onTap: () => _navigateTo(context, const ProfileScreen()),
                ),
              ],
            ),
          ),
          
          // Logout
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              'Logout',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    const primaryBlue = Color(0xFF2563EB);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFEFF6FF) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? primaryBlue : const Color(0xFF64748B),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? primaryBlue : const Color(0xFF1E293B),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        onTap: onTap,
      ),
    );
  }

  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.pop(context);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }
}

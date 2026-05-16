import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../chat/chat_list_screen.dart';
import '../owner/owner_home_screen.dart';
import '../owner/booking_history_screen.dart';
import '../owner/profile_screen.dart';
import '../owner/pet_profile_screen.dart';
import '../owner/browse_walkers_list_screen.dart';
import '../shared/settings_screen.dart';
import '../auth/login_screen.dart';
import '../../services/firestore_service.dart';
import '../../models/user_model.dart';
import '../../l10n/generated/app_localizations.dart';
import '../shared/notification_screen.dart';

class OwnerDrawer extends StatelessWidget {
  final String currentPage;

  const OwnerDrawer({super.key, required this.currentPage});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final FirestoreService firestoreService = FirestoreService();
    final User? currentUser = FirebaseAuth.instance.currentUser;

    return Drawer(
      child: Column(
        children: [
          // Header
          currentUser == null
              ? Container(
                  padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
                  color: const Color(0xFF1E3A5F),
                  child: Center(child: Text(l10n.notLoggedIn, style: const TextStyle(color: Colors.white))),
                )
              : StreamBuilder<UserModel>(
                  stream: firestoreService.getUserStream(currentUser.uid),
                  builder: (context, snapshot) {
                    final user = snapshot.data;
                    final String name = user?.name ?? l10n.loading;
                    final String role = user?.role ?? 'Owner';
                    final String? profilePic = user?.profileImageUrl;

                    return Container(
                      padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
                      color: const Color(0xFF1E3A5F),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.white24,
                            backgroundImage: (profilePic != null && profilePic.isNotEmpty)
                                ? NetworkImage(profilePic)
                                : null,
                            child: (profilePic == null || profilePic.isEmpty)
                                ? const Icon(Icons.person, color: Colors.white, size: 35)
                                : null,
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  role[0].toUpperCase() + role.substring(1),
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    );
                  },
                ),
          
          // Menu Items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(
                  context,
                  icon: Icons.home_outlined,
                  title: l10n.home,
                  isSelected: currentPage == 'Home',
                  onTap: () => _navigateTo(context, const OwnerHomeScreen()),
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.search,
                  title: l10n.browseWalkers,
                  isSelected: currentPage == 'Walkers',
                  onTap: () => _navigateTo(context, const BrowseWalkersListScreen()),
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.calendar_month_outlined,
                  title: l10n.myBookings,
                  isSelected: currentPage == 'Bookings',
                  onTap: () => _navigateTo(context, const BookingHistoryScreen()),
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.location_on_outlined,
                  title: l10n.trackWalk,
                  isSelected: currentPage == 'Track',
                  onTap: () {}, // TODO: Map screen
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.pets_outlined,
                  title: l10n.myPets,
                  isSelected: currentPage == 'Pets',
                  onTap: () => _navigateTo(context, const PetProfileScreen()),
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.notifications_none,
                  title: l10n.notifications,
                  isSelected: currentPage == 'Notifications',
                  onTap: () => _navigateTo(context, NotificationScreen()),
                ),
                // This is for the Chat Group List
                _buildDrawerItem(
                  context,
                  icon: Icons.chat_bubble_outline,
                  title: 'Messages',
                  isSelected: currentPage == 'Messages',
                  onTap: () => _navigateTo(context, ChatListScreen()),
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.person_outline,
                  title: l10n.profile,
                  isSelected: currentPage == 'Profile',
                  onTap: () => _navigateTo(context, const ProfileScreen()),
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.settings_outlined,
                  title: l10n.settings,
                  isSelected: currentPage == 'Settings',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SettingsScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
          
          // Logout
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: Text(
              l10n.logOut,
              style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
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

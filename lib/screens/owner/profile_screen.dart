import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../auth/login_screen.dart';
import '../shared/notification_screen.dart';
import 'owner_home_screen.dart';
import 'booking_history_screen.dart';
import 'pet_profile_screen.dart';

import 'browse_walkers_list_screen.dart';
import 'edit_profile_screen.dart';
import 'explore_map_screen.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../models/user_model.dart';
import '../../models/pet_model.dart';
import '../widgets/owner_drawer.dart';
import 'package:pawwalk/l10n/generated/app_localizations.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    const primaryBlue = Color(0xFF2563EB);

    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

    if (_currentUser == null) {
      return Scaffold(body: Center(child: Text(l10n.pleaseLogin)));
    }

    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        backgroundColor: primaryBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () => scaffoldKey.currentState?.openDrawer(),
        ),
        title: Text(
          l10n.profile,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      drawer: const OwnerDrawer(currentPage: 'Profile'),
      body: StreamBuilder<UserModel>(
        stream: _firestoreService.getUserStream(_currentUser!.uid),
        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          final user = userSnapshot.data;
          if (user == null) {
            return Center(child: Text(l10n.errorLoadingProfile));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // User Info Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.04),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: isDarkMode ? Colors.white10 : const Color(0xFFF1F5F9),
                            backgroundImage: (user.profileImageUrl != null && user.profileImageUrl!.isNotEmpty)
                              ? NetworkImage(user.profileImageUrl!) 
                              : null,
                            child: (user.profileImageUrl == null || user.profileImageUrl!.isEmpty)
                              ? const Icon(Icons.person, size: 55, color: Color(0xFF94A3B8))
                              : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EditProfileScreen(
                                      currentName: user.name,
                                      currentEmail: user.email,
                                      currentPhone: user.phoneNumber,
                                      currentAddress: user.address,
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                  color: primaryBlue,
                                  shape: BoxShape.circle,
                                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                                ),
                                child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        user.name,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        user.email,
                        style: TextStyle(
                          fontSize: 14,
                          color: theme.textTheme.bodySmall?.color,
                        ),
                      ),
                      if (user.address != null && user.address!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.location_on, size: 14, color: primaryBlue),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  user.address!,
                                  style: TextStyle(fontSize: 13, color: theme.textTheme.bodySmall?.color),
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 16),
                      OutlinedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditProfileScreen(
                                currentName: user.name,
                                currentEmail: user.email,
                                currentPhone: user.phoneNumber,
                                currentAddress: user.address,
                              ),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: theme.dividerColor),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                        ),
                        child: Text(
                          l10n.editProfile,
                          style: TextStyle(color: theme.textTheme.bodyLarge?.color, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Stats Section
                Row(
                  children: [
                    StreamBuilder<List<Map<String, dynamic>>>(
                      stream: _firestoreService.getBookingsByOwner(user.id),
                      builder: (context, snapshot) {
                        final count = snapshot.hasData ? snapshot.data!.length : 0;
                        return _buildStatCard(count.toString(), l10n.totalWalks, primaryBlue);
                      }
                    ),
                    const SizedBox(width: 12),
                    StreamBuilder<List<PetModel>>(
                      stream: _firestoreService.getPetsByOwner(user.id),
                      builder: (context, snapshot) {
                        final count = snapshot.hasData ? snapshot.data!.length : 0;
                        return _buildStatCard(
                          count.toString(),
                          l10n.pets,
                          primaryBlue,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const PetProfileScreen()),
                            );
                          },
                        );
                      }
                    ),
                    const SizedBox(width: 12),
                    _buildStatCard(
                      user.favoriteWalkers.length.toString(),
                      l10n.favorites,
                      primaryBlue,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const BrowseWalkersListScreen(showFavoritesOnly: true),
                          ),
                        );
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Settings List
                Container(
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.04),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildSettingItem(
                        Icons.pets,
                        l10n.myPets,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const PetProfileScreen()),
                          );
                        },
                      ),
                      Divider(height: 1, indent: 56, color: theme.dividerColor),
                      _buildSettingItem(
                        Icons.notifications_none,
                        l10n.notifications,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const NotificationScreen()),
                          );
                        },
                      ),
                      Divider(height: 1, indent: 56, color: theme.dividerColor),
                      _buildSettingItem(Icons.security, l10n.privacySecurity),
                      Divider(height: 1, indent: 56, color: theme.dividerColor),
                      _buildSettingItem(Icons.support_agent, l10n.contactSupport),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Logout Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await _authService.signOut();
                      if (context.mounted) {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (context) => const LoginScreen()),
                          (route) => false,
                        );
                      }
                    },
                    icon: const Icon(Icons.logout),
                    label: Text(
                      l10n.logOut,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        }
      ),
      bottomNavigationBar: Container(
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
          currentIndex: 4, 
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white54,
          backgroundColor: primaryBlue,
          onTap: (index) {
            if (index == 0) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const OwnerHomeScreen()),
              );
            } else if (index == 1) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const BrowseWalkersListScreen()),
              );
            } else if (index == 2) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const BookingHistoryScreen()),
              );
            } else if (index == 3) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const ExploreMapScreen()),
              );
            }
          },
          items: [
            BottomNavigationBarItem(icon: const Icon(Icons.home_outlined), label: l10n.home),
            BottomNavigationBarItem(icon: const Icon(Icons.search), label: l10n.walkers),
            BottomNavigationBarItem(icon: const Icon(Icons.calendar_month_outlined), label: l10n.bookings),
            BottomNavigationBarItem(icon: const Icon(Icons.map_outlined), label: l10n.map),
            BottomNavigationBarItem(icon: const Icon(Icons.person_outline), label: l10n.profile),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String value, String label, Color blue, {VoidCallback? onTap}) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDarkMode ? 0.2 : 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: blue,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: theme.textTheme.bodySmall?.color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingItem(IconData icon, String title, {String? subtitle, VoidCallback? onTap}) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: theme.brightness == Brightness.dark ? Colors.white10 : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: theme.brightness == Brightness.dark ? Colors.white70 : const Color(0xFF64748B), size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: subtitle != null ? Text(subtitle, style: const TextStyle(fontSize: 12)) : null,
      trailing: Icon(Icons.chevron_right, color: theme.hintColor),
      onTap: onTap,
    );
  }
}

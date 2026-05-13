import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'payment_methods_screen.dart';
import 'address_management_screen.dart';
import '../../services/firestore_service.dart';
import '../../models/user_model.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final String? _userId = FirebaseAuth.instance.currentUser?.uid;

  void _showLanguageDialog(String currentLanguage) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLanguageOption('English (US)', currentLanguage),
            _buildLanguageOption('French (FR)', currentLanguage),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageOption(String language, String currentLanguage) {
    return RadioListTile<String>(
      title: Text(language),
      value: language,
      groupValue: currentLanguage,
      activeColor: const Color(0xFF2563EB),
      onChanged: (value) async {
        if (value != null && _userId != null) {
          await _firestoreService.updateUser(_userId!, {'language': value});
          if (mounted) Navigator.pop(context);
        }
      },
    );
  }

  Future<void> _updateSetting(String key, bool value) async {
    if (_userId != null) {
      await _firestoreService.updateUser(_userId!, {key: value});
    }
  }

  @override
  Widget build(BuildContext context) {
    const textDark = Color(0xFF1E293B);
    const backgroundGray = Color(0xFFF8FAFC);
    const primaryBlue = Color(0xFF2563EB);

    if (_userId == null) {
      return const Scaffold(body: Center(child: Text("Please log in")));
    }

    return Scaffold(
      backgroundColor: backgroundGray,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Settings',
          style: TextStyle(color: textDark, fontWeight: FontWeight.bold),
        ),
      ),
      body: StreamBuilder<UserModel>(
        stream: _firestoreService.getUserStream(_userId!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text("Error loading settings"));
          }

          final user = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Account Section
                _buildSectionHeader('Account'),
                _buildSettingsCard([
                  _buildSettingItem(
                    Icons.credit_card,
                    'Payment Methods',
                    subtitle: 'Manage your cards',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const PaymentMethodsScreen()),
                      );
                    },
                  ),
                  const Divider(height: 1, indent: 56),
                  _buildSettingItem(
                    Icons.location_on_outlined,
                    'Saved Addresses',
                    subtitle: user.address ?? 'Add your address',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AddressManagementScreen()),
                      );
                    },
                  ),
                  const Divider(height: 1, indent: 56),
                  _buildSettingItem(
                    Icons.language,
                    'Language',
                    subtitle: user.language,
                    onTap: () => _showLanguageDialog(user.language),
                  ),
                ]),

                const SizedBox(height: 32),

                // Notifications Section
                _buildSectionHeader('Notifications'),
                _buildSettingsCard([
                  _buildToggleItem(
                    Icons.notifications_none,
                    'Push Notifications',
                    user.pushNotifications,
                    (val) => _updateSetting('pushNotifications', val),
                  ),
                  const Divider(height: 1, indent: 56),
                  _buildToggleItem(
                    Icons.email_outlined,
                    'Email Updates',
                    user.emailUpdates,
                    (val) => _updateSetting('emailUpdates', val),
                  ),
                ]),

                const SizedBox(height: 32),

                // Appearance Section
                _buildSectionHeader('Appearance'),
                _buildSettingsCard([
                  _buildToggleItem(
                    Icons.dark_mode_outlined,
                    'Dark Mode',
                    user.darkMode,
                    (val) => _updateSetting('darkMode', val),
                  ),
                ]),

                const SizedBox(height: 32),

                // Support & About Section
                _buildSectionHeader('Support'),
                _buildSettingsCard([
                  _buildSettingItem(Icons.help_outline, 'Help Center'),
                  const Divider(height: 1, indent: 56),
                  _buildSettingItem(Icons.policy_outlined, 'Privacy Policy'),
                  const Divider(height: 1, indent: 56),
                  _buildSettingItem(Icons.info_outline, 'About PawWalk'),
                ]),

                const SizedBox(height: 40),

                Center(
                  child: Text(
                    'Version 1.0.0',
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Color(0xFF64748B),
        ),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSettingItem(IconData icon, String title, {String? subtitle, VoidCallback? onTap}) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: const Color(0xFF64748B), size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          color: Color(0xFF1E293B),
        ),
      ),
      subtitle: subtitle != null ? Text(subtitle, style: const TextStyle(fontSize: 12)) : null,
      trailing: const Icon(Icons.chevron_right, color: Color(0xFFCBD5E1)),
      onTap: onTap,
    );
  }

  Widget _buildToggleItem(IconData icon, String title, bool value, ValueChanged<bool> onChanged) {
    return SwitchListTile(
      secondary: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: const Color(0xFF64748B), size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          color: Color(0xFF1E293B),
        ),
      ),
      activeColor: const Color(0xFF2563EB),
      value: value,
      onChanged: onChanged,
    );
  }
}

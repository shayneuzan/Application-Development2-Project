import 'package:flutter/material.dart';
import 'payment_methods_screen.dart';
import 'address_management_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _pushNotifications = true;
  bool _darkMode = false;
  bool _emailUpdates = false;
  String _selectedLanguage = 'English (US)';

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLanguageOption('English (US)'),
            _buildLanguageOption('French (FR)'),
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

  Widget _buildLanguageOption(String language) {
    return RadioListTile<String>(
      title: Text(language),
      value: language,
      groupValue: _selectedLanguage,
      activeColor: const Color(0xFF2563EB),
      onChanged: (value) {
        setState(() {
          _selectedLanguage = value!;
        });
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const textDark = Color(0xFF1E293B);
    const backgroundGray = Color(0xFFF8FAFC);

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
      body: SingleChildScrollView(
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
                subtitle: 'Visa •••• 4242',
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
                subtitle: 'Home, Office',
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
                subtitle: _selectedLanguage,
                onTap: _showLanguageDialog,
              ),
            ]),

            const SizedBox(height: 32),

            // Notifications Section
            _buildSectionHeader('Notifications'),
            _buildSettingsCard([
              _buildToggleItem(
                Icons.notifications_none,
                'Push Notifications',
                _pushNotifications,
                (val) => setState(() => _pushNotifications = val),
              ),
              const Divider(height: 1, indent: 56),
              _buildToggleItem(
                Icons.email_outlined,
                'Email Updates',
                _emailUpdates,
                (val) => setState(() => _emailUpdates = val),
              ),
            ]),

            const SizedBox(height: 32),

            // Appearance Section
            _buildSectionHeader('Appearance'),
            _buildSettingsCard([
              _buildToggleItem(
                Icons.dark_mode_outlined,
                'Dark Mode',
                _darkMode,
                (val) => setState(() => _darkMode = val),
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

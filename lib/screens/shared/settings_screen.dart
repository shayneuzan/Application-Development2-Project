import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../owner/payment_methods_screen.dart';
import '../owner/address_management_screen.dart';
import 'package:provider/provider.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../services/firestore_service.dart';
import '../../services/locale_provider.dart';
import '../../models/user_model.dart';
import '../auth/login_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final String? _userId = FirebaseAuth.instance.currentUser?.uid;

  void _showLanguageDialog(String currentLanguage) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.selectLanguage),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLanguageOption(l10n.english, 'en', currentLanguage),
            _buildLanguageOption(l10n.french, 'fr', currentLanguage),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageOption(String languageLabel, String localeCode, String currentLanguage) {
    return RadioListTile<String>(
      title: Text(languageLabel),
      value: localeCode,
      // Logic for comparing current language from Firestore
      groupValue: (currentLanguage == 'French (FR)' || currentLanguage == 'fr') ? 'fr' : 'en',
      activeColor: Theme.of(context).primaryColor,
      onChanged: (value) async {
        if (value != null) {
          // Update I18N Bridge (Locale Provider)
          Provider.of<LocaleProvider>(context, listen: false).setLocale(Locale(value));

          // Persist to Firestore
          if (_userId != null) {
            await _firestoreService.updateUser(_userId, {'language': value});
          }

          if (mounted) Navigator.pop(context);
        }
      },
    );
  }

  Future<void> _updateSetting(String key, bool value) async {
    if (_userId != null) {
      await _firestoreService.updateUser(_userId, {key: value});

      // Specifically for Dark Mode: Update the Provider so the app flips colors instantly
      if (key == 'darkMode') {
        if (!mounted) return;
        Provider.of<LocaleProvider>(context, listen: false).toggleTheme(value);
      }
    }
  }

  Future<void> _handleLogout() async {
    final l10n = AppLocalizations.of(context)!;
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.logOut),
        content: Text(l10n.confirmLogOut),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.logOut, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
              (route) => false,
        );
      }
    }
  }

  Future<void> _handleDeleteAccount() async {
    final l10n = AppLocalizations.of(context)!;
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteAccount, style: const TextStyle(color: Colors.red)),
        content: Text(l10n.deleteAccountConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.delete, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true && _userId != null) {
      try {
        await _firestoreService.deleteUser(_userId);
        await FirebaseAuth.instance.currentUser?.delete();
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
          );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.accountDeleted)),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.somethingWentWrong)),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    if (_userId == null) {
      return Scaffold(body: Center(child: Text(l10n.notLoggedIn)));
    }

    return Scaffold(
      // DARK MODE: Uses scaffoldBackgroundColor from theme
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.iconTheme.color),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n.settings,
          style: TextStyle(
              color: theme.textTheme.titleLarge?.color,
              fontWeight: FontWeight.bold
          ),
        ),
      ),
      body: StreamBuilder<UserModel>(
        stream: _firestoreService.getUserStream(_userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return Center(child: Text(l10n.somethingWentWrong));
          }

          final user = snapshot.data!;

          // Localization for Subtitles
          String paymentSubtitle = l10n.noCards;
          final defaultCard = user.paymentMethods.firstWhere(
                (c) => c['isDefault'] == true,
            orElse: () => {},
          );
          if (defaultCard.isNotEmpty) {
            paymentSubtitle = '${defaultCard['type']} •••• ${defaultCard['last4']}';
          }

          String addressSubtitle = user.address ?? l10n.enterAddress;
          final defaultAddr = user.savedAddresses.firstWhere(
                (a) => a['isDefault'] == true,
            orElse: () => {},
          );
          if (defaultAddr.isNotEmpty) {
            addressSubtitle = '${defaultAddr['label']}: ${user.address}';
          }

          String displayLanguage = user.language == 'fr' ? l10n.french : l10n.english;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader(l10n.account),
                _buildSettingsCard([
                  _buildSettingItem(
                    Icons.credit_card,
                    l10n.paymentMethods,
                    subtitle: paymentSubtitle,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const PaymentMethodsScreen())),
                  ),
                  const Divider(height: 1, indent: 56),
                  _buildSettingItem(
                    Icons.location_on_outlined,
                    l10n.savedAddresses,
                    subtitle: addressSubtitle,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AddressManagementScreen())),
                  ),
                  const Divider(height: 1, indent: 56),
                  _buildSettingItem(
                    Icons.language,
                    l10n.language,
                    subtitle: displayLanguage,
                    onTap: () => _showLanguageDialog(user.language),
                  ),
                ]),

                const SizedBox(height: 32),

                _buildSectionHeader(l10n.notifications),
                _buildSettingsCard([
                  _buildToggleItem(
                    Icons.notifications_none,
                    l10n.pushNotifications,
                    user.pushNotifications,
                        (val) => _updateSetting('pushNotifications', val),
                  ),
                  const Divider(height: 1, indent: 56),
                  _buildToggleItem(
                    Icons.email_outlined,
                    l10n.emailUpdates,
                    user.emailUpdates,
                        (val) => _updateSetting('emailUpdates', val),
                  ),
                ]),

                const SizedBox(height: 32),

                _buildSectionHeader(l10n.appearance),
                _buildSettingsCard([
                  _buildToggleItem(
                    Icons.dark_mode_outlined,
                    l10n.darkMode,
                    user.darkMode,
                        (val) => _updateSetting('darkMode', val),
                  ),
                ]),

                const SizedBox(height: 32),

                _buildSectionHeader(l10n.support),
                _buildSettingsCard([
                  _buildSettingItem(Icons.help_outline, l10n.helpCenter),
                  const Divider(height: 1, indent: 56),
                  _buildSettingItem(Icons.policy_outlined, l10n.privacyPolicy),
                  const Divider(height: 1, indent: 56),
                  _buildSettingItem(Icons.info_outline, l10n.aboutPawWalk),
                ]),

                const SizedBox(height: 32),

                _buildSectionHeader(l10n.dangerZone),
                _buildSettingsCard([
                  _buildSettingItem(
                    Icons.delete_forever_outlined,
                    l10n.deleteAccount,
                    titleColor: Colors.red,
                    onTap: _handleDeleteAccount,
                  ),
                ]),

                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: _handleLogout,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      foregroundColor: Colors.red,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.logout),
                        const SizedBox(width: 8),
                        Text(l10n.logOut, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),
                Center(
                  child: Text(
                    '${l10n.version} 1.0.0',
                    style: TextStyle(color: theme.hintColor, fontSize: 12),
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
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).hintColor,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor, // DARK MODE FIX
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

  Widget _buildSettingItem(IconData icon, String title, {String? subtitle, Color? titleColor, VoidCallback? onTap}) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: theme.dividerColor.withOpacity(0.05), // DARK MODE: subtle background
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: titleColor ?? theme.hintColor, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: titleColor ?? theme.textTheme.bodyLarge?.color,
        ),
      ),
      subtitle: subtitle != null ? Text(subtitle, style: TextStyle(fontSize: 12, color: theme.hintColor)) : null,
      trailing: const Icon(Icons.chevron_right, color: Color(0xFFCBD5E1), size: 18),
      onTap: onTap,
    );
  }

  Widget _buildToggleItem(IconData icon, String title, bool value, ValueChanged<bool> onChanged) {
    final theme = Theme.of(context);
    return SwitchListTile(
      secondary: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: theme.dividerColor.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: theme.hintColor, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: theme.textTheme.bodyLarge?.color,
        ),
      ),
      activeThumbColor: theme.primaryColor,
      value: value,
      onChanged: onChanged,
    );
  }
}
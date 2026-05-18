import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../services/locale_provider.dart';

// ─────────────────────────────────────────────────────────
// ADMIN PLATFORM SETTINGS SCREEN
// Saves all settings to Firestore at settings/platform.
// Theme and locale changes bubble up via callbacks to
// AdminDashboardScreen which owns that state.
// ─────────────────────────────────────────────────────────

class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  final DocumentReference _settingsDoc =
  FirebaseFirestore.instance.collection('settings').doc('platform');

  bool _maintenanceMode = false;
  String _supportEmail = '';
  bool _loading = true;

  final TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    try {
      DocumentSnapshot doc = await _settingsDoc.get();
      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        setState(() {
          _maintenanceMode = data['maintenanceMode'] ?? false;
          _supportEmail = data['supportEmail'] ?? '';
          _emailController.text = _supportEmail;
        });
      }
    } catch (e) {
      _showError('Failed to load settings: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _saveSetting(String field, dynamic value) async {
    try {
      await _settingsDoc.set({field: value}, SetOptions(merge: true));
      _showSuccess('Saved');
    } catch (e) {
      _showError('Failed to save: $e');
    }
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green, duration: const Duration(seconds: 2)),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red, duration: const Duration(seconds: 3)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: const Color(0xFF2563EB),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          loc.platformSettings,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF2563EB)))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionLabel(loc.general),
            const SizedBox(height: 10),
            _settingsCard(
              children: [
                _settingRow(
                  icon: Icons.language_outlined,
                  iconColor: const Color(0xFF2563EB),
                  title: loc.language,
                  subtitle: localeProvider.locale?.languageCode == 'fr' ? loc.french : loc.english,
                  trailing: DropdownButton<String>(
                    value: localeProvider.locale?.languageCode == 'fr' ? 'French' : 'English',
                    underline: const SizedBox(),
                    style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.w600, fontSize: 14),
                    dropdownColor: theme.cardColor,
                    items: ['English', 'French'].map((lang) => DropdownMenuItem(value: lang, child: Text(lang))).toList(),
                    onChanged: (value) async {
                      if (value == null) return;
                      // Update Provider (instantly changes UI)
                      final newLocale = value == 'French' ? const Locale('fr') : const Locale('en');
                      localeProvider.setLocale(newLocale);
                      // Persist to Admin Platform settings
                      await _saveSetting('language', value);
                    },
                  ),
                ),
                Divider(height: 1, color: theme.dividerColor),
                _settingRow(
                  icon: Icons.info_outline,
                  iconColor: const Color(0xFF64748B),
                  title: loc.appVersion,
                  subtitle: 'Version 1.0.0',
                ),
              ],
            ),
            const SizedBox(height: 24),
            _sectionLabel(loc.appearance),
            const SizedBox(height: 10),
            _settingsCard(
              children: [
                _settingRow(
                  icon: Icons.dark_mode_outlined,
                  iconColor: const Color(0xFF8B5CF6),
                  title: loc.darkMode,
                  subtitle: localeProvider.isDarkMode ? 'On' : 'Off',
                  trailing: Switch(
                    value: localeProvider.isDarkMode,
                    activeColor: const Color(0xFF2563EB),
                    onChanged: (value) async {
                      // Update Provider (instantly changes colors)
                      localeProvider.toggleTheme(value);
                      // Persist to Admin Platform settings
                      await _saveSetting('darkMode', value);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _sectionLabel(loc.system),
            const SizedBox(height: 10),
            _settingsCard(
              children: [
                _settingRow(
                  icon: Icons.construction_outlined,
                  iconColor: Colors.orange,
                  title: loc.maintenanceMode,
                  subtitle: _maintenanceMode ? 'Locked' : 'Live',
                  trailing: Switch(
                    value: _maintenanceMode,
                    activeColor: const Color(0xFF2563EB),
                    onChanged: (value) async {
                      setState(() => _maintenanceMode = value);
                      await _saveSetting('maintenanceMode', value);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _sectionLabel(loc.support),
            const SizedBox(height: 10),
            _buildEmailCard(theme, loc),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.grey));
  }

  Widget _settingsCard({required List<Widget> children}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Column(children: children),
    );
  }

  Widget _settingRow({required IconData icon, Color? iconColor, required String title, String? subtitle, Widget? trailing}) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: trailing,
    );
  }

  Widget _buildEmailCard(ThemeData theme, AppLocalizations loc) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          _settingRow(icon: Icons.email_outlined, title: loc.contactEmail, subtitle: "Support address"),
          TextField(
            controller: _emailController,
            decoration: InputDecoration(
              hintText: 'support@pawwalk.com',
              filled: true,
              fillColor: theme.scaffoldBackgroundColor,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onSubmitted: (val) => _saveSetting('supportEmail', val),
          ),
        ],
      ),
    );
  }
}
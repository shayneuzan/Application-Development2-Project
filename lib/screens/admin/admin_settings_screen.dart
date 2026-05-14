import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../../i18n/app_localizations.dart';

// ─────────────────────────────────────────────────────────
// ADMIN PLATFORM SETTINGS SCREEN
// Saves all settings to Firestore at settings/platform.
// Theme and locale changes bubble up via callbacks to
// AdminDashboardScreen which owns that state.
// ─────────────────────────────────────────────────────────

class AdminSettingsScreen extends StatefulWidget {
  final bool isDarkMode;
  final Locale locale;
  final void Function(bool) onThemeChanged;
  final void Function(Locale) onLocaleChanged;

  const AdminSettingsScreen({
    super.key,
    required this.isDarkMode,
    required this.locale,
    required this.onThemeChanged,
    required this.onLocaleChanged,
  });

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {

  final DocumentReference _settingsDoc =
      FirebaseFirestore.instance.collection('settings').doc('platform');

  late String _language;
  bool _maintenanceMode = false;
  String _supportEmail = '';
  bool _loading = true;

  final TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _language = widget.locale.languageCode == 'fr' ? 'French' : 'English';
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
          _language = data['language'] ?? _language;
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

  static ThemeData _makeTheme(bool dark) => dark
      ? ThemeData(
          brightness: Brightness.dark,
          primaryColor: const Color(0xFF2563EB),
          scaffoldBackgroundColor: const Color(0xFF1E293B),
          colorScheme: const ColorScheme.dark(primary: Color(0xFF2563EB), surface: Color(0xFF334155), onSurface: Color(0xFFF1F5F9)),
          cardColor: const Color(0xFF334155),
          dividerColor: const Color(0xFF475569),
        )
      : ThemeData(
          brightness: Brightness.light,
          primaryColor: const Color(0xFF2563EB),
          scaffoldBackgroundColor: const Color(0xFFF8FAFC),
          colorScheme: const ColorScheme.light(primary: Color(0xFF2563EB), surface: Colors.white, onSurface: Color(0xFF1E293B)),
          cardColor: Colors.white,
          dividerColor: const Color(0xFFE2E8F0),
        );

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: _makeTheme(widget.isDarkMode),
      child: Localizations.override(
        context: context,
        locale: widget.locale,
        delegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        child: Builder(builder: (ctx) => _buildContent(ctx)),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final AppLocalizations loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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

                  // ── GENERAL ─────────────────────────────────────────
                  _sectionLabel(loc.general),
                  const SizedBox(height: 10),

                  _settingsCard(
                    children: [

                      _settingRow(
                        icon: Icons.language_outlined,
                        iconColor: const Color(0xFF2563EB),
                        title: loc.language,
                        subtitle: widget.locale.languageCode == 'fr' ? loc.french : loc.english,
                        trailing: DropdownButton<String>(
                          value: _language,
                          underline: const SizedBox(),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                          dropdownColor: Theme.of(context).cardColor,
                          items: ['English', 'French'].map((lang) {
                            return DropdownMenuItem(value: lang, child: Text(lang));
                          }).toList(),
                          onChanged: (value) async {
                            if (value == null) return;
                            setState(() => _language = value);
                            final newLocale = value == 'French' ? const Locale('fr') : const Locale('en');
                            widget.onLocaleChanged(newLocale);
                            await _saveSetting('language', value);
                          },
                        ),
                      ),

                      Divider(height: 1, color: Theme.of(context).dividerColor),

                      _settingRow(
                        icon: Icons.info_outline,
                        iconColor: const Color(0xFF64748B),
                        title: loc.appVersion,
                        subtitle: 'Current build',
                        trailing: const Text(
                          'Version 1.0.0',
                          style: TextStyle(color: Color(0xFF64748B), fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // ── APPEARANCE ───────────────────────────────────────
                  _sectionLabel(loc.appearance),
                  const SizedBox(height: 10),

                  _settingsCard(
                    children: [
                      _settingRow(
                        icon: Icons.dark_mode_outlined,
                        iconColor: const Color(0xFF8B5CF6),
                        title: loc.darkMode,
                        subtitle: widget.isDarkMode ? 'On' : 'Off',
                        trailing: Switch(
                          value: widget.isDarkMode,
                          activeColor: const Color(0xFF2563EB),
                          onChanged: (value) async {
                            widget.onThemeChanged(value);
                            try {
                              await _settingsDoc.set({'darkMode': value}, SetOptions(merge: true));
                            } catch (e) {
                              _showError('Failed to save: $e');
                            }
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // ── SYSTEM ───────────────────────────────────────────
                  _sectionLabel(loc.system),
                  const SizedBox(height: 10),

                  _settingsCard(
                    children: [
                      _settingRow(
                        icon: Icons.construction_outlined,
                        iconColor: Colors.orange,
                        title: loc.maintenanceMode,
                        subtitle: _maintenanceMode
                            ? 'App is currently locked for users'
                            : 'App is live and accessible',
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

                  // ── SUPPORT ──────────────────────────────────────────
                  _sectionLabel(loc.support),
                  const SizedBox(height: 10),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6, offset: const Offset(0, 2)),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.email_outlined, color: Color(0xFF10B981), size: 20),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  loc.contactEmail,
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface),
                                ),
                                const Text(
                                  'Support address shown to users',
                                  style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),

                        TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurface),
                          decoration: InputDecoration(
                            hintText: 'support@pawwalk.com',
                            hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
                            filled: true,
                            fillColor: Theme.of(context).scaffoldBackgroundColor,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF2563EB))),
                          ),
                        ),

                        const SizedBox(height: 12),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () async {
                              await _saveSetting('supportEmail', _emailController.text.trim());
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2563EB),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: Text(loc.saveEmail, style: const TextStyle(fontWeight: FontWeight.w700)),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
    );
  }

  Widget _sectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF64748B), letterSpacing: 0.5),
    );
  }

  Widget _settingsCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _settingRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required Widget trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: iconColor.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface)),
                Text(subtitle, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}
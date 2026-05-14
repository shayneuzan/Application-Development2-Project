import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'admin_settings_screen.dart';
import '../../i18n/app_localizations.dart';

// ─────────────────────────────────────────────────────────
// ADMIN MORE TAB
// Admin profile card, quick actions, logout
// ─────────────────────────────────────────────────────────

class AdminMoreTab extends StatelessWidget {

  final VoidCallback onLogout;
  final Locale locale;
  final bool isDarkMode;
  final void Function(Locale) onLocaleChanged;
  final void Function(bool) onThemeChanged;

  const AdminMoreTab({
    required this.onLogout,
    required this.locale,
    required this.isDarkMode,
    required this.onLocaleChanged,
    required this.onThemeChanged,
  });

  @override
  Widget build(BuildContext context) {

    final user = FirebaseAuth.instance.currentUser;

    AppLocalizations loc = AppLocalizations.of(context)!;
    Color textPrimary = Theme.of(context).colorScheme.onSurface;
    Color textMuted   = Theme.of(context).textTheme.bodySmall!.color!;
    Color cardColor   = Theme.of(context).cardColor;
    Color divider     = Theme.of(context).dividerColor;

    final List<Map<String, dynamic>> _menuItems = [
      {'id': 'announcement', 'label': loc.sendAnnouncement, 'icon': Icons.campaign_outlined,  'color': const Color(0xFF2563EB)},
      {'id': 'settings',     'label': loc.platformSettings, 'icon': Icons.settings_outlined,   'color': const Color(0xFF3B82F6)},
      {'id': 'reports',      'label': loc.viewReports,      'icon': Icons.bar_chart_outlined,  'color': const Color(0xFF8B5CF6)},
      {'id': 'help',         'label': loc.helpAndSupport,   'icon': Icons.help_outline,        'color': const Color(0xFF10B981)},
    ];

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const SizedBox(height: 24),

            Text(loc.more, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: textPrimary)),
            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6, offset: const Offset(0, 2))],
              ),
              child: Row(
                children: [
                  Container(
                    width: 52, height: 52,
                    decoration: BoxDecoration(color: const Color(0xFF2563EB), borderRadius: BorderRadius.circular(14)),
                    child: const Icon(Icons.admin_panel_settings, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(loc.administrator, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: textPrimary)),
                      Text(user?.email ?? 'admin@pawwalk.com', style: TextStyle(fontSize: 12, color: textMuted)),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(color: const Color(0xFF2563EB).withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                        child: Text(loc.admin, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF2563EB))),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Text(loc.quickActions, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: textPrimary)),
            const SizedBox(height: 12),

            Container(
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6, offset: const Offset(0, 2))],
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _menuItems.length,
                separatorBuilder: (context, index) => Divider(height: 1, color: divider),
                itemBuilder: (context, index) {
                  final item = _menuItems[index];
                  return ListTile(
                    leading: Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        color: (item['color'] as Color).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(item['icon'] as IconData, color: item['color'] as Color, size: 20),
                    ),
                    title: Text(item['label'] as String, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: textPrimary)),
                    trailing: Icon(Icons.chevron_right, color: textMuted, size: 20),
                    onTap: () {
                      if (item['id'] == 'settings') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AdminSettingsScreen(
                              isDarkMode: isDarkMode,
                              locale: locale,
                              onThemeChanged: onThemeChanged,
                              onLocaleChanged: onLocaleChanged,
                            ),
                          ),
                        );
                        return;
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${item['label']} coming soon')),
                      );
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: onLogout,
                icon: const Icon(Icons.logout, size: 18),
                label: Text(loc.signOut, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';import 'package:firebase_auth/firebase_auth.dart';
import 'admin_settings_screen.dart';
import '../../l10n/generated/app_localizations.dart';

// ─────────────────────────────────────────────────────────
// ADMIN MORE TAB
// Admin profile card, quick actions, logout
// ─────────────────────────────────────────────────────────

class AdminMoreTab extends StatelessWidget {
  final VoidCallback onLogout;

  const AdminMoreTab({super.key, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    final List<Map<String, dynamic>> menuItems = [
      {'id': 'announcement', 'label': loc.sendAnnouncement, 'icon': Icons.campaign_outlined, 'color': const Color(0xFF2563EB)},
      {'id': 'settings', 'label': loc.platformSettings, 'icon': Icons.settings_outlined, 'color': const Color(0xFF3B82F6)},
      {'id': 'reports', 'label': loc.viewReports, 'icon': Icons.bar_chart_outlined, 'color': const Color(0xFF8B5CF6)},
      {'id': 'help', 'label': loc.helpAndSupport, 'icon': Icons.help_outline, 'color': const Color(0xFF10B981)},
    ];

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            Text(loc.more, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: theme.colorScheme.onSurface)),
            const SizedBox(height: 20),

            // Profile Card
            _buildProfileCard(theme, loc, user),

            const SizedBox(height: 24),
            Text(loc.quickActions, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: theme.colorScheme.onSurface)),
            const SizedBox(height: 12),

            // Menu List
            _buildMenuList(theme, menuItems),

            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: onLogout,
                icon: const Icon(Icons.logout, size: 18),
                label: Text(loc.signOut, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard(ThemeData theme, AppLocalizations loc, User? user) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6)],
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
              Text(loc.administrator, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: theme.colorScheme.onSurface)),
              Text(user?.email ?? 'admin@pawwalk.com', style: TextStyle(fontSize: 12, color: theme.textTheme.bodySmall?.color)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuList(ThemeData theme, List<Map<String, dynamic>> items) {
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6)],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        separatorBuilder: (context, index) => Divider(height: 1, color: theme.dividerColor),
        itemBuilder: (context, index) {
          final item = items[index];
          return ListTile(
            leading: Icon(item['icon'], color: item['color']),
            title: Text(item['label'], style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 14)),
            trailing: const Icon(Icons.chevron_right, size: 20),
            onTap: () {
              if (item['id'] == 'settings') {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminSettingsScreen()));
              } else if (item['id'] == 'announcement') {
                // ... logic for announcement
              }
            },
          );
        },
      ),
    );
  }
}
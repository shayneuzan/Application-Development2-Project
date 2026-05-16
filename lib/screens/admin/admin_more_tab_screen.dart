import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'admin_settings_screen.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../services/firestore_service.dart';

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
                      if (item['id'] == 'announcement') {
                        _showAnnouncementSheet(context);
                        return;
                      }
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

  void _showAnnouncementSheet(BuildContext context) {
    final titleController   = TextEditingController();
    final messageController = TextEditingController();
    final firestoreService  = FirestoreService();

    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
    );
    final focusedBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Color(0xFF2563EB)),
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) {
        bool isSending = false;

        return StatefulBuilder(
          builder: (sheetCtx, setSheetState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(sheetCtx).viewInsets.bottom + 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // Drag handle
                  Center(
                    child: Container(
                      width: 40, height: 4,
                      decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
                    ),
                  ),

                  const SizedBox(height: 16),

                  const Text(
                    'Send Announcement',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                  ),

                  const SizedBox(height: 16),

                  // Title field
                  TextField(
                    controller: titleController,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      labelText: 'Title',
                      labelStyle: const TextStyle(color: Color(0xFF64748B)),
                      floatingLabelStyle: const TextStyle(color: Color(0xFF2563EB)),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      border: inputBorder,
                      enabledBorder: inputBorder,
                      focusedBorder: focusedBorder,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Message field
                  TextField(
                    controller: messageController,
                    maxLines: 3,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      labelText: 'Message',
                      labelStyle: const TextStyle(color: Color(0xFF64748B)),
                      floatingLabelStyle: const TextStyle(color: Color(0xFF2563EB)),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      border: inputBorder,
                      enabledBorder: inputBorder,
                      focusedBorder: focusedBorder,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Send button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: isSending
                          ? null
                          : () async {
                              final title   = titleController.text.trim();
                              final message = messageController.text.trim();

                              if (title.isEmpty || message.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Please fill in both title and message.'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }

                              setSheetState(() => isSending = true);

                              try {
                                final ownersSnap = await FirebaseFirestore.instance
                                    .collection('users')
                                    .where('role', isEqualTo: 'owner')
                                    .get();
                                final walkersSnap = await FirebaseFirestore.instance
                                    .collection('users')
                                    .where('role', isEqualTo: 'walker')
                                    .get();

                                final allDocs = [...ownersSnap.docs, ...walkersSnap.docs];

                                for (final doc in allDocs) {
                                  await firestoreService.sendNotification(
                                    receiverID: doc.id,
                                    title: title,
                                    message: message,
                                    type: 'announcement',
                                  );
                                }

                                if (sheetCtx.mounted) Navigator.pop(sheetCtx);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Announcement sent to all users!'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                }
                              } catch (e) {
                                setSheetState(() => isSending = false);
                                if (sheetCtx.mounted) {
                                  ScaffoldMessenger.of(sheetCtx).showSnackBar(
                                    SnackBar(
                                      content: Text('Failed to send: $e'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: isSending
                          ? const SizedBox(
                              width: 22, height: 22,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                            )
                          : const Text('Send', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    ),
                  ),

                ],
              ),
            );
          },
        );
      },
    );
  }
}
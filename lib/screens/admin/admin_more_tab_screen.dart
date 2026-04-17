import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

// ─────────────────────────────────────────────────────────
// ADMIN MORE TAB
// Admin profile card, quick actions, logout
// ─────────────────────────────────────────────────────────

class AdminMoreTab extends StatelessWidget {

  // Logout callback from parent
  final VoidCallback onLogout;
  const AdminMoreTab({required this.onLogout});

  @override
  Widget build(BuildContext context) {

    //Get current admin user email
    final user = FirebaseAuth.instance.currentUser;

    final List<Map<String, dynamic>> _menuItems = [
      {'label': 'Send Announcement', 'icon': Icons.campaign_outlined,  'color': Color(0xFFF97316)},
      {'label': 'Platform Settings', 'icon': Icons.settings_outlined,   'color': Color(0xFF3B82F6)},
      {'label': 'View Reports',      'icon': Icons.bar_chart_outlined,  'color': Color(0xFF8B5CF6)},
      {'label': 'Help & Support',    'icon': Icons.help_outline,        'color': Color(0xFF10B981)},
    ];

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            SizedBox(height: 24),

            Text('More', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF7C2D12))),
            SizedBox(height: 20),

            //Admin profile card
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6, offset: Offset(0, 2))],
              ),
              child: Row(
                children: [
                  Container(
                    width: 52, height: 52,
                    decoration: BoxDecoration(color: Color(0xFFF97316), borderRadius: BorderRadius.circular(14)),
                    child: Icon(Icons.admin_panel_settings, color: Colors.white, size: 28),
                  ),
                  SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Administrator', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1C1917))),
                      Text(user?.email ?? 'admin@pawwalk.com', style: TextStyle(fontSize: 12, color: Color(0xFF78716C))),
                      SizedBox(height: 4),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(color: Color(0xFFF97316).withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                        child: Text('Admin', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFFEA580C))),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 24),

            Text('Quick Actions', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF7C2D12))),
            SizedBox(height: 12),

            //Menu items list
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6, offset: Offset(0, 2))],
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: _menuItems.length,
                separatorBuilder: (context, index) => Divider(height: 1, color: Color(0xFFF5F5F4)),
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
                    title: Text(item['label'] as String, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF1C1917))),
                    trailing: Icon(Icons.chevron_right, color: Color(0xFF78716C), size: 20),
                    onTap: () {
                      // TODO: implement each action
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${item['label']} coming soon')),
                      );
                    },
                  );
                },
              ),
            ),

            SizedBox(height: 24),

            //Signout button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: onLogout,
                icon: Icon(Icons.logout, size: 18),
                label: Text('Sign Out', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF7C2D12),
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
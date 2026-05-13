import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// ─────────────────────────────────────────────────────────
// ADMIN HOME TAB
// Grid stats and recent activity feed
// ─────────────────────────────────────────────────────────

class AdminHomeTab extends StatelessWidget {

  // Fetch total users from Firestore excluding admin accounts
  Future<int> _getTotalUsers() async {
    final snap = await FirebaseFirestore.instance
        .collection('users')
        .where('role', isNotEqualTo: 'admin')
        .get();
    return snap.docs.length;
  }

  // Fetch count of walkers waiting for approval
  Future<int> _getPendingApprovals() async {
    final snap = await FirebaseFirestore.instance
        .collection('users')
        .where('status', isEqualTo: 'pending')
        .get();
    return snap.docs.length;
  }

  //Dummy recent activity — swap with real Firestore values later
  final List<Map<String, dynamic>> _activity = [
    {'message': 'New walker registered: John Pasiolan',  'time': '2 min ago',   'icon': Icons.person_add,   'color': Color(0xFF10B981)},
    {'message': 'Booking completed: Sarah & Mike',       'time': '15 min ago',  'icon': Icons.check_circle, 'color': Color(0xFF3B82F6)},
    {'message': 'Dispute reported by Daniel',            'time': '1 hour ago',  'icon': Icons.report,       'color': Color(0xFFEF4444)},
    {'message': 'Walker approved: Jodel Santos',         'time': '2 hours ago', 'icon': Icons.verified,     'color': Color(0xFF2563EB)},
    {'message': 'New owner registered: Emily Chen',      'time': '3 hours ago', 'icon': Icons.person_add,   'color': Color(0xFF10B981)},
  ];

  AdminHomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            SizedBox(height: 24),

            //Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Admin Dashboard', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF1E293B))),
                    Text('Platform overview', style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                  ],
                ),
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(color: Color(0xFF2563EB), borderRadius: BorderRadius.circular(12)),
                  child: Icon(Icons.pets, color: Colors.white, size: 24),
                ),
              ],
            ),

            SizedBox(height: 28),

            //Stat cards
            Text('Platform Stats', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1E293B))),
            SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: [

                // Total Users — real Firestore count
                _buildCard(
                  label: 'Total Users',
                  icon: Icons.people,
                  color: Color(0xFF2563EB),
                  valueWidget: FutureBuilder<int>(
                    future: _getTotalUsers(),
                    builder: (context, snapshot) => Text(
                      snapshot.hasData ? '${snapshot.data}' : '...',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF1E293B)),
                    ),
                  ),
                ),

                // Active Walks — dummy until walks collection is built
                _buildCard(
                  label: 'Active Walks',
                  icon: Icons.directions_walk,
                  color: Color(0xFF10B981),
                  valueWidget: Text('8', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF1E293B))),
                ),

                // Total Bookings — dummy until bookings collection is built
                _buildCard(
                  label: 'Total Bookings',
                  icon: Icons.book,
                  color: Color(0xFF3B82F6),
                  valueWidget: Text('340', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF1E293B))),
                ),

                // Pending Approvals — real Firestore count
                _buildCard(
                  label: 'Pending Approvals',
                  icon: Icons.pending_actions,
                  color: Color(0xFFEF4444),
                  valueWidget: FutureBuilder<int>(
                    future: _getPendingApprovals(),
                    builder: (context, snapshot) => Text(
                      snapshot.hasData ? '${snapshot.data}' : '...',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF1E293B)),
                    ),
                  ),
                ),

              ],
            ),

            SizedBox(height: 28),

            //Recent activity
            Text('Recent Activity', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1E293B))),
            SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: Offset(0, 2))],
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: _activity.length,
                separatorBuilder: (context, index) => Divider(height: 1, color: Color(0xFFF5F5F4)),
                itemBuilder: (context, index) {
                  final item = _activity[index];
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Row(
                      children: [
                        Container(
                          width: 36, height: 36,
                          decoration: BoxDecoration(
                            color: (item['color'] as Color).withOpacity(0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(item['icon'] as IconData, color: item['color'] as Color, size: 18),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item['message'] as String, style: TextStyle(fontSize: 13, color: Color(0xFF1E293B), fontWeight: FontWeight.w500)),
                              SizedBox(height: 2),
                              Text(item['time'] as String, style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // Reusable stat card — accepts any widget for the value so FutureBuilder or plain Text both work
  Widget _buildCard({required String label, required IconData icon, required Color color, required Widget valueWidget}) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              valueWidget,
              Text(label, style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
            ],
          ),
        ],
      ),
    );
  }
}
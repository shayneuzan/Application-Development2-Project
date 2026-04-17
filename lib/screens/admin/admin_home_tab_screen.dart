import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────
// ADMIN HOME TAB
// Grid stats and recent activity feed
// ─────────────────────────────────────────────────────────

class AdminHomeTab extends StatelessWidget {

  //Dummy stats swap values with real Firestore values later
  final List<Map<String, dynamic>> _stats = [
    {'label': 'Total Users',       'value': '124', 'icon': Icons.people,           'color': Color(0xFFF97316),},
    {'label': 'Active Walks',      'value': '8',   'icon': Icons.directions_walk,  'color': Color(0xFF10B981)},
    {'label': 'Total Bookings',    'value': '340', 'icon': Icons.book,             'color': Color(0xFF3B82F6)},
    {'label': 'Pending Approvals', 'value': '5',   'icon': Icons.pending_actions,  'color': Color(0xFFEF4444)},
  ];

  //Dummy recent activity swap with real Firestore values later
  final List<Map<String, dynamic>> _activity = [
    {'message': 'New walker registered: John Pasiolan',  'time': '2 min ago',   'icon': Icons.person_add,   'color': Color(0xFF10B981)},
    {'message': 'Booking completed: Sarah & Mike',       'time': '15 min ago',  'icon': Icons.check_circle, 'color': Color(0xFF3B82F6)},
    {'message': 'Dispute reported by Daniel',            'time': '1 hour ago',  'icon': Icons.report,       'color': Color(0xFFEF4444)},
    {'message': 'Walker approved: Jodel Santos',         'time': '2 hours ago', 'icon': Icons.verified,     'color': Color(0xFFF97316)},
    {'message': 'New owner registered: Emily Chen',      'time': '3 hours ago', 'icon': Icons.person_add,   'color': Color(0xFF10B981)},
  ];

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
                    Text('Admin Dashboard', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF7C2D12))),
                    Text('Platform overview', style: TextStyle(fontSize: 13, color: Color(0xFF78716C))),
                  ],
                ),
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(color: Color(0xFFF97316), borderRadius: BorderRadius.circular(12)),
                  child: Icon(Icons.pets, color: Colors.white, size: 24),
                ),
              ],
            ),

            SizedBox(height: 28),

            //Stat cards
            Text('Platform Stats', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF7C2D12))),
            SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.5,
              ),
              itemCount: _stats.length,
              itemBuilder: (context, index) {
                final stat = _stats[index];
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
                          color: (stat['color'] as Color).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(stat['icon'] as IconData, color: stat['color'] as Color, size: 20),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(stat['value'] as String, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF1C1917))),
                          Text(stat['label'] as String, style: TextStyle(fontSize: 11, color: Color(0xFF78716C))),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),

            SizedBox(height: 28),

            //Recent activity
            Text('Recent Activity', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF7C2D12))),
            SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: Offset(0, 2))],
              ),
              child: ListView.separated(
                shrinkWrap: true, //only take the space you actually need instead of filling the whole screen
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
                              Text(item['message'] as String, style: TextStyle(fontSize: 13, color: Color(0xFF1C1917), fontWeight: FontWeight.w500)),
                              SizedBox(height: 2),
                              Text(item['time'] as String, style: TextStyle(fontSize: 11, color: Color(0xFF78716C))),
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
}
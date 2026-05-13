import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// ─────────────────────────────────────────────────────────
// ADMIN USERS TAB
// List of all users with search, approve, suspend actions
// ─────────────────────────────────────────────────────────

class AdminUsersTab extends StatefulWidget {
  const AdminUsersTab({super.key});

  @override
  State<AdminUsersTab> createState() => _AdminUsersTabState();
}

class _AdminUsersTabState extends State<AdminUsersTab> {

  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      // Wrap everything in a StreamBuilder so the list updates live
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').where('role', isNotEqualTo: 'admin').snapshots(),
        builder: (context, snapshot) {

          // Convert Firestore docs to maps and include the uid from the doc id
          final allUsers = snapshot.hasData
              ? snapshot.data!.docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return {...data, 'uid': doc.id};
                }).toList()
              : <Map<String, dynamic>>[];

          // Filter based on search query
          final filtered = allUsers.where((u) {
            return (u['name'] ?? 'No name').toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
                (u['email'] ?? 'No email').toString().toLowerCase().contains(_searchQuery.toLowerCase());
          }).toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // Header
              Padding(
                padding: EdgeInsets.fromLTRB(20, 24, 20, 4),
                child: Text('User Management', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF1E293B))),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: Text('${allUsers.length} total users', style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
              ),

              // Search bar
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  onChanged: (value) => setState(() => _searchQuery = value),
                  decoration: InputDecoration(
                    hintText: 'Search by name or email...',
                    hintStyle: TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
                    prefixIcon: Icon(Icons.search, color: Color(0xFF64748B), size: 20),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Color(0xFFE2E8F0))),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Color(0xFF2563EB), width: 1.5)),
                  ),
                ),
              ),

              SizedBox(height: 16),

              // Show spinner while waiting for Firestore to respond
              if (snapshot.connectionState == ConnectionState.waiting)
                Expanded(child: Center(child: CircularProgressIndicator(color: Color(0xFF2563EB))))

              // Show message if no users match the search
              else if (filtered.isEmpty)
                Expanded(child: Center(child: Text('No users found.', style: TextStyle(color: Color(0xFF64748B)))))

              // User list
              else
                Expanded(
                  child: ListView.separated(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    itemCount: filtered.length,
                    separatorBuilder: (context, index) => SizedBox(height: 10),
                    itemBuilder: (context, index) => _UserCard(user: filtered[index]),
                  ),
                ),

              SizedBox(height: 16),
            ],
          );
        },
      ),
    );
  }
}

// ── User card ──────────────────────────────────────────
class _UserCard extends StatelessWidget {
  final Map<String, dynamic> user;

  const _UserCard({required this.user});

  @override
  Widget build(BuildContext context) {

    //Pick status badge color
    Color statusColor;
    switch (user['status'] ?? 'active') {
      case 'active':    statusColor = Color(0xFF10B981); break;
      case 'pending':   statusColor = Color(0xFFF59E0B); break;
      case 'suspended': statusColor = Color(0xFFEF4444); break;
      default:          statusColor = Color(0xFF64748B);
    }

    return Container(
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6, offset: Offset(0, 2))],
      ),
      child: Row(
        children: [

          //Initials avatar
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(color: Color(0xFF2563EB).withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
            child: Center(
              child: Text(
                (user['name'] ?? 'No name').toString().split(' ').map((n) => n[0]).take(2).join(),
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF2563EB)),
              ),
            ),
          ),

          SizedBox(width: 12),

          //Name, email, badges
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user['name'] ?? 'No name', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1E293B))),
                SizedBox(height: 2),
                Text(user['email'] ?? 'No email', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                SizedBox(height: 6),
                Row(
                  children: [
                    _Badge(
                      label: (user['role'] ?? 'owner') == 'walker' ? 'Walker' : 'Owner',
                      color: (user['role'] ?? 'owner') == 'walker' ? Color(0xFF3B82F6) : Color(0xFF10B981),
                    ),
                    SizedBox(width: 6),
                    _Badge(
                      label: (user['status'] ?? 'active').toString()[0].toUpperCase() + (user['status'] ?? 'active').toString().substring(1),
                      color: statusColor,
                    ),
                  ],
                ),
              ],
            ),
          ),

          //Action button for each user
          _ActionButton(user: user),
        ],
      ),
    );
  }
}

//Small badge widget
class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
      child: Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color)),
    );
  }
}

//Action button, different button depending on the user's current status.
class _ActionButton extends StatelessWidget {
  final Map<String, dynamic> user;

  const _ActionButton({required this.user});

  // Shortcut to the user's Firestore document
  DocumentReference get _ref =>
      FirebaseFirestore.instance.collection('users').doc(user['uid']);

  @override
  Widget build(BuildContext context) {

    //Pending walker — Approve
    if ((user['role'] ?? 'owner') == 'walker' && (user['status'] ?? 'active') == 'pending') {
      return ElevatedButton(
        onPressed: () async {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${user['name'] ?? 'No name'} approved!'), backgroundColor: Color(0xFF10B981)),
          );
          await _ref.update({'isApproved': true, 'status': 'active'});
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF10B981), foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), elevation: 0,
        ),
        child: Text('Approve', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
      );
    }

    //Active — Suspend
    if ((user['status'] ?? 'active') == 'active') {
      return OutlinedButton(
        onPressed: () async {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${user['name'] ?? 'No name'} suspended.'), backgroundColor: Color(0xFFEF4444)),
          );
          await _ref.update({'status': 'suspended'});
        },
        style: OutlinedButton.styleFrom(
          foregroundColor: Color(0xFFEF4444), side: BorderSide(color: Color(0xFFEF4444)),
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text('Suspend', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
      );
    }

    //Suspended — Restore
    if ((user['status'] ?? 'active') == 'suspended') {
      return OutlinedButton(
        onPressed: () async {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${user['name'] ?? 'No name'} restored.'), backgroundColor: Color(0xFF10B981)),
          );
          await _ref.update({'status': 'active'});
        },
        style: OutlinedButton.styleFrom(
          foregroundColor: Color(0xFF10B981), side: BorderSide(color: Color(0xFF10B981)),
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text('Restore', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
      );
    }

    //Safety fallback — show nothing if status doesn't match any known case
    return SizedBox();
  }
}
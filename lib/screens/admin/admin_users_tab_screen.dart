import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────
// ADMIN USERS TAB
// List of all users with search, approve, suspend actions
// ─────────────────────────────────────────────────────────

class AdminUsersTab extends StatefulWidget {
  @override
  State<AdminUsersTab> createState() => _AdminUsersTabState();
}

class _AdminUsersTabState extends State<AdminUsersTab> {

  String _searchQuery = '';

  //Dummy users, replace with real Firestore values later
  //Structure matches what register_screen.dart saves to Firestore
  final List<Map<String, dynamic>> _users = [
    {'name': 'Shayne Uzan',     'email': 'shayne@gmail.com',  'role': 'owner',  'status': 'active',    'isApproved': true},
    {'name': 'Jodel Santos',    'email': 'jodel@gmail.com',   'role': 'walker', 'status': 'active',    'isApproved': true},
    {'name': 'John Pasiolan',   'email': 'john@gmail.com',    'role': 'walker', 'status': 'pending',   'isApproved': false},
    {'name': 'Emily Chen',      'email': 'emily@gmail.com',   'role': 'owner',  'status': 'active',    'isApproved': true},
    {'name': 'Daniel Tremblay', 'email': 'daniel@gmail.com',  'role': 'walker', 'status': 'suspended', 'isApproved': false},
    {'name': 'Sarah Leblanc',   'email': 'sarah@gmail.com',   'role': 'owner',  'status': 'active',    'isApproved': true},
  ];

  @override
  Widget build(BuildContext context) {

    //Filter based on search
    final filtered = _users.where((u) {
      return u['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          u['email'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // Header
          Padding(
            padding: EdgeInsets.fromLTRB(20, 24, 20, 4),
            child: Text('User Management', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF7C2D12))),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: Text('${_users.length} total users', style: TextStyle(fontSize: 13, color: Color(0xFF78716C))),
          ),

          // Search bar
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: 'Search by name or email...',
                hintStyle: TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
                prefixIcon: Icon(Icons.search, color: Color(0xFF78716C), size: 20),
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Color(0xFFE7E5E4))), //grey border when not tapped
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Color(0xFFF97316), width: 1.5)), //orange when tapped
              ),
            ),
          ),

          SizedBox(height: 16),

          //User list
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
    switch (user['status']) {
      case 'active':    statusColor = Color(0xFF10B981); break;
      case 'pending':   statusColor = Color(0xFFF59E0B); break;
      case 'suspended': statusColor = Color(0xFFEF4444); break;
      default:          statusColor = Color(0xFF78716C);
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
            decoration: BoxDecoration(color: Color(0xFFF97316).withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
            child: Center(
              child: Text(
                user['name'].toString().split(' ').map((n) => n[0]).take(2).join(), //take the first the initial of the first and last name and join the 2
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFFEA580C)),
              ),
            ),
          ),

          SizedBox(width: 12),

          //Name, email, badges
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user['name'], style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1C1917))),
                SizedBox(height: 2),
                Text(user['email'], style: TextStyle(fontSize: 11, color: Color(0xFF78716C))),
                SizedBox(height: 6),
                Row(
                  children: [
                    _Badge(
                      label: user['role'] == 'walker' ? 'Walker' : 'Owner',
                      color: user['role'] == 'walker' ? Color(0xFF3B82F6) : Color(0xFF10B981), //blue or walker, green for owner
                    ),
                    SizedBox(width: 6),
                    _Badge(
                      label: user['status'].toString()[0].toUpperCase() + user['status'].toString().substring(1), //3 types of status. capitalize the first letter(cleaner)
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

  @override
  Widget build(BuildContext context) {

    //Pending walker —> Approve
    if (user['role'] == 'walker' && user['status'] == 'pending') {
      return ElevatedButton(
        onPressed: () {
          // TODO: FirebaseFirestore.instance.collection('users')
          //   .doc(user['uid']).update({'isApproved': true, 'status': 'active'})
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${user['name']} approved!'), backgroundColor: Color(0xFF10B981)),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF10B981), foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), elevation: 0,
        ),
        child: Text('Approve', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
      );
    }

    //Active —> Suspend
    if (user['status'] == 'active') {
      return OutlinedButton(
        onPressed: () {
          // TODO: FirebaseFirestore.instance.collection('users')
          //   .doc(user['uid']).update({'status': 'suspended'})
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${user['name']} suspended.'), backgroundColor: Color(0xFFEF4444)),
          );
        },
        style: OutlinedButton.styleFrom(
          foregroundColor: Color(0xFFEF4444), side: BorderSide(color: Color(0xFFEF4444)),
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text('Suspend', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
      );
    }

    //Suspended —> Restore
    if (user['status'] == 'suspended') {
      return OutlinedButton(
        onPressed: () {
          // TODO: FirebaseFirestore.instance.collection('users')
          //   .doc(user['uid']).update({'status': 'active'})
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${user['name']} restored.'), backgroundColor: Color(0xFF10B981)),
          );
        },
        style: OutlinedButton.styleFrom(
          foregroundColor: Color(0xFF10B981), side: BorderSide(color: Color(0xFF10B981)),
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text('Restore', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
      );
    }

    //safety fallback, if somehow a user has a status that does not match any of the conditions above,
    //instead of crashing the app it just shows nothing
    return SizedBox();


  }
}
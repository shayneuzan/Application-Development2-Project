import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../l10n/generated/app_localizations.dart';

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
    final loc = AppLocalizations.of(context)!;
    Color textPrimary = Theme.of(context).colorScheme.onSurface;
    Color textMuted   = Theme.of(context).textTheme.bodySmall!.color!;
    Color cardColor   = Theme.of(context).cardColor;

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
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 4),
                child: Text(loc.userManagement, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: textPrimary)),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: Text('${allUsers.length} total users', style: TextStyle(fontSize: 13, color: textMuted)),
              ),

              // Search bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  onChanged: (value) => setState(() => _searchQuery = value),
                  style: TextStyle(color: textPrimary),
                  decoration: InputDecoration(
                    hintText: loc.searchByNameOrEmail,
                    hintStyle: TextStyle(color: textMuted, fontSize: 14),
                    prefixIcon: Icon(Icons.search, color: textMuted, size: 20),
                    filled: true,
                    fillColor: cardColor,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Theme.of(context).dividerColor)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Color(0xFF2563EB), width: 1.5)),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Show spinner while waiting for Firestore to respond
              if (snapshot.connectionState == ConnectionState.waiting)
                const Expanded(child: Center(child: CircularProgressIndicator(color: Color(0xFF2563EB))))

              // Show message if no users match the search
              else if (filtered.isEmpty)
                Expanded(child: Center(child: Text(loc.noUsersFound, style: TextStyle(color: textMuted))))

              // User list
              else
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: filtered.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 10),
                    itemBuilder: (context, index) => _UserCard(user: filtered[index]),
                  ),
                ),

              const SizedBox(height: 16),
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
    final loc = AppLocalizations.of(context)!;
    Color textPrimary = Theme.of(context).colorScheme.onSurface;
    Color textMuted   = Theme.of(context).textTheme.bodySmall!.color!;
    Color cardColor   = Theme.of(context).cardColor;

    //Pick status badge color
    Color statusColor;
    switch (user['status'] ?? 'active') {
      case 'active':    statusColor = const Color(0xFF10B981); break;
      case 'pending':   statusColor = const Color(0xFFF59E0B); break;
      case 'suspended': statusColor = const Color(0xFFEF4444); break;
      default:          statusColor = const Color(0xFF64748B);
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6, offset: Offset(0, 2))],
      ),
      child: Row(
        children: [

          //Initials avatar
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(color: const Color(0xFF2563EB).withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
            child: Center(
              child: Text(
                (user['name'] ?? 'No name').toString().split(' ').map((n) => n[0]).take(2).join(),
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF2563EB)),
              ),
            ),
          ),

          const SizedBox(width: 12),

          //Name, email, badges
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user['name'] ?? 'No name', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: textPrimary)),
                const SizedBox(height: 2),
                Text(user['email'] ?? 'No email', style: TextStyle(fontSize: 11, color: textMuted)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _Badge(
                      label: (user['role'] ?? 'owner') == 'walker' ? loc.walker : loc.owner,
                      color: (user['role'] ?? 'owner') == 'walker' ? const Color(0xFF3B82F6) : const Color(0xFF10B981),
                    ),
                    const SizedBox(width: 6),
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
          backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), elevation: 0,
        ),
        child: Text(AppLocalizations.of(context)!.approve, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
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
          foregroundColor: const Color(0xFFEF4444), side: const BorderSide(color: Color(0xFFEF4444)),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(AppLocalizations.of(context)!.suspend, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
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
          foregroundColor: const Color(0xFF10B981), side: const BorderSide(color: Color(0xFF10B981)),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(AppLocalizations.of(context)!.restore, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
      );
    }

    //Safety fallback — show nothing if status doesn't match any known case
    return SizedBox();
  }
}

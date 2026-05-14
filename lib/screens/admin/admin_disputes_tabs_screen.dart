import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────
// ADMIN DISPUTES TAB
// Open and resolved disputes with resolve/dismiss actions
// ─────────────────────────────────────────────────────────

class AdminDisputesTab extends StatelessWidget {

  // Dummy disputes, replace with real Firestore values later
  final List<Map<String, dynamic>> _disputes = [
    {'reportedBy': 'Shayne Uzan',   'against': 'Jodel Santos',  'reason': 'Walker was late by 30 minutes',   'date': 'Apr 9, 2026',  'status': 'open'},
    {'reportedBy': 'Emily Chen',    'against': 'John Pasiolan', 'reason': 'Dog returned home wet and muddy',  'date': 'Apr 8, 2026',  'status': 'open'},
    {'reportedBy': 'Sarah Leblanc', 'against': 'Jodel Santos',  'reason': 'Walker cancelled last minute',     'date': 'Apr 5, 2026',  'status': 'resolved'},
  ];

  @override
  Widget build(BuildContext context) {

    Color textPrimary = Theme.of(context).colorScheme.onSurface;
    Color textMuted   = Theme.of(context).textTheme.bodySmall!.color!;

    final open     = _disputes.where((d) => d['status'] == 'open').toList();
    final resolved = _disputes.where((d) => d['status'] == 'resolved').toList();

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            SizedBox(height: 24),

            // Header
            Text('Dispute Resolution', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: textPrimary)),
            Text('${open.length} open disputes', style: TextStyle(fontSize: 13, color: textMuted)),

            SizedBox(height: 20),

            //Open disputes section
            if (open.isNotEmpty) ...[
              Text('Open', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFFEF4444))),
              SizedBox(height: 10),
              ...open.map((d) => Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: _DisputeCard(dispute: d),
              )),
              SizedBox(height: 16),
            ],

            // Resolved disputes section
            if (resolved.isNotEmpty) ...[
              Text('Resolved', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF10B981))),
              SizedBox(height: 10),
              ...resolved.map((d) => Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: _DisputeCard(dispute: d),
              )),
            ],

            SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// ── Dispute card ───────────────────────────────────────
class _DisputeCard extends StatelessWidget {
  final Map<String, dynamic> dispute;
  const _DisputeCard({required this.dispute});

  @override
  Widget build(BuildContext context) {

    Color textPrimary  = Theme.of(context).colorScheme.onSurface;
    Color textMuted    = Theme.of(context).textTheme.bodySmall!.color!;
    Color cardColor    = Theme.of(context).cardColor;
    // Slightly tinted surface for the reason box — one step darker than card
    Color reasonBg     = Theme.of(context).colorScheme.surface;

    final isOpen = dispute['status'] == 'open';

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        border: isOpen ? Border.all(color: Color(0xFFEF4444).withOpacity(0.3)) : null,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          //Who reported who
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(fontSize: 13, color: textPrimary),
                    children: [
                      TextSpan(text: dispute['reportedBy'], style: TextStyle(fontWeight: FontWeight.w700)),
                      TextSpan(text: ' reported '),
                      TextSpan(text: dispute['against'], style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF2563EB))),
                    ],
                  ),
                ),
              ),
              Text(dispute['date'], style: TextStyle(fontSize: 11, color: textMuted)),
            ],
          ),

          SizedBox(height: 8),

          //Reason text in a tinted box
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(color: reasonBg, borderRadius: BorderRadius.circular(8)),
            child: Text(
              dispute['reason'],
              style: TextStyle(fontSize: 12, color: textMuted, fontStyle: FontStyle.italic),
            ),
          ),

          //Action buttons only on open disputes
          if (isOpen) ...[
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: FirebaseFirestore.instance.collection('disputes')
                      //   .doc(dispute['id']).update({'status': 'resolved'})
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Dispute resolved.'), backgroundColor: Color(0xFF10B981)),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF10B981), foregroundColor: Colors.white,
                      elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text('Resolve', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      // TODO: FirebaseFirestore.instance.collection('disputes')
                      //   .doc(dispute['id']).update({'status': 'dismissed'})
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Dispute dismissed.'), backgroundColor: Color(0xFF64748B)),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: textMuted,
                      side: BorderSide(color: Theme.of(context).dividerColor),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text('Dismiss', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

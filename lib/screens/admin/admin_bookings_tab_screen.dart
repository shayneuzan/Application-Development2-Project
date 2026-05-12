import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────
// ADMIN BOOKINGS TAB
// List of all bookings with status cards at top
// ─────────────────────────────────────────────────────────

class AdminBookingsTab extends StatelessWidget {

  //Dummy bookings, replace with real Firestore values later
  // Structure matches what booking_screen.dart will save to Firestore
  final List<Map<String, dynamic>> _bookings = [
    {'id': 'b1', 'owner': 'John Smith',  'walker': 'Sarah Johnson', 'date': '2026-03-25', 'time': '10:00', 'duration': '60 min', 'price': '\$25', 'status': 'confirmed'},
    {'id': 'b2', 'owner': 'John Smith',  'walker': 'Mike Chen',     'date': '2026-03-20', 'time': '14:00', 'duration': '30 min', 'price': '\$15', 'status': 'completed'},
    {'id': 'b3', 'owner': 'Emily Chen',  'walker': 'Jodel Santos',  'date': '2026-04-01', 'time': '09:00', 'duration': '45 min', 'price': '\$20', 'status': 'pending'},
  ];

  @override
  Widget build(BuildContext context) {

    //Count bookings per status
    final total     = _bookings.length;
    final pending   = _bookings.where((b) => b['status'] == 'pending').length;
    final confirmed = _bookings.where((b) => b['status'] == 'confirmed').length;
    final completed = _bookings.where((b) => b['status'] == 'completed').length;

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          //Header
          Padding(
            padding: EdgeInsets.fromLTRB(20, 24, 20, 4),
            child: Text('Booking Management', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF1E293B))),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  //Status summary cards
                  Row(
                    children: [
                      _StatCard(label: 'Total', value: total.toString(), color: Color(0xFF1E293B)),
                      SizedBox(width: 10),
                      _StatCard(label: 'Pending', value: pending.toString(), color: Color(0xFFF59E0B)),
                      SizedBox(width: 10),
                      _StatCard(label: 'Confirmed', value: confirmed.toString(), color: Color(0xFF2563EB)),
                      SizedBox(width: 10),
                      _StatCard(label: 'Completed', value: completed.toString(), color: Color(0xFF10B981)),
                    ],
                  ),

                  SizedBox(height: 20),

                  // Booking cards list
                  ListView.separated(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: _bookings.length,
                    separatorBuilder: (context, index) => SizedBox(height: 12),
                    itemBuilder: (context, index) => _BookingCard(booking: _bookings[index]),
                  ),

                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Small stat card at top ─────────────────────────────
class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatCard({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: color)),
            SizedBox(height: 2),
            Text(label, style: TextStyle(fontSize: 10, color: Color(0xFF64748B))),
          ],
        ),
      ),
    );
  }
}

//Booking card
class _BookingCard extends StatelessWidget {
  final Map<String, dynamic> booking;
  const _BookingCard({required this.booking});

  @override
  Widget build(BuildContext context) {

    //Status badge color
    Color statusColor;
    switch (booking['status']) {
      case 'completed':  statusColor = Color(0xFF10B981); break; //green
      case 'confirmed':  statusColor = Color(0xFF2563EB); break; //orange
      case 'pending':    statusColor = Color(0xFFF59E0B); break; //yellow
      case 'active':     statusColor = Color(0xFF3B82F6); break; //blue
      default:           statusColor = Color(0xFF64748B); //grey
    }

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          //Status badge and price row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  booking['status'].toString()[0].toUpperCase() + booking['status'].toString().substring(1),
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: statusColor),
                ),
              ),
              Text(
                booking['price'],
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF2563EB)),
              ),
            ],
          ),

          SizedBox(height: 12),

          //Booking ID
          Text('ID: ${booking['id']}', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),

          SizedBox(height: 10),

          //Owner row
          Row(
            children: [
              Icon(Icons.person_outline, size: 16, color: Color(0xFF64748B)),
              SizedBox(width: 6),
              Text('Owner: ${booking['owner']}', style: TextStyle(fontSize: 13, color: Color(0xFF1E293B))),
            ],
          ),

          SizedBox(height: 6),

          //Walker row
          Row(
            children: [
              Icon(Icons.directions_walk, size: 16, color: Color(0xFF64748B)),
              SizedBox(width: 6),
              Text('Walker: ${booking['walker']}', style: TextStyle(fontSize: 13, color: Color(0xFF1E293B))),
            ],
          ),

          SizedBox(height: 10),

          //Date, time, duration row
          Row(
            children: [
              Icon(Icons.calendar_today_outlined, size: 14, color: Color(0xFF64748B)),
              SizedBox(width: 4),
              Text(booking['date'], style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
              SizedBox(width: 12),
              Icon(Icons.access_time, size: 14, color: Color(0xFF64748B)),
              SizedBox(width: 4),
              Text(booking['time'], style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
              SizedBox(width: 6),
              Text(booking['duration'], style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
            ],
          ),

          SizedBox(height: 12),

          //View details button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                // TODO: show booking detail bottom popup
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Booking ${booking['id']} details coming soon')),
                );
              },
              icon: Icon(Icons.remove_red_eye_outlined, size: 16),
              label: Text('View Details', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              style: OutlinedButton.styleFrom(
                foregroundColor: Color(0xFF2563EB),
                side: BorderSide(color: Color(0xFFE2E8F0)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),

        ],
      ),
    );
  }
}
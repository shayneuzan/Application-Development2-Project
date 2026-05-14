import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/booking_model.dart';

// ─────────────────────────────────────────────────────────
// ADMIN BOOKINGS TAB
// List of all bookings with status cards at top
// ─────────────────────────────────────────────────────────

class AdminBookingsTab extends StatefulWidget {
  const AdminBookingsTab({super.key});

  @override
  State<AdminBookingsTab> createState() => _AdminBookingsTabState();
}

class _AdminBookingsTabState extends State<AdminBookingsTab> {
  final Stream<QuerySnapshot> _stream =
      FirebaseFirestore.instance.collection('requests').snapshots();

  @override
  Widget build(BuildContext context) {
    Color textPrimary = Theme.of(context).colorScheme.onSurface;

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          //Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 4),
            child: Text('Booking Management', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: textPrimary)),
          ),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _stream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFF2563EB)));
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error loading bookings: ${snapshot.error}'));
                }

                final bookings = (snapshot.data?.docs ?? [])
                    .map((doc) {
                      try {
                        return BookingModel.fromFirestore(doc);
                      } catch (_) {
                        return null;
                      }
                    })
                    .whereType<BookingModel>()
                    .toList();

                //Count bookings per status
                final total     = bookings.length;
                final pending   = bookings.where((b) => b.status == 'pending').length;
                final confirmed = bookings.where((b) => b.status == 'accepted' || b.status == 'confirmed').length;
                final completed = bookings.where((b) => b.status == 'completed').length;

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      //Status summary cards
                      Row(
                        children: [
                          _StatCard(label: 'Total',     value: total.toString(),     color: Theme.of(context).colorScheme.onSurface),
                          const SizedBox(width: 10),
                          _StatCard(label: 'Pending',   value: pending.toString(),   color: const Color(0xFFF59E0B)),
                          const SizedBox(width: 10),
                          _StatCard(label: 'Confirmed', value: confirmed.toString(), color: const Color(0xFF2563EB)),
                          const SizedBox(width: 10),
                          _StatCard(label: 'Completed', value: completed.toString(), color: const Color(0xFF10B981)),
                        ],
                      ),

                      const SizedBox(height: 20),

                      if (bookings.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 40),
                            child: Text(
                              'No bookings yet.',
                              style: TextStyle(color: Theme.of(context).textTheme.bodySmall!.color, fontStyle: FontStyle.italic),
                            ),
                          ),
                        )
                      else
                        // Booking cards list
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: bookings.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 12),
                          itemBuilder: (context, index) => _BookingCard(booking: bookings[index]),
                        ),

                    ],
                  ),
                );
              },
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
    Color textMuted = Theme.of(context).textTheme.bodySmall!.color!;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: color)),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(fontSize: 10, color: textMuted)),
          ],
        ),
      ),
    );
  }
}

// ── Booking card ───────────────────────────────────────
class _BookingCard extends StatelessWidget {
  final BookingModel booking;
  const _BookingCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    Color textPrimary = Theme.of(context).colorScheme.onSurface;
    Color textMuted   = Theme.of(context).textTheme.bodySmall!.color!;
    Color cardColor   = Theme.of(context).cardColor;

    //Status badge color
    Color statusColor;
    switch (booking.status) {
      case 'completed':  statusColor = const Color(0xFF10B981); break;
      case 'accepted':
      case 'confirmed':  statusColor = const Color(0xFF2563EB); break;
      case 'pending':    statusColor = const Color(0xFFF59E0B); break;
      case 'declined':   statusColor = const Color(0xFFEF4444); break;
      case 'active':     statusColor = const Color(0xFF3B82F6); break;
      default:           statusColor = const Color(0xFF64748B);
    }

    final statusLabel = booking.status.isNotEmpty
        ? booking.status[0].toUpperCase() + booking.status.substring(1)
        : '';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          //Status badge and price row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: statusColor),
                ),
              ),
              Text(
                '\$${booking.totalPrice.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF2563EB)),
              ),
            ],
          ),

          const SizedBox(height: 12),

          //Owner row
          Row(
            children: [
              Icon(Icons.person_outline, size: 16, color: textMuted),
              const SizedBox(width: 6),
              Text('Owner: ${booking.ownerName}', style: TextStyle(fontSize: 13, color: textPrimary)),
            ],
          ),

          const SizedBox(height: 6),

          //Walker row
          Row(
            children: [
              Icon(Icons.directions_walk, size: 16, color: textMuted),
              const SizedBox(width: 6),
              Text('Walker: ${booking.walkerName}', style: TextStyle(fontSize: 13, color: textPrimary)),
            ],
          ),

          const SizedBox(height: 10),

          //Date, time, duration row
          Row(
            children: [
              Icon(Icons.calendar_today_outlined, size: 14, color: textMuted),
              const SizedBox(width: 4),
              Text(DateFormat('yyyy-MM-dd').format(booking.date), style: TextStyle(fontSize: 12, color: textMuted)),
              const SizedBox(width: 12),
              Icon(Icons.access_time, size: 14, color: textMuted),
              const SizedBox(width: 4),
              Text(booking.time, style: TextStyle(fontSize: 12, color: textMuted)),
              const SizedBox(width: 6),
              Text('${booking.duration} min', style: TextStyle(fontSize: 12, color: textMuted)),
            ],
          ),

          const SizedBox(height: 12),

          //View details button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _showDetails(context),
              icon: const Icon(Icons.remove_red_eye_outlined, size: 16),
              label: const Text('View Details', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF2563EB),
                side: BorderSide(color: Theme.of(context).dividerColor),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),

        ],
      ),
    );
  }

  void _showDetails(BuildContext context) {
    final Color scaffoldBg = Theme.of(context).scaffoldBackgroundColor;
    final Color cardBg     = Theme.of(context).cardColor;
    final Color textPrimary = Theme.of(context).colorScheme.onSurface;

    Color statusColor;
    switch (booking.status) {
      case 'completed':  statusColor = const Color(0xFF10B981); break;
      case 'accepted':
      case 'confirmed':  statusColor = const Color(0xFF2563EB); break;
      case 'pending':    statusColor = const Color(0xFFF59E0B); break;
      case 'declined':   statusColor = const Color(0xFFEF4444); break;
      default:           statusColor = const Color(0xFF64748B);
    }

    final statusLabel = booking.status.isNotEmpty
        ? booking.status[0].toUpperCase() + booking.status.substring(1)
        : '';

    showModalBottomSheet(
      context: context,
      backgroundColor: scaffoldBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(ctx).viewInsets.bottom + 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            //Drag handle
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
              ),
            ),

            const SizedBox(height: 16),

            //Title + status badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Booking Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: textPrimary)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(statusLabel, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: statusColor)),
                ),
              ],
            ),

            const SizedBox(height: 4),

            Text('ID: ${booking.id}', style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),

            const SizedBox(height: 16),

            //Details list
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: [
                  _detailRow(context, Icons.person_outline,         'Owner',       booking.ownerName),
                  const Divider(height: 20),
                  _detailRow(context, Icons.directions_walk,        'Walker',      booking.walkerName),
                  const Divider(height: 20),
                  _detailRow(context, Icons.pets,                   'Pet',         booking.petName),
                  const Divider(height: 20),
                  _detailRow(context, Icons.calendar_today_outlined,'Date',        DateFormat('yyyy-MM-dd').format(booking.date)),
                  const Divider(height: 20),
                  _detailRow(context, Icons.access_time,            'Time',        booking.time),
                  const Divider(height: 20),
                  _detailRow(context, Icons.timer_outlined,         'Duration',    '${booking.duration} min'),
                  const Divider(height: 20),
                  _detailRow(context, Icons.attach_money,           'Total Price', '\$${booking.totalPrice.toStringAsFixed(2)}'),
                ],
              ),
            ),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(BuildContext context, IconData icon, String label, String value) {
    Color textPrimary = Theme.of(context).colorScheme.onSurface;
    Color textMuted   = Theme.of(context).textTheme.bodySmall!.color!;

    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF2563EB)),
        const SizedBox(width: 10),
        Text(label, style: TextStyle(fontSize: 13, color: textMuted, fontWeight: FontWeight.w500)),
        const Spacer(),
        Text(value, style: TextStyle(fontSize: 13, color: textPrimary, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
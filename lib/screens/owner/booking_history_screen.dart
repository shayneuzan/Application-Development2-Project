import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../widgets/owner_bottom_nav_bar.dart';
import '../widgets/walker_notification_icon.dart';
import 'browse_walkers_list_screen.dart';

import 'review_screen.dart';
import 'booking_screen.dart';
import '../../services/firestore_service.dart';
import '../widgets/owner_drawer.dart';
import '../../l10n/generated/app_localizations.dart';

class BookingHistoryScreen extends StatefulWidget {
  const BookingHistoryScreen({super.key});

  @override
  State<BookingHistoryScreen> createState() => _BookingHistoryScreenState();
}

class _BookingHistoryScreenState extends State<BookingHistoryScreen> {
  bool isUpcomingSelected = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final FirestoreService _firestoreService = FirestoreService();
  final String? _userId = FirebaseAuth.instance.currentUser?.uid;

  TimeOfDay _parseTime(String timeStr) {
    try {
      final parts = timeStr.trim().split(RegExp(r'[:\s]'));
      int hour = int.parse(parts[0]);
      int minute = int.parse(parts[1]);
      if (parts.length > 2) {
        final period = parts[2].toUpperCase();
        if (period == 'PM' && hour != 12) hour += 12;
        if (period == 'AM' && hour == 12) hour = 0;
      }
      return TimeOfDay(hour: hour, minute: minute);
    } catch (_) {
      return TimeOfDay.now();
    }
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  void _showEditSheet({
    required String bookingId,
    required String walkerId,
    required String petName,
    required String currentDate,
    required String currentTime,
    required int currentDuration,
  }) {
    const durations = [30, 45, 60, 90, 120];
    DateTime selectedDate = DateTime.tryParse(currentDate) ?? DateTime.now();
    TimeOfDay selectedTime = _parseTime(currentTime);
    int selectedDuration = durations.contains(currentDuration) ? currentDuration : 60;
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          Future<void> save() async {
            setSheetState(() => isSaving = true);
            try {
              final dateStr = DateFormat('yyyy-MM-dd').format(selectedDate);
              final timeStr = _formatTime(selectedTime);
              await _firestoreService.rescheduleBooking(bookingId, dateStr, timeStr, selectedDuration);
              await _firestoreService.sendNotification(
                receiverID: walkerId,
                title: 'Booking Rescheduled',
                message: 'A booking with $petName has been rescheduled to $dateStr at $timeStr. Please re-approve.',
                type: 'reschedule',
              );
              if (!mounted) return;
              Navigator.pop(sheetContext);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Booking rescheduled successfully')),
              );
            } catch (e) {
              setSheetState(() => isSaving = false);
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Failed to reschedule: $e')),
              );
            }
          }
          final loc = AppLocalizations.of(context)!;
          final theme = Theme.of(context);
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              top: 24,
              left: 24,
              right: 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loc.rescheduleBooking,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.textTheme.titleLarge?.color),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: ctx,
                      initialDate: selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) setSheetState(() => selectedDate = picked);
                  },
                  child: _pickerRow(
                    Icons.calendar_today_outlined,
                    DateFormat('EEE, MMM d yyyy').format(selectedDate),
                  ),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: ctx,
                      initialTime: selectedTime,
                    );
                    if (picked != null) setSheetState(() => selectedTime = picked);
                  },
                  child: _pickerRow(Icons.access_time, _formatTime(selectedTime)),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    border: Border.all(color: theme.dividerColor),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.timer_outlined, size: 18, color: Color(0xFF2563EB)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            value: selectedDuration,
                            isExpanded: true,
                            dropdownColor: theme.cardColor,
                            items: durations.map((d) => DropdownMenuItem(
                              value: d,
                              child: Text('$d minutes', style: TextStyle(fontSize: 15, color: theme.textTheme.bodyLarge?.color)),
                            )).toList(),
                            onChanged: (v) { if (v != null) setSheetState(() => selectedDuration = v); },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isSaving ? null : save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: isSaving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Text('Save', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _pickerRow(IconData icon, String label) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        border: Border.all(color: theme.dividerColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF2563EB)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label, style: TextStyle(fontSize: 15, color: theme.textTheme.bodyLarge?.color)),
          ),
          Icon(Icons.chevron_right, color: theme.hintColor),
        ],
      ),
    );
  }

  Future<void> _reBook(String walkerId, String walkerName) async {
    try {
      final walker = await _firestoreService.getWalkerById(walkerId);
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BookingScreen(
            walkerId: walkerId,
            walkerName: walkerName,
            hourlyRate: walker.hourlyRate,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not load walker details: $e')),
      );
    }
  }

  void _showCancelDialog(String bookingId, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.cancelBooking),
        content: Text(l10n.cancelBookingConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.noKeepIt),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              try {
                await _firestoreService.updateBookingStatus(bookingId, 'cancelled');
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.bookingCancelled)),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to cancel booking: $e')),
                  );
                }
              }
            },
            child: Text(l10n.yesCancel, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    const primaryBlue = Color(0xFF2563EB);

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: primaryBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: Text(
          l10n.myBookings,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: const [
          NotificationIcon(),
          SizedBox(width: 8),
        ],
      ),
      drawer: const OwnerDrawer(currentPage: 'Bookings'),
      body: _userId == null 
        ? Center(child: Text(l10n.pleaseLogin))
        : StreamBuilder<List<Map<String, dynamic>>>(
            stream: _firestoreService.getBookingsByOwner(_userId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error loading bookings: ${snapshot.error}'));
              }

              final allBookings = snapshot.data ?? [];
              final upcomingBookings = allBookings.where((b) => b['status'] != 'completed').toList();
              final pastBookings = allBookings.where((b) => b['status'] == 'completed').toList();

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: theme.brightness == Brightness.dark ? Colors.black26 : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => isUpcomingSelected = true),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isUpcomingSelected ? theme.cardColor : Colors.transparent,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: isUpcomingSelected
                                      ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))]
                                      : [],
                                ),
                                margin: const EdgeInsets.all(4),
                                alignment: Alignment.center,
                                child: Text(
                                  l10n.upcomingCount(upcomingBookings.length),
                                  style: TextStyle(
                                    color: isUpcomingSelected ? primaryBlue : theme.textTheme.bodySmall?.color,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => isUpcomingSelected = false),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: !isUpcomingSelected ? theme.cardColor : Colors.transparent,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: !isUpcomingSelected
                                      ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))]
                                      : [],
                                ),
                                margin: const EdgeInsets.all(4),
                                alignment: Alignment.center,
                                child: Text(
                                  l10n.pastCount(pastBookings.length),
                                  style: TextStyle(
                                    color: !isUpcomingSelected ? primaryBlue : theme.textTheme.bodySmall?.color,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: isUpcomingSelected 
                        ? _buildList(upcomingBookings, true, l10n) 
                        : _buildList(pastBookings, false, l10n),
                    ),
                  ),
                ],
              );
            },
          ),
      bottomNavigationBar: const OwnerBottomNavBar(currentIndex: 2),
    );
  }

  Widget _buildList(List<Map<String, dynamic>> bookings, bool isUpcoming, AppLocalizations l10n) {
    if (bookings.isEmpty) {
      return _buildEmptyState(
        isUpcoming ? l10n.noUpcomingWalks : l10n.noPastWalks,
        isUpcoming ? Icons.calendar_today_outlined : Icons.history,
        l10n
      );
    }

    return ListView.builder(
      key: ValueKey(isUpcoming ? 'upcoming' : 'past'),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final b = bookings[index];
        return _buildBookingCard(
          bookingId: b['id'],
          walkerId: b['walkerId'] ?? '',
          walkerName: b['walkerName'] ?? 'Walker',
          dogs: b['petName'] ?? 'Pet',
          date: b['date'] ?? '',
          time: b['time'] ?? '',
          duration: l10n.durationMinutes(b['duration'] ?? 0),
          rawDuration: (b['duration'] as int?) ?? 60,
          price: '\$${b['totalPrice']}',
          status: b['status'] ?? 'pending',
          isUpcoming: isUpcoming,
          rating: b['rating']?.toDouble(),
          l10n: l10n,
        );
      },
    );
  }

  Widget _buildEmptyState(String message, IconData icon, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: const Color(0xFFCBD5E1)),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const BrowseWalkersListScreen()));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(l10n.bookAWalk, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingCard({
    required String bookingId,
    required String walkerId,
    required String walkerName,
    required String dogs,
    required String date,
    required String time,
    required String duration,
    required int rawDuration,
    required String price,
    required String status,
    required bool isUpcoming,
    required AppLocalizations l10n,
    double? rating,
  }) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    Color statusBg;
    Color statusText;

    switch (status.toLowerCase()) {
      case 'completed':
        statusBg = const Color(0xFFDCFCE7);
        statusText = const Color(0xFF166534);
        break;
      case 'pending':
        statusBg = const Color(0xFFFEF9C3);
        statusText = const Color(0xFF854D0E);
        break;
      default: // confirmed
        statusBg = const Color(0xFFEFF6FF);
        statusText = const Color(0xFF2563EB);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: isDarkMode ? Colors.white10 : const Color(0xFFF1F5F9),
                  child: Text(
                    walkerName.isNotEmpty ? walkerName[0] : 'W',
                    style: TextStyle(color: theme.textTheme.bodyLarge?.color, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        walkerName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        l10n.withPet(dogs),
                        style: TextStyle(color: theme.textTheme.bodySmall?.color, fontSize: 13),
                      ),
                      if (!isUpcoming && rating != null)
                        Row(
                          children: List.generate(5, (index) {
                            return Icon(
                              index < rating ? Icons.star : Icons.star_border,
                              color: Colors.orange,
                              size: 14,
                            );
                          }),
                        ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(color: statusText, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: theme.dividerColor),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.calendar_today_outlined, size: 16, color: theme.textTheme.bodySmall?.color),
                const SizedBox(width: 4),
                Text(date, style: TextStyle(color: theme.textTheme.bodySmall?.color, fontSize: 12)),
                const SizedBox(width: 12),
                Icon(Icons.access_time, size: 16, color: theme.textTheme.bodySmall?.color),
                const SizedBox(width: 4),
                Text('$time ($duration)', style: TextStyle(color: theme.textTheme.bodySmall?.color, fontSize: 12)),
              ],
            ),
          ),
          Divider(height: 1, color: theme.dividerColor),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  price,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                if (isUpcoming)
                  Row(
                    children: [
                      TextButton(
                        onPressed: () => _showEditSheet(
                          bookingId: bookingId,
                          walkerId: walkerId,
                          petName: dogs,
                          currentDate: date,
                          currentTime: time,
                          currentDuration: rawDuration,
                        ),
                        child: Text(
                          l10n.edit,
                          style: const TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.bold),
                        ),
                      ),
                      TextButton(
                        onPressed: () => _showCancelDialog(bookingId, l10n),
                        child: Text(
                          l10n.cancel,
                          style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  )
                else
                  Row(
                    children: [
                      OutlinedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ReviewScreen(
                                walkerId: walkerId,
                                walkerName: walkerName,
                                dogName: dogs,
                                bookingId: bookingId,
                              ),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: theme.dividerColor),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: Text(l10n.review, style: TextStyle(color: theme.textTheme.bodySmall?.color, fontSize: 12)),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => _reBook(walkerId, walkerName),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: Text(l10n.rebook, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

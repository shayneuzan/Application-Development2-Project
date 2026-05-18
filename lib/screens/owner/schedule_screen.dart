import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../services/firestore_service.dart';
import 'owner_home_screen.dart';

class ScheduleScreen extends StatefulWidget {
  final String walkerId;
  final String walkerName;
  final double hourlyRate;
  final String selectedPet;
  final int selectedDuration;

  const ScheduleScreen({
    super.key,
    required this.walkerId,
    required this.walkerName,
    required this.hourlyRate,
    required this.selectedPet,
    required this.selectedDuration,
  });

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  String? _selectedTimeSlot;
  bool _isLoading = false;
  String? _ownerName;

  final FirestoreService _firestoreService = FirestoreService();
  final String? _userId = FirebaseAuth.instance.currentUser?.uid;

  final List<String> _timeSlots = [
    '09:00 AM', '10:00 AM', '11:00 AM',
    '12:00 PM', '01:00 PM', '02:00 PM',
    '03:00 PM', '04:00 PM', '05:00 PM',
  ];

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _fetchOwnerData();
  }

  Future<void> _fetchOwnerData() async {
    if (_userId == null) return;
    try {
      final userData = await _firestoreService.getUserById(_userId);
      if (mounted) {
        setState(() {
          _ownerName = userData.name;
        });
      }
    } catch (e) {
      debugPrint("Error fetching owner data: $e");
    }
  }

  Future<void> _confirmBooking() async {
    final loc = AppLocalizations.of(context)!;
    if (_selectedDay == null || _selectedTimeSlot == null) return;
    if (_userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.pleaseLoginToBookWalk)),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final double totalPrice = (widget.hourlyRate / 60) * widget.selectedDuration;
      
      final bookingData = {
        'ownerId': _userId,
        'ownerName': _ownerName ?? "Unknown Owner",
        'petOwner': _ownerName ?? "Unknown Owner",
        'walkerID': widget.walkerId,
        'walkerName': widget.walkerName,
        'petName': widget.selectedPet,
        'duration': widget.selectedDuration,
        'date': DateFormat('yyyy-MM-dd').format(_selectedDay!),
        'time': _selectedTimeSlot,
        'payment': totalPrice,
        'totalPrice': totalPrice,
        'status': 'pending',
      };

      await _firestoreService.createBooking(bookingData);

      if (mounted) {
        _showSuccessDialog(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loc.errorCreatingBooking(e.toString()))),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    const primaryBlue = Color(0xFF2563EB);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.cardColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.iconTheme.color),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          loc.selectDateAndTime,
          style: TextStyle(color: theme.textTheme.titleLarge?.color, fontWeight: FontWeight.bold),
        ),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.all(20),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TableCalendar(
                    firstDay: DateTime.now(),
                    lastDay: DateTime.now().add(const Duration(days: 30)),
                    focusedDay: _focusedDay,
                    selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                      });
                    },
                    calendarStyle: CalendarStyle(
                      selectedDecoration: const BoxDecoration(color: primaryBlue, shape: BoxShape.circle),
                      todayDecoration: BoxDecoration(color: primaryBlue.withOpacity(0.1), shape: BoxShape.circle),
                      todayTextStyle: const TextStyle(color: primaryBlue, fontWeight: FontWeight.bold),
                      defaultTextStyle: TextStyle(color: theme.textTheme.bodyLarge?.color),
                      weekendTextStyle: TextStyle(color: theme.textTheme.bodyLarge?.color),
                    ),
                    headerStyle: HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                      titleTextStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: theme.textTheme.titleLarge?.color),
                      leftChevronIcon: Icon(Icons.chevron_left, color: theme.iconTheme.color),
                      rightChevronIcon: Icon(Icons.chevron_right, color: theme.iconTheme.color),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Text(
                    loc.availableTimeSlots,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 2.2,
                    ),
                    itemCount: _timeSlots.length,
                    itemBuilder: (context, index) {
                      final slot = _timeSlots[index];
                      bool isSelected = _selectedTimeSlot == slot;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedTimeSlot = slot),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected ? primaryBlue : theme.cardColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: isSelected ? primaryBlue : theme.dividerColor),
                          ),
                          child: Center(
                            child: Text(
                              slot,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.white : theme.textTheme.bodyLarge?.color,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 32),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.white.withOpacity(0.05) : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        _buildSummaryItem(Icons.pets, loc.pet, widget.selectedPet),
                        const SizedBox(height: 8),
                        _buildSummaryItem(Icons.timer, loc.duration, loc.durationMinutes(widget.selectedDuration)),
                        const SizedBox(height: 8),
                        _buildSummaryItem(
                          Icons.calendar_today, 
                          loc.date, 
                          _selectedDay != null ? DateFormat('MMM dd, yyyy').format(_selectedDay!) : loc.noRecentActivity
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 100),
              ],
            ),
          ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.cardColor,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5)),
          ],
        ),
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: (_selectedDay == null || _selectedTimeSlot == null) ? null : _confirmBooking,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryBlue,
              foregroundColor: Colors.white,
              disabledBackgroundColor: theme.disabledColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            child: Text(
              loc.confirmBooking,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryItem(IconData icon, String label, String value) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 18, color: theme.hintColor),
        const SizedBox(width: 8),
        Text('$label: ', style: TextStyle(color: theme.hintColor)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  void _showSuccessDialog(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: theme.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 80),
            const SizedBox(height: 20),
            Text(loc.bookingSuccessful, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text(
              loc.walkRequested(widget.walkerName),
              textAlign: TextAlign.center,
              style: TextStyle(color: theme.textTheme.bodySmall?.color),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const OwnerHomeScreen()),
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(loc.backToHome, style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

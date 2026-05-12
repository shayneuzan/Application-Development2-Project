import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'owner_home_screen.dart';
import 'profile_screen.dart';
import 'browse_walkers_list_screen.dart';
import 'notifications_screen.dart';
import 'schedule_screen.dart';
import 'review_screen.dart';
import 'booking_screen.dart';
import '../../services/firestore_service.dart';
import '../widgets/owner_drawer.dart';

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

  void _showCancelDialog(String bookingId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Booking'),
        content: const Text('Are you sure you want to cancel this booking? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No, Keep It'),
          ),
          TextButton(
            onPressed: () async {
              // TODO: Implement cancel/delete in FirestoreService
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cancellation feature coming soon')),
              );
            },
            child: const Text('Yes, Cancel', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF2563EB);
    const backgroundGray = Color(0xFFF8FAFC);
    const textLight = Color(0xFF64748B);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: backgroundGray,
      appBar: AppBar(
        backgroundColor: primaryBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: const Text(
          'My Bookings',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white, size: 28),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NotificationsScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: const OwnerDrawer(currentPage: 'Bookings'),
      body: _userId == null 
        ? const Center(child: Text('Please log in to see your bookings'))
        : StreamBuilder<List<Map<String, dynamic>>>(
            stream: _firestoreService.getBookingsByOwner(_userId!),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              
              final allBookings = snapshot.data ?? [];
              final upcomingBookings = allBookings.where((b) => b['status'] != 'completed').toList();
              final pastBookings = allBookings.where((b) => b['status'] == 'completed').toList();

              return Column(
                children: [
                  // Toggle Tabs
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => isUpcomingSelected = true),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isUpcomingSelected ? Colors.white : Colors.transparent,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: isUpcomingSelected
                                      ? [BoxShadow(color: Colors.black12, blurRadius: 4, offset: const Offset(0, 2))]
                                      : [],
                                ),
                                margin: const EdgeInsets.all(4),
                                alignment: Alignment.center,
                                child: Text(
                                  'Upcoming (${upcomingBookings.length})',
                                  style: TextStyle(
                                    color: isUpcomingSelected ? primaryBlue : textLight,
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
                                  color: !isUpcomingSelected ? Colors.white : Colors.transparent,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: !isUpcomingSelected
                                      ? [BoxShadow(color: Colors.black12, blurRadius: 4, offset: const Offset(0, 2))]
                                      : [],
                                ),
                                margin: const EdgeInsets.all(4),
                                alignment: Alignment.center,
                                child: Text(
                                  'Past (${pastBookings.length})',
                                  style: TextStyle(
                                    color: !isUpcomingSelected ? primaryBlue : textLight,
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

                  // Bookings List
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: isUpcomingSelected 
                        ? _buildList(upcomingBookings, true) 
                        : _buildList(pastBookings, false),
                    ),
                  ),
                ],
              );
            },
          ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: 2,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white54,
          backgroundColor: const Color(0xFF2563EB),
          onTap: (index) {
            if (index == 0) {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const OwnerHomeScreen()));
            } else if (index == 1) {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const BrowseWalkersListScreen()));
            } else if (index == 4) {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const ProfileScreen()));
            }
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Walkers'),
            BottomNavigationBarItem(icon: Icon(Icons.calendar_month_outlined), label: 'Bookings'),
            BottomNavigationBarItem(icon: Icon(Icons.map_outlined), label: 'Map'),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
          ],
        ),
      ),
    );
  }

  Widget _buildList(List<Map<String, dynamic>> bookings, bool isUpcoming) {
    if (bookings.isEmpty) {
      return _buildEmptyState(
        isUpcoming ? 'No upcoming walks scheduled.' : 'No past walks yet.',
        isUpcoming ? Icons.calendar_today_outlined : Icons.history
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
          duration: '${b['duration']} min',
          price: '\$${b['totalPrice']}',
          status: b['status'] ?? 'pending',
          isUpcoming: isUpcoming,
          rating: b['rating']?.toDouble(),
        );
      },
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: const Color(0xFFCBD5E1)),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(color: Color(0xFF64748B), fontSize: 16, fontWeight: FontWeight.w500),
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
            child: const Text('Book a Walk', style: TextStyle(color: Colors.white)),
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
    required String price,
    required String status,
    required bool isUpcoming,
    double? rating,
  }) {
    const textDark = Color(0xFF1E293B);
    const textLight = Color(0xFF64748B);

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
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 15,
            offset: Offset(0, 5),
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
                  backgroundColor: const Color(0xFFF1F5F9),
                  child: Text(
                    walkerName[0],
                    style: const TextStyle(color: textDark, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        walkerName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textDark),
                      ),
                      Text(
                        'with $dogs',
                        style: const TextStyle(color: textLight, fontSize: 13),
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
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_outlined, size: 16, color: textLight),
                const SizedBox(width: 4),
                Text(date, style: const TextStyle(color: textLight, fontSize: 12)),
                const SizedBox(width: 12),
                const Icon(Icons.access_time, size: 16, color: textLight),
                const SizedBox(width: 4),
                Text('$time ($duration)', style: const TextStyle(color: textLight, fontSize: 12)),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  price,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: textDark),
                ),
                if (isUpcoming)
                  Row(
                    children: [
                      TextButton(
                        onPressed: () {
                          // TODO: Navigate to Schedule Screen to edit
                        },
                        child: const Text(
                          'Edit',
                          style: TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.bold),
                        ),
                      ),
                      TextButton(
                        onPressed: () => _showCancelDialog(bookingId),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
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
                          side: const BorderSide(color: Color(0xFFE2E8F0)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Review', style: TextStyle(color: textLight, fontSize: 12)),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BookingScreen(
                                walkerId: walkerId,
                                walkerName: walkerName,
                                hourlyRate: 30, // Placeholder
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Re-book', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
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

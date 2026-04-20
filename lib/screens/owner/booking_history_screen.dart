import 'package:flutter/material.dart';
import 'owner_home_screen.dart';
import 'profile_screen.dart';
import 'browse_walkers_list_screen.dart';
import 'notifications_screen.dart';
import '../widgets/owner_drawer.dart';

class BookingHistoryScreen extends StatefulWidget {
  const BookingHistoryScreen({super.key});

  @override
  State<BookingHistoryScreen> createState() => _BookingHistoryScreenState();
}

class _BookingHistoryScreenState extends State<BookingHistoryScreen> {
  bool isUpcomingSelected = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF2563EB);
    const backgroundGray = Color(0xFFF8FAFC);
    const textDark = Color(0xFF1E293B);
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
            icon: Stack(
              children: [
                const Icon(Icons.notifications_outlined, color: Colors.white, size: 28),
                Positioned(
                  right: 4,
                  top: 4,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
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
      body: Column(
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
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  )
                                ]
                              : [],
                        ),
                        margin: const EdgeInsets.all(4),
                        alignment: Alignment.center,
                        child: Text(
                          'Upcoming (2)',
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
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  )
                                ]
                              : [],
                        ),
                        margin: const EdgeInsets.all(4),
                        alignment: Alignment.center,
                        child: Text(
                          'Past (1)',
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
              child: isUpcomingSelected ? _buildUpcomingList() : _buildPastList(),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: 2, // Bookings tab active
          type: BottomNavigationBarType.fixed,
          selectedItemColor: primaryBlue,
          unselectedItemColor: const Color(0xFF94A3B8),
          backgroundColor: Colors.white,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          onTap: (index) {
            if (index == 0) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const OwnerHomeScreen()),
              );
            } else if (index == 1) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const BrowseWalkersListScreen()),
              );
            } else if (index == 3) {
              // TODO: Navigate to Map Screen when built
            } else if (index == 4) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
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

  Widget _buildUpcomingList() {
    return ListView(
      key: const ValueKey('upcoming'),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        _buildBookingCard(
          walkerName: 'Sarah Johnson',
          dogs: 'Max',
          date: '2026-03-25',
          time: '10:00',
          duration: '60 min',
          price: '\$25',
          status: 'Confirmed',
          isUpcoming: true,
        ),
        _buildBookingCard(
          walkerName: 'Sarah Johnson',
          dogs: 'Rocky',
          date: '2026-03-24',
          time: '09:00',
          duration: '45 min',
          price: '\$19',
          status: 'Pending',
          isUpcoming: true,
        ),
      ],
    );
  }

  Widget _buildPastList() {
    return ListView(
      key: const ValueKey('past'),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        _buildBookingCard(
          walkerName: 'Mike Chen',
          dogs: 'Bella',
          date: '2026-03-20',
          time: '14:00',
          duration: '30 min',
          price: '\$15',
          status: 'Completed',
          isUpcoming: false,
        ),
      ],
    );
  }

  Widget _buildBookingCard({
    required String walkerName,
    required String dogs,
    required String date,
    required String time,
    required String duration,
    required String price,
    required String status,
    required bool isUpcoming,
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
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
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      'Cancel Booking',
                      style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

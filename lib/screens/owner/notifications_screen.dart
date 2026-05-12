import 'package:flutter/material.dart';
import 'owner_home_screen.dart';
import 'booking_history_screen.dart';
import 'profile_screen.dart';
import 'browse_walkers_list_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  // Using a list so we can simulate "clearing" or "marking as read"
  List<Map<String, dynamic>> _notifications = [
    {
      'icon': Icons.calendar_today,
      'iconBg': const Color(0xFFEFF6FF),
      'iconColor': const Color(0xFF2563EB),
      'title': 'Booking Confirmed',
      'description': 'Your booking with Sarah Johnson for March 25 has been confirmed.',
      'time': '2 mins ago',
      'isUnread': true,
      'category': 'New',
    },
    {
      'icon': Icons.location_on,
      'iconBg': const Color(0xFFF0FDF4),
      'iconColor': Colors.green,
      'title': 'Walk Started',
      'description': 'Sarah has started walking Max. Track the walk in real-time!',
      'time': '1 hour ago',
      'isUnread': true,
      'category': 'New',
    },
    {
      'icon': Icons.payment,
      'iconBg': const Color(0xFFFEFCE8),
      'iconColor': Colors.yellow.shade800,
      'title': 'Payment Processed',
      'description': "Your payment of \$15 for Bella's walk has been processed.",
      'time': 'Yesterday',
      'isUnread': false,
      'category': 'Earlier',
    },
    {
      'icon': Icons.star_border,
      'iconBg': const Color(0xFFEFF6FF),
      'iconColor': Colors.blue,
      'title': 'Rate your Walker',
      'description': 'How was your walk with Mike Chen? Leave a review now!',
      'time': '2 days ago',
      'isUnread': false,
      'category': 'Earlier',
    },
  ];

  void _markAllRead() {
    setState(() {
      for (var note in _notifications) {
        note['isUnread'] = false;
      }
    });
  }

  void _clearAll() {
    setState(() {
      _notifications = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF2563EB);
    const backgroundGray = Color(0xFFF8FAFC);
    const textDark = Color(0xFF1E293B);

    return Scaffold(
      backgroundColor: backgroundGray,
      appBar: AppBar(
        backgroundColor: const Color(0xFF2563EB),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: textDark,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          if (_notifications.isNotEmpty)
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'read') _markAllRead();
                if (value == 'clear') _clearAll();
              },
              icon: const Icon(Icons.more_vert, color: textDark),
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'read', child: Text('Mark all as read')),
                const PopupMenuItem(value: 'clear', child: Text('Clear all', style: TextStyle(color: Colors.red))),
              ],
            ),
        ],
      ),
      body: _notifications.isEmpty ? _buildEmptyState() : _buildNotificationList(),
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
          currentIndex: 0,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white54,
          backgroundColor: const Color(0xFF2563EB),
          onTap: (index) {
            if (index == 0) {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const OwnerHomeScreen()));
            } else if (index == 1) {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const BrowseWalkersListScreen()));
            } else if (index == 2) {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const BookingHistoryScreen()));
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20),
              ],
            ),
            child: const Icon(Icons.notifications_none_outlined, size: 64, color: Color(0xFFCBD5E1)),
          ),
          const SizedBox(height: 24),
          const Text(
            'All caught up!',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
          ),
          const SizedBox(height: 8),
          const Text(
            "You don't have any new notifications\nat the moment.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF64748B), fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationList() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        if (_notifications.any((n) => n['category'] == 'New')) ...[
          const Text('New', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
          const SizedBox(height: 12),
          ..._notifications.where((n) => n['category'] == 'New').map((n) => _buildCard(n)),
          const SizedBox(height: 24),
        ],
        if (_notifications.any((n) => n['category'] == 'Earlier')) ...[
          const Text('Earlier', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
          const SizedBox(height: 12),
          ..._notifications.where((n) => n['category'] == 'Earlier').map((n) => _buildCard(n)),
        ],
      ],
    );
  }

  Widget _buildCard(Map<String, dynamic> n) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: n['isUnread'] ? const Color(0xFF2563EB).withOpacity(0.1) : Colors.transparent),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: n['iconBg'],
              shape: BoxShape.circle,
            ),
            child: Icon(n['icon'], color: n['iconColor'], size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      n['title'],
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1E293B)),
                    ),
                    if (n['isUnread'])
                      const CircleAvatar(radius: 4, backgroundColor: Color(0xFF2563EB)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  n['description'],
                  style: const TextStyle(color: Color(0xFF64748B), fontSize: 13, height: 1.4),
                ),
                const SizedBox(height: 8),
                Text(n['time'], style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

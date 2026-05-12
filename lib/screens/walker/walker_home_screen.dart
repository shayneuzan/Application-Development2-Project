import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pawwalk/screens/walker/earnings_screen.dart';
import '../../models/booking_model.dart';
import '../widgets/walker_bottom_nav_bar.dart';
import '../widgets/walker_drawer.dart';
import 'package:intl/intl.dart';
import '../chat/chat_service.dart';
import '../auth/login_screen.dart';
import '../widgets/walker_notification_icon.dart';
import '/services/firestore_service.dart';

class WalkerHomeScreen extends StatefulWidget {
  const WalkerHomeScreen({super.key});

  @override
  State<WalkerHomeScreen> createState() => _WalkerHomeScreenState();
}

class _WalkerHomeScreenState extends State<WalkerHomeScreen> {
  final String? uid = FirebaseAuth.instance.currentUser?.uid;
  final ChatService _chatService = ChatService();
  final FirestoreService _firestoreService = FirestoreService();

  final DateTime _presentDay = DateTime.now();
  bool _isTimedOut = false;
  StreamSubscription? _statusSub;

  Future<void> checkAndResetEarnings(Map<String, dynamic> data) async {
    if (uid == null) return;
    DateTime now = DateTime.now();
    DateTime lastDaily = (data['lastResetDaily'] as Timestamp?)?.toDate() ?? now;
    DateTime lastWeekly = (data['lastResetWeekly'] as Timestamp?)?.toDate() ?? now;
    DateTime lastMonthly = (data['lastResetMonthly'] as Timestamp?)?.toDate() ?? now;

    Map<String, dynamic> updates = {};
    // Daily reset
    if (now.day != lastDaily.day || now.month != lastDaily.month || now.year != lastDaily.year) {
      updates['todayEarnings'] = 0.0;
      updates['lastResetDaily'] = FieldValue.serverTimestamp();
    }
    // Weekly reset (7 days passed)
    if (now.difference(lastWeekly).inDays >= 7) {
      updates['weeklyEarnings'] = 0.0;
      updates['lastResetWeekly'] = FieldValue.serverTimestamp();
    }
    // Monthly reset
    if (now.month != lastMonthly.month || now.year != lastMonthly.year) {
      updates['monthEarnings'] = 0.0;
      updates['lastResetMonthly'] = FieldValue.serverTimestamp();
    }
    // Apply updates
    if (updates.isNotEmpty) {
      await FirebaseFirestore.instance.collection('users').doc(uid).update(updates);
    }
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) setState(() => _isTimedOut = true);
    });

    // Listen to the user's document and sign them out if they get suspended
    if (uid != null) {
      _statusSub = FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .snapshots()
          .listen((doc) {
        if (!doc.exists || !mounted) return;
        final status = (doc.data() as Map<String, dynamic>)['status'] ?? 'active';
        if (status == 'suspended') {
          FirebaseAuth.instance.signOut();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => LoginScreen()),
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _statusSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
        builder: (context, snapshot) {
          String? name = "Walker";
          double todayEarnings = 0;
          double weeklyEarnings = 0;
          bool isPending = false;
          if (snapshot.hasData && snapshot.data!.exists) {
            final data = snapshot.data!.data() as Map<String, dynamic>;
            // Check and reset earnings
            checkAndResetEarnings(data);

            // Update earnings and name
            name = data['name'] ?? 'Guest';
            todayEarnings = (data['todayEarnings'] ?? 0).toDouble();
            weeklyEarnings = (data['weeklyEarnings'] ?? 0).toDouble();
            isPending = !(data['isApproved'] ?? false) || data['status'] == 'pending';
          }
          return Scaffold(
            appBar: AppBar(
              title: const Text('Dashboard', style: TextStyle(color: Colors.white)),
              backgroundColor: const Color(0xFF2563EB),
              iconTheme: const IconThemeData(color: Colors.white),
              actions: [
                const WalkerNotificationIcon(),
                const SizedBox(width: 8,)
              ],
            ),
            drawer: WalkerDrawer(name: name!),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // Show banner if the walker has not been approved yet
                      if (isPending)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFF59E0B)),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.access_time, color: Color(0xFFD97706), size: 18),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Your account is pending admin approval. You cannot accept bookings yet.',
                                  style: TextStyle(color: Color(0xFF92400E), fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                        ),

                      Text('Hello, $name!', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),),
                      const SizedBox(height: 10,),
                      const Text('Here\'s your activity overview'),
                      const SizedBox(height: 10,),
                      // Earnings Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2563EB),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4),),
                          ],
                        ),
                        child: Column(
                            children: [
                              Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text('Today\'s Earnings', style: TextStyle(color: Colors.white),),
                                        const SizedBox(height: 4,),
                                        Text('\$${todayEarnings.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),)
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        const Text('This Week', style: TextStyle(color: Colors.white),),
                                        const SizedBox(height: 4,),
                                        Text('\$${weeklyEarnings.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),)
                                      ],
                                    ),
                                  ]
                              ),
                              const SizedBox(height: 20,),
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(builder: (context) => const EarningsScreen()),
                                    );
                                  },
                                  icon: const Icon(Icons.attach_money, color: Color(0xFF2563EB), size: 18),
                                  label: const Text("View All Earnings", style: TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.bold),),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12),),
                                  ),
                                ),
                              ),
                            ]
                        ),
                      ),
                      const SizedBox(height: 20,),
                      const Text('Upcoming Walks', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),),
                      const SizedBox(height: 10,),
                      StreamBuilder<List<BookingModel>>(
                      stream: _firestoreService.getThreePendingRequestsByWalkerID(uid!, _presentDay),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 20.0),
                            child: Center(child: Text("No upcoming walks scheduled.", style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),),),
                          );
                        }
                        final requests = snapshot.data!;
                        return ListView.builder(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: requests.length,
                          itemBuilder: (context, index) {
                            final data = requests[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      const CircleAvatar(radius: 25, backgroundColor: Color(0xFFF1F5F9), child: Icon(Icons.pets, color: Colors.black, size: 24)),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(data.petName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                            Text("Owner: ${data.ownerName}", style: const TextStyle(color: Colors.grey, fontSize: 14)),
                                          ],
                                        ),
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Text(data.time, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                          Text(DateFormat('yyyy-MM-dd').format(data.date), style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const Divider(height: 24, thickness: 1),
                                  Row(
                                    children: [
                                      const Icon(Icons.access_time, size: 16, color: Colors.grey),
                                      const SizedBox(width: 4),
                                      Text("${data.duration} min", style: const TextStyle(color: Colors.grey, fontSize: 14)),
                                      const Spacer(),
                                      Text("\$${data.totalPrice}", style: const TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.bold, fontSize: 16)),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      }
                    ),
                      const SizedBox(height: 20,),
                      const Text("New Requests", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),),
                      const SizedBox(height: 10,),
                      StreamBuilder<List<BookingModel>>(
                        stream: _firestoreService.getThreePendingRequestsByWalkerID(uid!, _presentDay),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting && !_isTimedOut) return const Center(child: CircularProgressIndicator());
                          if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text('No Upcoming Requests'));
                          final requests = snapshot.data!;
                          return ListView.separated(
                            shrinkWrap: true, 
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: requests.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final data = requests[index];
                              return Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: const Border(left: BorderSide(color: Color(0xFF2563EB), width: 5)),
                                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(data.ownerName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                        Text("\$${data.totalPrice}", style: const TextStyle(color: Color(0xFF2563EB), fontSize: 18, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                    Text("${data.petName} - ${data.duration} min walk", style: const TextStyle(color: Colors.grey)),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                                        const SizedBox(width: 4),
                                        Text("${data.date} at ${data.time}", style: const TextStyle(color: Colors.grey)),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: OutlinedButton(
                                            onPressed: () async {
                                              String ownerID = data.ownerId;
                                              String petName = data.petName;

                                              await _firestoreService.updateBookingStatus(data.id, 'declined');
                                              if (ownerID.isNotEmpty) {
                                                // Notify Owner
                                                _firestoreService.sendNotification(
                                                  receiverID: ownerID,
                                                  title: 'Request Declined',
                                                  message: '$name declined your walk request for $petName.',
                                                  type: 'request_declined',
                                                );
                                                // Notify Walker
                                                _firestoreService.sendNotification(
                                                  receiverID: uid!,
                                                  title: 'Request Declined',
                                                  message: 'You have declined the walk request for $petName.',
                                                  type: 'request_declined',
                                                );
                                              }
                                              if (!context.mounted) return;
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text("Request Declined! Pet: $petName\nOwner: ${data.ownerName}"),
                                                  backgroundColor: Colors.red,
                                                  duration: const Duration(seconds: 3),
                                                ),
                                              );
                                            },
                                            style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                                            child: const Text("Decline", style: TextStyle(color: Colors.black)),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: ElevatedButton(
                                            onPressed: () async {
                                              String ownerID = data.ownerId;
                                              String petName = data.petName;
                                              String ownerName = data.ownerName;

                                              await _firestoreService.updateBookingStatus(data.id, 'accept');
                                              if (ownerID.isNotEmpty) {
                                                // Create Chat Room
                                                await _chatService.createChatRoom(ownerID, ownerName, petName);

                                                // Notify Owner
                                                _firestoreService.sendNotification(
                                                  receiverID: ownerID,
                                                  title: 'Walk Request Accepted!',
                                                  message: '$name is ready to walk $petName! Go to "Messages" in your drawer to coordinate details.',
                                                  type: 'request_accepted',
                                                );
                                                // Notify Walker
                                                _firestoreService.sendNotification(
                                                  receiverID: uid!,
                                                  title: 'Walk Request Accepted!',
                                                  message: 'You have accepted the walk request for $petName. Open "View Chat" to discuss location with $ownerName.',
                                                  type: 'request_accepted',
                                                );
                                              }
                                              if (!context.mounted) return;
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text("Request Accepted! Pet: $petName\nOwner: $ownerName"),
                                                  backgroundColor: Colors.green,
                                                  duration: const Duration(seconds: 3),
                                                ),
                                              );
                                            },
                                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                                            child: const Text("Accept", style: TextStyle(color: Colors.white)),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      )
                    ]
                ),
              ),
            ),
            bottomNavigationBar: const WalkerBottomNavBar(currentIndex: 0),
          );
        }
    );
  }
}

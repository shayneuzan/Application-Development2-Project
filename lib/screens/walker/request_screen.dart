import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pawwalk/models/booking_model.dart';
import 'package:pawwalk/services/firestore_service.dart';
import '../widgets/walker_bottom_nav_bar.dart';
import '../widgets/walker_drawer.dart';
import 'package:intl/intl.dart';
import '../chat/chat_service.dart';

import '../widgets/walker_notification_icon.dart';

class RequestScreen extends StatefulWidget {
  const RequestScreen({super.key});

  @override
  State<RequestScreen> createState() => _RequestScreenState();
}

class _RequestScreenState extends State<RequestScreen> {
  final String? uid = FirebaseAuth.instance.currentUser?.uid;
  final ChatService _chatService = ChatService();
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(uid).get(),
      builder: (context, snapshot) {
        String? walkerName = "Walker";
        if (snapshot.hasData && snapshot.data!.exists) {
          walkerName = (snapshot.data!.data() as Map<String, dynamic>)['name'] ?? 'Walker';
        }
        return Scaffold(
          appBar: AppBar(
            title: const Text('Booking Requests', style: TextStyle(color: Colors.white)),
            backgroundColor: const Color(0xFF2563EB),
            iconTheme: const IconThemeData(color: Colors.white),
            actions: [
              const WalkerNotificationIcon(),
              const SizedBox(width: 8),
            ],
          ),
          drawer: WalkerDrawer(name: walkerName!),
          body: StreamBuilder<List<BookingModel>>(
            stream: _firestoreService.getBookingsByWalkerID(uid!),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                  child: Text("No upcoming walks scheduled.",
                    style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
                  ),
                );
              }
              final requests = snapshot.data!;
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: requests.map((booking) {
                    String initials = booking.ownerName.trim().isNotEmpty ? booking.ownerName.trim()
                      .split(RegExp(r'\s+'))
                      .where((word) => word.isNotEmpty)
                      .map((word) => word[0].toUpperCase())
                      .take(3).join() : "?";

                    return Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 22,
                                backgroundColor: const Color(0xFFF1F5F9),
                                child: Text(initials, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(booking.ownerName, style: const TextStyle(fontWeight: FontWeight.bold)),
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              const Icon(Icons.pets, size: 16, color: Colors.grey),
                                              const SizedBox(width: 8),
                                              Text(booking.petName),
                                            ],
                                          ),
                                          const SizedBox(height: 14),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                            width: double.infinity,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFEFF6FF),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Column(
                                              children: [
                                                Row(
                                                  children: [
                                                    const Icon(Icons.calendar_month_outlined, size: 20, color: Color(0xFF2563EB)),
                                                    const SizedBox(width: 10),
                                                    Text(DateFormat('yyyy-MM-dd').format(booking.date), style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 13,))
                                                  ]
                                                ),
                                                const SizedBox(height: 12),
                                                Row(
                                                  children: [
                                                    const Icon(Icons.timer_outlined, size: 20, color: Color(0xFF2563EB)),
                                                    const SizedBox(width: 10),
                                                    Text("${booking.time} (${booking.duration} minutes)", style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 13,)),
                                                  ]
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text("\$${booking.totalPrice}", style: const TextStyle(fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              // Decline Button
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () async {
                                    _firestoreService.updateBookingStatus(booking.id, 'declined');

                                    if (booking.ownerId.isNotEmpty) {
                                      _firestoreService.sendNotification(
                                        receiverID: booking.ownerId,
                                        title: 'Request Declined',
                                        message: '$walkerName declined your walk request for ${booking.petName}.',
                                        type: 'request_declined',
                                      );

                                      _firestoreService.sendNotification(
                                        receiverID: uid!,
                                        title: 'Request Declined',
                                        message: 'You have declined the walk request for ${booking.petName} from ${booking.ownerName}.',
                                        type: 'request_declined',
                                      );
                                    }

                                    if (!context.mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text("Request Declined! Pet: ${booking.petName}\nOwner: ${booking.ownerName}"),
                                        backgroundColor: Colors.red,
                                        duration: const Duration(seconds: 3),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.close, size: 18, color: Colors.black),
                                  label: const Text("Decline", style: TextStyle(color: Colors.black)),
                                  style: OutlinedButton.styleFrom(
                                    backgroundColor: const Color(0xFFF1F5F9),
                                    side: BorderSide.none,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Accept Button
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () async {
                                    _firestoreService.updateBookingStatus(booking.id, 'accepted');
                                    if (booking.ownerId.isNotEmpty) {
                                      // Create a chat room between the walker and the owner
                                      await _chatService.createChatRoom(booking.ownerId, booking.ownerName, booking.petName);

                                      _firestoreService.sendNotification(
                                        receiverID: booking.ownerId,
                                        title: 'Walk Request Accepted!',
                                        message: '${booking.walkerName} is ready to walk ${booking.petName}! Go to "Messages" in your drawer to coordinate details.',
                                        type: 'request_accepted',
                                      );

                                      _firestoreService.sendNotification(
                                        receiverID: uid!,
                                        title: 'Walk Request Accepted!',
                                        message: 'You have accepted the walk request for ${booking.petName}. Open "View Chat" to discuss location with ${booking.ownerName}.',
                                        type: 'request_accepted',
                                      );
                                    }
                                    if (!context.mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text("Request Accepted! Pet: ${booking.petName}\nOwner: ${booking.ownerName}"),
                                        backgroundColor: Colors.green,
                                        duration: const Duration(seconds: 3),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.check, size: 18, color: Colors.white),
                                  label: const Text("Accept", style: TextStyle(color: Colors.white)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF2563EB),
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          ),
          bottomNavigationBar: const WalkerBottomNavBar(currentIndex: 1),
        );
      },
    );
  }
}

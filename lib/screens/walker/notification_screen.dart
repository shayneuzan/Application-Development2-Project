import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../widgets/walker_bottom_nav_bar.dart';
import '../widgets/walker_drawer.dart';
import 'package:intl/intl.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final String? uid = FirebaseAuth.instance.currentUser?.uid;
  late Future<DocumentSnapshot> _userFuture;

  @override
  void initState() {
    super.initState();
    if (uid != null) {
      _userFuture = FirebaseFirestore.instance.collection('users').doc(uid).get();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (uid == null) {
      return const Scaffold(body: Center(child: Text("User not logged in")));
    }
    return FutureBuilder<DocumentSnapshot>(
      future: _userFuture,
      builder: (context, userSnapshot) {
        String name = "Walker";
        if (userSnapshot.hasData && userSnapshot.data!.exists) {
          name = (userSnapshot.data!.data() as Map<String, dynamic>)['name'] ?? 'Walker';
        }
        return Scaffold(
          appBar: AppBar(
            title: const Text('Notifications', style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.blueAccent,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          drawer: WalkerDrawer(name: name),
          body: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('notifications')
                .where('receiverID', isEqualTo: uid)
                .orderBy('timestamp', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                print("Notification Stream Error: ${snapshot.error}");
                return const Center(child: Text("Error loading notifications."));
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.notifications_none, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        "No notifications yet.",
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    ],
                  ),
                );
              }
              final docs = snapshot.data!.docs;
              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: docs.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final data = docs[index].data() as Map<String, dynamic>;
                  final String title = data['title'] ?? 'Notification';
                  final String message = data['message'] ?? '';
                  final String type = data['type'] ?? '';
                  final Timestamp? timestamp = data['timestamp'] as Timestamp?;
                  final bool isRead = data['isRead'] ?? false;
                  String timeAgo = '';
                  if (timestamp != null) {
                    timeAgo = DateFormat('MMM d, h:mm a').format(timestamp.toDate());
                  }
                  final Color notificationColor = _getColorForType(type);
                  return Dismissible(
                    key: Key(docs[index].id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      color: Colors.red,
                      child: const Icon(
                        Icons.delete,
                        color: Colors.white,
                      ),
                    ),
                    onDismissed: (_) async {
                      await docs[index].reference.delete();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Notification dismissed"),
                        ),
                      );
                    },
                    child: InkWell(
                      onTap: () async {
                        if (!isRead) {
                          await docs[index].reference.update({
                            'isRead': true,
                          });
                        }
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: notificationColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: notificationColor.withOpacity(0.35),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              backgroundColor: notificationColor.withOpacity(0.2),
                              child: Icon(
                                _getIconForType(type),
                                color: notificationColor,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          title,
                                          style: TextStyle(
                                            fontWeight: isRead
                                                ? FontWeight.w500
                                                : FontWeight.bold,
                                            fontSize: 15,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        timeAgo,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    message,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
          // Note: BottomNavBar index -1 because Notification might not be in main tabs
          // or you can set it to the closest match.
          bottomNavigationBar: const WalkerBottomNavBar(currentIndex: 0),
        );
      },
    );
  }

  IconData _getIconForType(String? type) {
    switch (type) {
      case 'payment_received':
        return Icons.attach_money;
      case 'walk_request_pending':
        return Icons.pets;
      case 'request_accepted':
        return Icons.check_circle;
      case 'request_declined':
        return Icons.cancel;
      case 'request_cancelled':
        return Icons.error;
      case 'chat_message':
        return Icons.chat_bubble;
      default:
        return Icons.notifications;
    }
  }

  Color _getColorForType(String? type) {
    switch (type) {
    // GREEN
      case 'payment_received':
        return Colors.green;
      case 'request_accepted':
        return Colors.green;
    // YELLOW
      case 'walk_request_pending':
        return Colors.amber;
    // RED
      case 'request_declined':
        return Colors.red;
      case 'request_cancelled':
        return Colors.red;
    // BLUE / INFO
      case 'chat_message':
        return Colors.lightBlue;
      default:
        return Colors.grey;
    }
  }
}

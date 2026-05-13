import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../models/notification_model.dart';
import '../../services/firestore_service.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final String? uid = FirebaseAuth.instance.currentUser?.uid;
  final FirestoreService _firestoreService = FirestoreService();

  Map<String, List<NotificationModel>> _categorize(List<NotificationModel> docs) {
    return {
      'New': docs.where((selectedNotification) => !selectedNotification.isRead).toList(),
      'Earlier': docs.where((selectedNotification) => selectedNotification.isRead).toList(),
    };
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2563EB),
        elevation: 0,
        title: const Text('Notifications', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20,),),
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
            PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) async {
              if (value == 'read') _firestoreService.markAllRead(uid!);
              if (value == 'clear') _firestoreService.clearAll(uid!);
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'read', child: Text('Mark all as read')),
              const PopupMenuItem(value: 'clear', child: Text('Clear all', style: TextStyle(color: Colors.red)),),
            ],
          ),
        ],
      ),
      body: StreamBuilder<List<NotificationModel>>(
        stream: _firestoreService.getAllNotificationsByUserID(uid!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            print("Notification Stream Error: ${snapshot.error}");
            return const Center(child: Text("Error loading notifications."));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_none, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    "No notifications available at this time.",
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ],
              ),
            );
          }

          final notificationList = snapshot.data!;
          final categories = _categorize(notificationList);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (categories['New']!.isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.only(bottom: 10),
                  child: Text('New',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF64748B), fontSize: 13),
                  ),
                ),
                ...categories['New']!.map((n) => _buildNotificationCard(n)),
                const SizedBox(height: 16),
              ],
              if (categories['Earlier']!.isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.only(bottom: 10),
                  child: Text('Earlier',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF64748B), fontSize: 13),
                  ),
                ),
                ...categories['Earlier']!.map((n) => _buildNotificationCard(n)),
              ],
            ],
          );
        }
      )
    );
  }

  Widget _buildNotificationCard(NotificationModel n) {
    final Color color = _getColorForType(n.type);

    return Dismissible(
      key: Key(n.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) async {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Notification dismissed")),
        );
        await _firestoreService.deleteNotification(n.id);
      },
      child: InkWell(
        onTap: () async {
          if (!n.isRead) {
            await _firestoreService.markAsRead(n.id);
          }
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(_getIconForType(n.type), color: color, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(n.title,
                            style: TextStyle(
                              fontWeight: n.isRead ? FontWeight.w600 : FontWeight.bold,
                              fontSize: 15,
                              color: const Color(0xFF1E293B),
                            ),
                          ),
                        ),
                        if (!n.isRead)
                          const CircleAvatar(radius: 5, backgroundColor: Color(0xFF2563EB)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(n.message,
                      style: const TextStyle(color: Color(0xFF64748B), fontSize: 13, height: 1.4),
                    ),
                    const SizedBox(height: 8),
                    Text(_timeAgo(n.timestamp),
                      style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _timeAgo(Timestamp timestamp) {
    final diff = DateTime.now().difference(timestamp.toDate());
    if (diff.inMinutes < 1)  return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} mins ago';
    if (diff.inHours < 24)   return '${diff.inHours} hours ago';
    if (diff.inDays == 1)    return 'Yesterday';
    return '${diff.inDays} days ago';
  }

  IconData _getIconForType(String type) {
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
      case 'walk_completed':
        return Icons.flag;
      case 'walk_cancelled':
        return Icons.block;
      case 'refund_issued':
        return Icons.account_balance_wallet;
      case 'chat_message':
        return Icons.chat_bubble;
      default:
        return Icons.notifications;
    }
  }

  Color _getColorForType(String type) {
    switch (type) {
      case 'payment_received':
        case 'request_accepted':
          case 'walk_completed':
            return Colors.green;
      case 'walk_request_pending':
        return Colors.amber;
      case 'request_declined':
        case 'request_cancelled':
          case 'walk_cancelled':
            return Colors.red;
      case 'refund_issued':
        return Colors.orange;
      case 'chat_message':
        return Colors.lightBlue;
      default:
        return Colors.grey;
    }
  }
}

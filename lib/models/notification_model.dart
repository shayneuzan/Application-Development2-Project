import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String id;
  final String message;
  final String receiverID;
  final Timestamp timestamp;
  final bool isRead;
  final String title;
  final String type;

  NotificationModel({
    required this.id,
    required this.message,
    required this.receiverID,
    required this.timestamp,
    required this.isRead,
    required this.title,
    required this.type,
  });

  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return NotificationModel(
      id: doc.id,
      message: data['message'] ?? '',
      receiverID: data['receiverID'] ?? '',
      timestamp: data['timestamp'] as Timestamp,
      isRead: data['isRead'] ?? false,
      title: data['title'] ?? '',
      type: data['type'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'message': message,
      'receiverID': receiverID,
      'timestamp': timestamp,
      'isRead': isRead,
      'title': title,
      'type': type,
    };
  }
}

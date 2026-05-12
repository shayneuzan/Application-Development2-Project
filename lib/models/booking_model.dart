import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class BookingModel {
  final String id;
  final String ownerId;
  final String ownerName;
  final String petName;
  final DateTime date;
  final String time;
  final int duration;
  final double totalPrice;
  final String walkerId;
  final String walkerName;
  final String status;
  final Timestamp? createdAt;

  BookingModel({
    required this.id,
    required this.ownerId,
    required this.ownerName,
    required this.petName,
    required this.date,
    required this.time,
    required this.duration,
    required this.totalPrice,
    required this.walkerId,
    required this.walkerName,
    required this.status,
    this.createdAt,
  });

  factory BookingModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return BookingModel(
      id: doc.id,
      ownerId: data['ownerId'] ?? '',
      ownerName: data['ownerName'] ?? '',
      petName: data['petName'] ?? '',
      date: DateTime.parse(data['date'] ?? '0000-00-00'),
      time: data['time'] ?? '',
      duration: data['duration'] ?? 0,
      totalPrice: (data['totalPrice'] ?? 0.0).toDouble(),
      walkerId: data['walkerId'] ?? '',
      walkerName: data['walkerName'] ?? '',
      status: data['status'] ?? '',
      createdAt: data['createdAt'] as Timestamp?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ownerId': ownerId,
      'ownerName': ownerName,
      'petName': petName,
      'date': DateFormat('yyyy-MM-dd').format(date),
      'time': time,
      'duration': duration,
      'totalPrice': totalPrice,
      'walkerId': walkerId,
      'walkerName': walkerName,
      'status': status,
      'createdAt': createdAt,
    };
  }
}

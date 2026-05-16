import 'package:cloud_firestore/cloud_firestore.dart';

class WalkerModel {
  final String id;
  final String name;
  final String initials;
  final double rating;
  final int walksCount;
  final double hourlyRate;
  final String bio;
  final List<String> services;
  final int experienceYears;
  final bool isApproved;
  final String status;

  final double todayEarnings;
  final double weeklyEarnings;
  final double monthEarnings;
  final DateTime lastResetDaily;
  final DateTime lastResetWeekly;
  final DateTime lastResetMonthly;

  WalkerModel({
    required this.id,
    required this.name,
    required this.initials,
    required this.rating,
    required this.walksCount,
    required this.hourlyRate,
    required this.bio,
    required this.services,
    required this.experienceYears,
    required this.todayEarnings,
    required this.weeklyEarnings,
    required this.monthEarnings,
    required this.lastResetDaily,
    required this.lastResetWeekly,
    required this.lastResetMonthly,
    required this.isApproved,
    required this.status,
  });

  double get price => hourlyRate;

  factory WalkerModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return WalkerModel(
      id: doc.id,
      name: data['name'] ?? '',
      initials: data['initials'] ?? '',
      rating: (data['rating'] ?? 0.0).toDouble(),
      walksCount: data['walksCount'] ?? 0,
      hourlyRate: (data['hourlyRate'] ?? 0.0).toDouble(),
      bio: data['bio'] ?? '',
      services: List<String>.from(data['services'] ?? []),
      experienceYears: data['experienceYears'] ?? 0,
      todayEarnings: (data['todayEarnings'] ?? 0.0).toDouble(),
      weeklyEarnings: (data['weeklyEarnings'] ?? 0.0).toDouble(),
      monthEarnings: (data['monthEarnings'] ?? 0.0).toDouble(),
      lastResetDaily: (data['lastResetDaily'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastResetWeekly: (data['lastResetWeekly'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastResetMonthly: (data['lastResetMonthly'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isApproved: data['isApproved'] ?? false,
      status: data['status'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'initials': initials,
      'rating': rating,
      'walksCount': walksCount,
      'hourlyRate': hourlyRate,
      'bio': bio,
      'services': services,
      'experienceYears': experienceYears,
      'todayEarnings': todayEarnings,
      'weeklyEarnings': weeklyEarnings,
      'monthEarnings': monthEarnings,
      'lastResetDaily': lastResetDaily,
      'lastResetWeekly': lastResetWeekly,
      'lastResetMonthly': lastResetMonthly,
      'isApproved': isApproved,
      'status': status,
    };
  }
}

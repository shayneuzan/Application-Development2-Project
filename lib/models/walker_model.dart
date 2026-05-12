import 'package:cloud_firestore/cloud_firestore.dart';

class WalkerModel {
  final String id;
  final String name;
  final String initials;
  final double rating;
  final int walksCount;
  final int price;
  final String bio;
  final List<String> services;
  final int experienceYears;

  WalkerModel({
    required this.id,
    required this.name,
    required this.initials,
    required this.rating,
    required this.walksCount,
    required this.price,
    required this.bio,
    required this.services,
    required this.experienceYears,
  });

  factory WalkerModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return WalkerModel(
      id: doc.id,
      name: data['name'] ?? '',
      initials: data['initials'] ?? '',
      rating: (data['rating'] ?? 0.0).toDouble(),
      walksCount: data['walksCount'] ?? 0,
      price: data['price'] ?? 0,
      bio: data['bio'] ?? '',
      services: List<String>.from(data['services'] ?? []),
      experienceYears: data['experienceYears'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'initials': initials,
      'rating': rating,
      'walksCount': walksCount,
      'price': price,
      'bio': bio,
      'services': services,
      'experienceYears': experienceYears,
    };
  }
}

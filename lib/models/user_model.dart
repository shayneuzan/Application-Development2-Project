import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String role; // 'owner' or 'walker'
  final String? profileImageUrl;
  final String? phoneNumber;
  final String? address;
  final List<String> favoriteWalkers; // Added favoriteWalkers

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.profileImageUrl,
    this.phoneNumber,
    this.address,
    this.favoriteWalkers = const [],
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] ?? 'owner',
      profileImageUrl: data['profileImageUrl'],
      phoneNumber: data['phoneNumber'],
      address: data['address'],
      favoriteWalkers: List<String>.from(data['favoriteWalkers'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'role': role,
      'profileImageUrl': profileImageUrl,
      'phoneNumber': phoneNumber,
      'address': address,
      'favoriteWalkers': favoriteWalkers,
    };
  }
}

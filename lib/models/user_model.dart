import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String role; // 'owner' or 'walker'
  final String? profileImageUrl;
  final String? phoneNumber;
  final String? address;
  final List<String> favoriteWalkers;
  
  // Settings fields
  final bool pushNotifications;
  final bool emailUpdates;
  final bool darkMode;
  final String language;

  // New fields for multiple addresses and payment methods
  final List<Map<String, dynamic>> savedAddresses;
  final List<Map<String, dynamic>> paymentMethods;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.profileImageUrl,
    this.phoneNumber,
    this.address,
    this.favoriteWalkers = const [],
    this.pushNotifications = true,
    this.emailUpdates = false,
    this.darkMode = false,
    this.language = 'English (US)',
    this.savedAddresses = const [],
    this.paymentMethods = const [],
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
      pushNotifications: data['pushNotifications'] ?? true,
      emailUpdates: data['emailUpdates'] ?? false,
      darkMode: data['darkMode'] ?? false,
      language: data['language'] ?? 'English (US)',
      savedAddresses: List<Map<String, dynamic>>.from(data['savedAddresses'] ?? []),
      paymentMethods: List<Map<String, dynamic>>.from(data['paymentMethods'] ?? []),
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
      'pushNotifications': pushNotifications,
      'emailUpdates': emailUpdates,
      'darkMode': darkMode,
      'language': language,
      'savedAddresses': savedAddresses,
      'paymentMethods': paymentMethods,
    };
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

class PetModel {
  final String id;
  final String ownerId;
  final String name;
  final String breed;
  final int age;
  final String gender;
  final double weight;
  final String description;
  final String imageUrl;

  PetModel({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.breed,
    required this.age,
    required this.gender,
    required this.weight,
    required this.description,
    this.imageUrl = '',
  });

  factory PetModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return PetModel(
      id: doc.id,
      ownerId: data['ownerId'] ?? '',
      name: data['name'] ?? '',
      breed: data['breed'] ?? '',
      age: data['age'] ?? 0,
      gender: data['gender'] ?? '',
      weight: (data['weight'] ?? 0.0).toDouble(),
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ownerId': ownerId,
      'name': name,
      'breed': breed,
      'age': age,
      'gender': gender,
      'weight': weight,
      'description': description,
      'imageUrl': imageUrl,
    };
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../widgets/walker_bottom_nav_bar.dart';
import '../widgets/walker_drawer.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final String? uid = FirebaseAuth.instance.currentUser?.uid;
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('users').doc(uid).get(),
        builder: (context, snapshot) {
          String? name = uid;
          if (snapshot.hasData && snapshot.data!.exists) {
            name = (snapshot.data!.data() as Map<String, dynamic>)['name'] ?? 'Guest';
          }
          return Scaffold(
            appBar: AppBar(
              title: const Text(
                  'Edit Profile', style: TextStyle(color: Colors.white)),
              backgroundColor: Colors.blueAccent,
            ),
            drawer: WalkerDrawer(name: name!),
            body: const Center(
              child: Text(
                  'Profile Edit Screen (WIP)', style: TextStyle(fontSize: 18)),
            ),
            bottomNavigationBar: const WalkerBottomNavBar(currentIndex: 4),
          );
        }
    );
  }
}
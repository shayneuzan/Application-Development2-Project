import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../widgets/walker_bottom_nav_bar.dart';
import '../widgets/walker_drawer.dart';

class RequestScreen extends StatefulWidget {
  const RequestScreen({super.key});

  @override
  State<RequestScreen> createState() => _RequestScreenState();
}

class _RequestScreenState extends State<RequestScreen> {
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
                'Booking Requests', style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.blueAccent,
          ),
          drawer: WalkerDrawer(name: name!),
          body: const Center(
            child: Text('Request Screen (WIP)'),
          ),
          bottomNavigationBar: const WalkerBottomNavBar(currentIndex: 1),
        );
      }
    );
  }
}

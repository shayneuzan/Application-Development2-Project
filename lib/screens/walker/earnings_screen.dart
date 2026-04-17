import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../widgets/walker_bottom_nav_bar.dart';
import '../widgets/walker_drawer.dart';

class EarningsScreen extends StatefulWidget {
  const EarningsScreen({super.key});

  @override
  State<EarningsScreen> createState() => _EarningsScreenState();
}

class _EarningsScreenState extends State<EarningsScreen> {
  final String? uid = FirebaseAuth.instance.currentUser?.uid;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
        builder: (context, snapshot) {
          String? name = uid;
          if (snapshot.hasData && snapshot.data!.exists) {
            name = (snapshot.data!.data() as Map<String, dynamic>)['name'] ?? 'Guest';
          }
          return Scaffold(
            appBar: AppBar(
              title: const Text('Earnings', style: TextStyle(color: Colors.white),),
              backgroundColor: Colors.blueAccent,
              iconTheme: const IconThemeData(color: Colors.white),
            ),
            drawer: WalkerDrawer(name: name!), // TODO: Complete the Earning Screen
            body: const Center(
              child: Text('Earnings Screen (WIP)'),
            ),
            bottomNavigationBar: const WalkerBottomNavBar(currentIndex: 3),
          );
        }
    );
  }
}


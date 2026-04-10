import 'package:flutter/material.dart';
import 'package:pawwalk/widgets/walker_drawer.dart';
import 'package:pawwalk/widgets/walker_bottom_nav_bar.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  // In the future, you can fetch this from Firebase
  final String name = "Jodel Santos";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueAccent,
      ),
      drawer: WalkerDrawer(name: name),
      body: const Center(
        child: Text('Profile Edit Screen (WIP)', style: TextStyle(fontSize: 18)),
      ),
      bottomNavigationBar: const WalkerBottomNavBar(currentIndex: 4),
    );
  }
}
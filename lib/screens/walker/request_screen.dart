import 'package:flutter/material.dart';
import 'package:pawwalk/widgets/walker_drawer.dart';
import 'package:pawwalk/widgets/walker_bottom_nav_bar.dart';

class RequestScreen extends StatefulWidget {
  const RequestScreen({super.key});

  @override
  State<RequestScreen> createState() => _RequestScreenState();
}

class _RequestScreenState extends State<RequestScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Requests', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueAccent,
      ),
      drawer: WalkerDrawer(name: 'Jodel Santos'),
      body: const Center(
        child: Text('Request Screen (WIP)'),
      ),
      bottomNavigationBar: const WalkerBottomNavBar(currentIndex: 1),
    );
  }
}

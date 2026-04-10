import 'package:flutter/material.dart';
import 'package:pawwalk/widgets/walker_drawer.dart';
import 'package:pawwalk/widgets/walker_bottom_nav_bar.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Schedule', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueAccent,
      ),
      drawer: const WalkerDrawer(name: 'Jodel Santos'),
      body: const Center(
        child: Text('Schedule Screen (WIP)'),
      ),
      bottomNavigationBar: WalkerBottomNavBar(currentIndex: 2),
    );
  }
}

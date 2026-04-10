import 'package:flutter/material.dart';
import 'package:pawwalk/widgets/walker_drawer.dart';
import '../../widgets/walker_bottom_nav_bar.dart';

class EarningsScreen extends StatefulWidget {
  const EarningsScreen({super.key});

  @override
  State<EarningsScreen> createState() => _EarningsScreenState();
}

class _EarningsScreenState extends State<EarningsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Earnings'),
        backgroundColor: Colors.blueAccent,
      ),
      drawer: const WalkerDrawer(name: 'Jodel Santos'),
      body: const Center(
        child: Text('Earnings Screen (WIP)'),
      ),
      bottomNavigationBar: const WalkerBottomNavBar(currentIndex: 3),
    );
  }
}


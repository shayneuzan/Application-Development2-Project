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
            title: const Text('Booking Requests', style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.blueAccent,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          drawer: WalkerDrawer(name: name!),
          body: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('requests')
                .where('walkerID', isEqualTo: uid)
                .where('status', isEqualTo: 'pending')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError || !snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Text("No upcoming walks scheduled.",
                    style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
                  ),
                );
              }
              final docs = snapshot.data!.docs;
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: docs.map((doc) {
                    final currentData = doc.data() as Map<String, dynamic>;
                    String ownerName = currentData['petOwner'] ?? "N/A";
                    String petName = currentData['petName'] ?? "N/A";
                    String payment = currentData['payment'] ?? '0';
                    String date = currentData['date'] ?? 'N/A';
                    String time = currentData['time'] ?? 'N/A';
                    String duration = currentData['duration'] ?? 'N/A';
                    String initials = ownerName.trim().isNotEmpty
                        ? ownerName.trim()
                        .split(RegExp(r'\s+'))
                        .where((word) => word.isNotEmpty)
                        .map((word) => word[0].toUpperCase())
                        .take(3)
                        .join()
                        : "?";
                    return Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 22,
                                backgroundColor: const Color(0xFFF5EFE9),
                                child: Text(initials, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(ownerName, style: const TextStyle(fontWeight: FontWeight.bold)),
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              const Icon(Icons.pets, size: 16, color: Colors.grey),
                                              const SizedBox(width: 8),
                                              Text(petName),
                                            ],
                                          ),
                                          const SizedBox(height: 14),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                            width: double.infinity,
                                            decoration: BoxDecoration(
                                              color: Colors.lightBlue.shade50,
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Column(
                                              children: [
                                                Row(
                                                  children: [
                                                    const Icon(Icons.calendar_month_outlined, size: 20, color: Colors.blueAccent),
                                                    const SizedBox(width: 10),
                                                    Text(date, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 13,))
                                                  ]
                                                ),
                                                const SizedBox(height: 12),
                                                Row(
                                                  children: [
                                                    const Icon(Icons.timer_outlined, size: 20, color: Colors.blueAccent),
                                                    const SizedBox(width: 10),
                                                    Text("$time ($duration minutes)", style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 13,)),
                                                  ]
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text("\$$payment", style: const TextStyle(fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16), // Spacing between info and buttons
                          Row(
                            children: [
                              // Decline Button
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    doc.reference.update({'status': 'declined'});
                                  },
                                  icon: const Icon(Icons.close, size: 18, color: Colors.black),
                                  label: const Text("Decline", style: TextStyle(color: Colors.black)),
                                  style: OutlinedButton.styleFrom(
                                    backgroundColor: const Color(0xFFF5EFE9),
                                    side: BorderSide.none,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Accept Button
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    doc.reference.update({'status': 'accepted'});
                                  },
                                  icon: const Icon(Icons.check, size: 18, color: Colors.white),
                                  label: const Text("Accept", style: TextStyle(color: Colors.white)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blueAccent,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          ),
          bottomNavigationBar: const WalkerBottomNavBar(currentIndex: 1),
        );
      },
    );
  }
}

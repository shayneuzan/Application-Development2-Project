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
          ),
          drawer: WalkerDrawer(name: name!),
          body: Column(
            children: [
              Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
            StreamBuilder<QuerySnapshot>(
            // Only show "accepted" walks meant for THIS walker
            stream: FirebaseFirestore.instance.collection('requests')
                .where('walkerID', isEqualTo: uid) // Ensure 'uid' is defined in your widget
                .where('status', isEqualTo: 'pending')
                .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError || !snapshot.hasData ||
                    snapshot.data!.docs.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20.0),
                    child: Center(
                      child: Text("No upcoming walks scheduled.",
                        style: TextStyle(
                            color: Colors.grey, fontStyle: FontStyle.italic),),
                    ),
                  );
                }
                // Get the data from the first document in the list of upcoming walk
                final docs = snapshot.data!.docs;
                return ListView.builder(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    String ownerName = data['petOwner'] ?? "Unknown Owner";
                    String petName = data['petName'] ?? "Unknown Pet";
                    String payment = data['payment'] ?? '0';
                    String initials = ownerName.trim().isNotEmpty ? ownerName.trim()
                        .split(RegExp(r'\s+')) // split by any whitespace
                        .where((word) => word.isNotEmpty)
                        .map((word) => word[0].toUpperCase())
                        .take(3) // first, middle, last (max 3)
                        .join() : "?";
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
                              // First letters (Initials) in a circle
                              CircleAvatar(
                                radius: 22,
                                backgroundColor: const Color(0xFFF5EFE9),
                                child: Text(initials, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),),
                              ),
                              const SizedBox(width: 12),
                              // Owner Name and Pet Name
                              Expanded(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(ownerName, style: TextStyle(fontWeight: FontWeight.bold)),
                                        SizedBox(height: 8,),
                                        Row(
                                          children: [
                                            Icon(Icons.pets, size: 16, color: Colors.grey),
                                            SizedBox(width: 8,),
                                            Text(petName),
                                          ]
                                        ),
                                        SizedBox(height: 14,),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Colors.green.shade100,
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: const Text("N/A", style: TextStyle(color: Colors.green,fontWeight: FontWeight.w600,fontSize: 12,),),
                                        ),
                                      ]
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text("\$$payment", style: TextStyle(fontWeight: FontWeight.bold)),
                                        SizedBox(height: 8,),
                                      ]
                                    ),
                                  ]
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
                })
              ]
            ),
            ]
          ),
          bottomNavigationBar: const WalkerBottomNavBar(currentIndex: 1),
        );
      }
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pawwalk/screens/walker/earnings_screen.dart';
import '../widgets/walker_bottom_nav_bar.dart';
import '../widgets/walker_drawer.dart';
import 'package:intl/intl.dart';

class WalkerHomeScreen extends StatefulWidget {
  const WalkerHomeScreen({super.key});

  @override
  State<WalkerHomeScreen> createState() => _WalkerHomeScreenState();
}

class _WalkerHomeScreenState extends State<WalkerHomeScreen> {
  // // Gets the current user's ID
  final String? uid = FirebaseAuth.instance.currentUser?.uid;
  final DateTime _presentDay = DateTime.now();
  bool _isTimedOut = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _isTimedOut = true;
        });
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
        builder: (context, snapshot) {
          String? name = uid;
          String? todayEarnings = '0';
          String? weeklyEarnings = '0';
          if (snapshot.hasData && snapshot.data!.exists) {
            final data = snapshot.data!.data() as Map<String, dynamic>;
            name = data['name'] ?? 'Guest';
            todayEarnings = data['todayEarnings'] ?? '0';
            weeklyEarnings = data['weeklyEarnings'] ?? '0';
          }
          return Scaffold(
            appBar: AppBar(
              title: const Text('Dashboard', style: TextStyle(color: Colors.white)),
              backgroundColor: Colors.blueAccent,
              iconTheme: const IconThemeData(color: Colors.white),
            ),
            drawer: WalkerDrawer(name: name!,),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Hello, $name!', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),),
                      const SizedBox(height: 10,),
                      const Text('Here\'s your activity overview'),
                      const SizedBox(height: 10,),
                      // Today's Earnings
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4),),
                          ],
                        ),
                        child: Column(
                            children: [
                              Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text('Today\'s Earnings', style: TextStyle(color: Colors.white),),
                                        const SizedBox(height: 4,),
                                        Text('\$$todayEarnings', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),)
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        const Text('This Week',
                                          style: TextStyle(color: Colors.white),),
                                        const SizedBox(height: 4,),
                                        Text('\$$weeklyEarnings', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),)
                                      ],
                                    ),
                                  ]
                              ),
                              const SizedBox(height: 20,),
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.pushReplacement(
                                      context,
                                      PageRouteBuilder(
                                        pageBuilder: (context, animation1, animation2) => EarningsScreen(),
                                        transitionDuration: Duration.zero, // Instant transition for smooth nav feel
                                        reverseTransitionDuration: Duration.zero,
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.attach_money, color: Colors.black, size: 18),
                                  label: const Text("View All Earnings", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12),),
                                  ),
                                ),
                              ),
                            ]
                        ),
                      ),
                      const SizedBox(height: 20,),
                      // Upcoming Walks
                      const Text('Upcoming Walks', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),),
                      const SizedBox(height: 10,),
                      // Walker Card
                      StreamBuilder<QuerySnapshot>(
                      // Only show "accepted" walks meant for THIS walker
                      stream: FirebaseFirestore.instance.collection('requests')
                          .where('walkerID', isEqualTo: uid) // Ensure 'uid' is defined in your widget
                          .where('status', isEqualTo: 'accepted')
                          .where('date', isGreaterThanOrEqualTo: DateFormat('yyyy-MM-dd').format(_presentDay))
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 20.0),
                            child: Center(
                              child: Text("No upcoming walks scheduled.", style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),),
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
                                    children: [
                                      const CircleAvatar(
                                        radius: 25,
                                        backgroundColor: Color(0xFFF5EFE9),
                                        child: Icon(Icons.pets, color: Colors.black, size: 24),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(data['petName'] ?? "Unknown Pet", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
                                            Text("Owner: ${data['petOwner'] ?? 'Unknown'}", style: const TextStyle(color: Colors.grey, fontSize: 14),),
                                          ],
                                        ),
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Text(data['time'] ?? "00:00", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                          ),
                                          Text(
                                            data['date'] ?? "No Date",
                                            style: const TextStyle(color: Colors.grey, fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const Divider(height: 24, thickness: 1),
                                  Row(
                                    children: [
                                      const Icon(Icons.access_time, size: 16, color: Colors.grey),
                                      const SizedBox(width: 4),
                                      Text("${data['duration'] ?? '0'} min", style: const TextStyle(color: Colors.grey, fontSize: 14),),
                                      const Spacer(),
                                      Text("\$${data['payment'] ?? '0'}", style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 16,),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      }
                    ),
                      // End of Walk Card
                      // New Requests
                      StreamBuilder<QuerySnapshot>( // Calculate the number of pending requests
                        stream: FirebaseFirestore.instance
                            .collection('requests')
                            .where('walkerID', isEqualTo: uid)
                            .where('status', isEqualTo: 'pending')
                            .where('date', isGreaterThanOrEqualTo: DateFormat('yyyy-MM-dd'))
                            .snapshots(),
                        builder: (context, snapshot) {
                        int requestCount = snapshot.hasData ? snapshot.data!.docs.length : 0;
                        return Row(
                          children: [
                            const Text("New Requests", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),),
                            const SizedBox(width: 8),
                            // Only show the red circle if there are 1 or more requests
                            if (requestCount > 0)
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle,),
                                child: Text("$requestCount", style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold,),),
                            ),
                          ],
                        );
                      },
                      ),
                      const SizedBox(height: 10,),
                      // Request Card
                      StreamBuilder<QuerySnapshot>(
                        // Filter: Only show "pending" requests meant for THIS walker
                        stream: FirebaseFirestore.instance
                            .collection('requests')
                            .where('walkerID', isEqualTo: uid)
                            .where('status', isEqualTo: 'pending')
                            .where('date', isGreaterThanOrEqualTo: DateFormat('yyyy-MM-dd'))
                            .limit(3)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting && !_isTimedOut) {
                            return Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          if (!snapshot.hasData || snapshot.data == null || snapshot.data!.docs.isEmpty && !_isTimedOut) {
                            return const Center(
                              child: Text('No Upcoming Requests'),
                            );
                          }
                          // Get the data from the first document in the list
                          final doc = snapshot.data!.docs.first;
                          final data = doc.data() as Map<String, dynamic>;
                          return Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: const Border(left: BorderSide(color: Colors.blue, width: 5)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(data['ownerName'] ?? "Unknown Owner", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                    Text("\$${data['payment'] ?? '0'}", style: const TextStyle(color: Colors.blue, fontSize: 18, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                Text("${data['petName']} - ${data['duration']} min walk", style: const TextStyle(color: Colors.grey)),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                                    const SizedBox(width: 4),
                                    Text("${data['date']} at ${data['time']}", style: const TextStyle(color: Colors.grey)),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    // Decline Button
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        onPressed: () {
                                          // Update status to 'declined' in Firebase
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
                                          // Update status to 'accepted' in Firebase
                                          doc.reference.update({'status': 'accepted'});
                                        },
                                        icon: const Icon(Icons.check, size: 18, color: Colors.white),
                                        label: const Text("Accept", style: TextStyle(color: Colors.white)),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blue,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      )
                      // End of Request Card
                    ]
                ),
              ),
            ),
            bottomNavigationBar: const WalkerBottomNavBar(currentIndex: 0),
          );
        }
    );
  }
}

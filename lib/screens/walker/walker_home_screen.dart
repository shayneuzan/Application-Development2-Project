import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../widgets/walker_bottom_nav_bar.dart';
import '../widgets/walker_drawer.dart';


// void main() async {
//   runApp(
//       MaterialApp(
//           home: WalkerHomeScreen()
//       )
//   );
// }

class WalkerHomeScreen extends StatefulWidget {
  const WalkerHomeScreen({super.key});

  @override
  State<WalkerHomeScreen> createState() => _WalkerHomeScreenState();
}

class _WalkerHomeScreenState extends State<WalkerHomeScreen> {
  // // Gets the current user's ID
  final String? uid = FirebaseAuth.instance.currentUser?.uid;
  // Will be saved for later
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
          drawer: WalkerDrawer(name: name!,),
          body: Padding( // TODO: NOT REAL FUNCTION JUST FOR DISPLAY. REMOVE LATER AS FOR OTHER SCREENS
            padding: const EdgeInsets.all(16.0),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Hello, $name!', style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 20),),
                  SizedBox(height: 10,),
                  Text('Here\'s your activity overview'),
                  SizedBox(height: 10,),

                  // Today's Earnings TODO: Replace with actual data
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(12),
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
                              mainAxisAlignment: MainAxisAlignment
                                  .spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment
                                      .start,
                                  children: [
                                    Text('Today\'s Earnings',
                                      style: TextStyle(color: Colors.white),),
                                    SizedBox(height: 4,),
                                    Text('\$75', style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20),)
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text('This Week',
                                      style: TextStyle(color: Colors.white),),
                                    SizedBox(height: 4,),
                                    Text('\$425', style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20),)
                                  ],
                                ),
                              ]
                          ),
                          const SizedBox(height: 20,),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton.icon(
                              onPressed: () {},
                              icon: const Icon(
                                  Icons.attach_money, color: Colors.black,
                                  size: 18),
                              label: const Text(
                                "View All Earnings",
                                style: TextStyle(color: Colors.black,
                                    fontWeight: FontWeight.bold),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ]
                    ),
                  ),
                  SizedBox(height: 20,),

                  // Upcoming Walks TODO: Replace with actual data
                  Text('Upcoming Walks', style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 15),),
                  SizedBox(height: 10,),
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      // Matches your dashboard style
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
                              child: Icon(Icons.pets, color: Colors.black,
                                  size: 24), // Dog Symbol
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Max", style: TextStyle(fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                  ),
                                  Text("Owner: John Smith", style: TextStyle(
                                      color: Colors.grey, fontSize: 14),),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: const [
                                Text("10:00", style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14),),
                                Text("2026-03-25", style: TextStyle(
                                    color: Colors.grey, fontSize: 12),),
                              ],
                            ),
                          ],
                        ),
                        const Divider(height: 24, thickness: 1),
                        Row(
                          children: [
                            Icon(Icons.access_time, size: 16, color: Colors
                                .grey),
                            SizedBox(width: 4),
                            Text("60 min", style: TextStyle(
                                color: Colors.grey, fontSize: 14)),
                            SizedBox(width: 16),
                            Text("\$25", style: TextStyle(color: Colors.blue,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,),),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // New Requests
                  Row(
                    children: [
                      Text("New Requests", style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15),),
                      SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Colors.red, shape: BoxShape.circle,),
                        child: const Text("1", style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold),),
                      ),
                    ],
                  ),
                  SizedBox(height: 10,),
                  // Request Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: const Border(
                        left: BorderSide(color: Colors.blue, width: 5),),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Lisa Brown", style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                            Text("\$19", style: TextStyle(color: Colors.blue,
                                fontSize: 18,
                                fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Text("Rocky - 45 min walk",
                            style: TextStyle(color: Colors.grey)),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.calendar_today, size: 16, color: Colors
                                .grey),
                            SizedBox(width: 4),
                            Text("2026-03-24 at 09:00", style: TextStyle(
                                color: Colors.grey)),
                          ],
                        ),
                        SizedBox(height: 16),
                        Row(
                          children: [
                            // Decline Button
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {},
                                icon: Icon(Icons.close, size: 18,
                                    color: Colors.black),
                                label: Text("Decline",
                                    style: TextStyle(color: Colors.black)),
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: Color(0xFFF5EFE9),
                                  side: BorderSide.none,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          12)),
                                ),
                              ),
                            ),
                            SizedBox(width: 12),
                            // Accept Button
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {},
                                icon: const Icon(Icons.check, size: 18,
                                    color: Colors.white),
                                label: const Text("Accept",
                                    style: TextStyle(color: Colors.white)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          12)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                ]
            ),
          ),
          bottomNavigationBar: const WalkerBottomNavBar(currentIndex: 0),
        );
      }
    );
  }
}

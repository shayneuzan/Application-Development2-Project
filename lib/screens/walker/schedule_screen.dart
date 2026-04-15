import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

import '../widgets/walker_bottom_nav_bar.dart';
import '../widgets/walker_drawer.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  final String? uid = FirebaseAuth.instance.currentUser?.uid;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
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
            title: const Text('Your Schedule', style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.blueAccent,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          drawer: WalkerDrawer(name: name!),
          body: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Calendar
                  TableCalendar(
                    firstDay: DateTime.utc(2020, 1, 1),
                    lastDay: DateTime.utc(2100, 3, 31),
                    focusedDay: _focusedDay,
                    selectedDayPredicate: (day) {
                      return isSameDay(_selectedDay, day);
                    },
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                      });
                    },
                    onPageChanged: (focusedDay) {
                      _focusedDay = focusedDay;
                    },
                    calendarStyle: const CalendarStyle(
                      selectedDecoration: BoxDecoration(
                        color: Colors.blueAccent,
                        shape: BoxShape.circle,
                      ),
                      todayDecoration: BoxDecoration(
                        color: Colors.lightBlueAccent,
                        shape: BoxShape.circle,
                      ),
                    ),
                    headerStyle: const HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                      titleTextStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ),
                  // Error Message if no date is selected
                  const SizedBox(height: 20),
                  _selectedDay == null
                      ? const Text("Select a date to see walks", style: TextStyle(fontSize: 18))
                      : Text("Your Upcoming Walks for ${DateFormat('MMMM d, yyyy')
                      .format(_selectedDay!)}", style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold,
                        color: Colors.black87
                      ),
                  ),
                  const SizedBox(height: 10),
                  if (_selectedDay != null)
                  // List of walks for the selected date
                  const SizedBox(height: 10),
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('requests')
                    .where('walkerID', isEqualTo: uid)
                    .where('status', isEqualTo: 'accepted')
                    .where('date', isEqualTo: DateFormat('yyyy-MM-dd')
                    .format(_selectedDay!))
                    .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(40.0),
                            child: Column(
                              children: [
                                Icon(Icons.event_busy, size: 60, color: Colors.grey.shade400),
                                const SizedBox(height: 10),
                                const Text("No walks scheduled for this day", style: TextStyle(color: Colors.grey)),
                              ],
                            ),
                          ),
                        );
                      } else {
                        // List of walks for the selected date
                        final docs = snapshot.data!.docs;
                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: snapshot.data!.docs.length,
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
                                      const CircleAvatar( // Profile Picture
                                        radius: 25,
                                        backgroundColor: Color(0xFFF5EFE9),
                                        child: Icon(Icons.pets, color: Colors.black, size: 24),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column( // Pet Name & Owner
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(data['petName'] ?? "Unknown Pet", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
                                                Text("\$${data['payment'] ?? '0'}", style: const TextStyle(fontSize: 18, color: Colors.blue, fontWeight: FontWeight.bold,)),
                                              ],
                                            ),
                                            Text("${data['petOwner'] ?? 'Unknown'}", style: const TextStyle(color: Colors.grey, fontSize: 14),),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Divider(height: 24, thickness: 1),
                                  Row(
                                    children: [
                                      const Icon(Icons.access_time, size: 16, color: Colors.grey),
                                      const SizedBox(width: 4),
                                      Text("${data['time'] ?? '00:00'}    ${data['duration'] ?? '0'} min", style: const TextStyle(color: Colors.grey, fontSize: 15),),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          }
                        );
                      }
                    }
                  ),
                ],
              ),
            ),
          ),
          bottomNavigationBar: WalkerBottomNavBar(currentIndex: 2),
        );
      }
    );
  }
}

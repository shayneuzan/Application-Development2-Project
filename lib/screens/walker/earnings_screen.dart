import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart'; // For Charts Feature
import '../widgets/walker_bottom_nav_bar.dart';
import '../widgets/walker_drawer.dart';
import '../widgets/walker_notification_icon.dart';
import '/services/firestore_service.dart';

class EarningsScreen extends StatefulWidget {
  const EarningsScreen({super.key});

  @override
  State<EarningsScreen> createState() => _EarningsScreenState();
}

class _EarningsScreenState extends State<EarningsScreen> {
  final String? uid = FirebaseAuth.instance.currentUser?.uid;
  final FirestoreService _firestoreService = FirestoreService();
  @override
  Widget build(BuildContext context) {
    final double containerHeightForTop = 120;
    final double containerWidthForTop = 120;

    return StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
        builder: (context, snapshot) {
          final userData = snapshot.data?.data() as Map<String, dynamic>? ?? {};
          // Background check: This resets the numbers if the date has changed
          _firestoreService.checkAndResetEarnings(userData, uid!);
          num today = userData['todayEarnings'] ?? 0.0;
          num week = userData['weeklyEarnings'] ?? 0.0;
          num month = userData['monthEarnings'] ?? 0.0;
          String name = userData['name'] ?? 'Guest';
          return Scaffold(
            appBar: AppBar(
              title: const Text('Earnings', style: TextStyle(color: Colors.white),),
              backgroundColor: const Color(0xFF2563EB),
              iconTheme: const IconThemeData(color: Colors.white),
              actions: [
                WalkerNotificationIcon(),
                const SizedBox(width: 8),
              ],
            ),
            drawer: WalkerDrawer(name: name),
            body: Padding(
              padding: EdgeInsets.all(13.5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Today, Week and Month Earnings
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: containerWidthForTop,
                          height: containerHeightForTop,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(color: Colors.black)
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Today',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                (today).toDouble() >= 1000
                                    ? '\$${((today) / 1000).toStringAsFixed(1)}K'
                                    : '\$${(today).toStringAsFixed(2).replaceAll('.00', '')}',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2563EB),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 12,),
                        Container(
                          width: containerWidthForTop,
                          height: containerHeightForTop,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(color: Colors.black)
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'This Week',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                (week).toDouble() >= 1000
                                    ? '\$${((week) / 1000).toStringAsFixed(1)}K'
                                    : '\$${(week).toStringAsFixed(2).replaceAll('.00', '')}',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2563EB),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 12,),
                        Container(
                          width: containerWidthForTop,
                          height: containerHeightForTop,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(color: Colors.black)
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'This Month',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(height: 10),
                              Text((month).toDouble() >= 1000
                                  ? '\$${((month) / 1000).toStringAsFixed(1)}K'
                                  : '\$${(month).toStringAsFixed(2).replaceAll('.00', '')}',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2563EB),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20,),
                  // Weekly Overview
                  Container(
                    width: double.infinity,
                    height: 275,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.black)
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Weekly Overview', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10,),
                        Expanded(
                          child: StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('users')
                                .doc(uid)
                                .collection('earnings')
                                .orderBy('date', descending: true)
                                .limit(7)
                                .snapshots(),
                            builder: (context, earnSnapshot) {
                              // Safe check for chart data
                              if (!earnSnapshot.hasData) {
                                return const Center(child: CircularProgressIndicator());
                              }
                              List<_ChartData> chartData = earnSnapshot.data!.docs.map((doc) {
                                final d = doc.data() as Map<String, dynamic>;
                                return _ChartData(
                                    d['dayOfWeek'] ?? '',
                                    (d['amount'] ?? 0.0).toDouble()
                                );
                              }).toList().reversed.toList(); // Reverse to show Mon -> Sun
                              return SfCartesianChart(
                                primaryXAxis: CategoryAxis(),
                                tooltipBehavior: TooltipBehavior(
                                  enable: true,
                                  header: 'Earnings',
                                  canShowMarker: false,
                                  format: 'point.x : \$point.y', // Shows "MON : $12"
                                ),
                                series: <CartesianSeries<_ChartData, String>>[
                                  ColumnSeries<_ChartData, String>(
                                    dataSource: chartData,
                                    xValueMapper: (_ChartData data, _) => data.day,
                                    yValueMapper: (_ChartData data, _) => data.receivedAmount,
                                    color: const Color.fromRGBO(8, 142, 255, 1),
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                                    borderWidth: 2,
                                    borderColor: Colors.black,
                                    dataLabelSettings: const DataLabelSettings(
                                      isVisible: true,
                                      labelAlignment: ChartDataLabelAlignment.outer,
                                      textStyle: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ]
                    ),
                  ),
                  const SizedBox(height: 20,),
                  Text('Recent Completed Walks', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                        .collection('users')
                        .doc(uid)
                        .collection('earnings')
                        .orderBy('date', descending: true)
                        .snapshots(),
                      builder: (context, walkSnapshot) {
                        if (!walkSnapshot.hasData) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        return ListView.builder(
                          itemCount: walkSnapshot.data!.docs.length,
                          itemBuilder: (context, index) {
                            var doc = walkSnapshot.data!.docs[index];
                            String date = DateFormat('MMMM d, yyyy').format(doc['date'].toDate());
                            num amt = doc['amount'] ?? 0;
                            return Card(
                              elevation: 2,
                              margin: const EdgeInsets.symmetric(vertical: 5),
                              child: ListTile(
                                leading: const Icon(Icons.pets, color: Color(0xFF2563EB)),
                                title: Text('$date, (${doc['dayOfWeek']})'),
                                subtitle: Text('${doc['walkTitle']}'),
                                trailing: Text(
                                  '+\$${amt.toStringAsFixed(2).replaceAll('.00', '')}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                      fontSize: 16
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ]
              ),
            ),
            bottomNavigationBar: const WalkerBottomNavBar(currentIndex: 3),
          );
        }
    );
  }
}

class _ChartData {
  _ChartData(this.day, this.receivedAmount);
  final String day;
  final double receivedAmount;
}



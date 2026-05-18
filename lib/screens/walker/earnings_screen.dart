import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../l10n/generated/app_localizations.dart';
import '../widgets/walker_bottom_nav_bar.dart';
import '../widgets/walker_drawer.dart';
import '../widgets/walker_notification_icon.dart';
import '../../services/firestore_service.dart';

class EarningsScreen extends StatefulWidget {
  const EarningsScreen({super.key});

  @override
  State<EarningsScreen> createState() => _EarningsScreenState();
}

class _EarningsScreenState extends State<EarningsScreen> {
  final String? uid = FirebaseAuth.instance.currentUser?.uid;
  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    if (uid != null) {
      FirebaseFirestore.instance.collection('users').doc(uid).get().then((doc) {
        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>;
          _firestoreService.checkAndResetEarnings(data, uid!);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const double containerHeightForTop = 120;
    const double containerWidthForTop = 120;
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final borderColor = isDarkMode ? Colors.white10 : Colors.black12;

    return StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
        builder: (context, snapshot) {
          final userData = snapshot.data?.data() as Map<String, dynamic>? ?? {};
          num today = userData['todayEarnings'] ?? 0.0;
          num week = userData['weeklyEarnings'] ?? 0.0;
          num month = userData['monthEarnings'] ?? 0.0;
          String name = userData['name'] ?? 'Guest';

          return Scaffold(
            appBar: AppBar(
              title: Text(loc.earnings, style: const TextStyle(color: Colors.white),),
              backgroundColor: const Color(0xFF2563EB),
              iconTheme: const IconThemeData(color: Colors.white),
              actions: const [
                NotificationIcon(),
                SizedBox(width: 8),
              ],
            ),
            drawer: WalkerDrawer(name: name),
            body: Padding(
              padding: const EdgeInsets.all(13.5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildEarningsCard(theme, borderColor, loc.today, today, containerWidthForTop, containerHeightForTop),
                        const SizedBox(width: 12,),
                        _buildEarningsCard(theme, borderColor, loc.thisWeek, week, containerWidthForTop, containerHeightForTop),
                        const SizedBox(width: 12,),
                        _buildEarningsCard(theme, borderColor, loc.thisMonth, month, containerWidthForTop, containerHeightForTop),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20,),
                  Container(
                    width: double.infinity,
                    height: 275,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: borderColor)
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(loc.weeklyOverview, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
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
                              if (!earnSnapshot.hasData) {
                                return const Center(child: CircularProgressIndicator());
                              }
                              List<_ChartData> chartData = earnSnapshot.data!.docs.map((doc) {
                                final d = doc.data() as Map<String, dynamic>;
                                return _ChartData(
                                    d['dayOfWeek'] ?? '',
                                    (d['amount'] ?? 0.0).toDouble()
                                );
                              }).toList().reversed.toList();
                              return SfCartesianChart(
                                plotAreaBorderWidth: 0,
                                primaryXAxis: CategoryAxis(
                                  labelStyle: TextStyle(color: theme.textTheme.bodySmall?.color),
                                  majorGridLines: const MajorGridLines(width: 0),
                                ),
                                primaryYAxis: NumericAxis(
                                  labelStyle: TextStyle(color: theme.textTheme.bodySmall?.color),
                                  axisLine: const AxisLine(width: 0),
                                  majorTickLines: const MajorTickLines(size: 0),
                                ),
                                tooltipBehavior: TooltipBehavior(
                                  enable: true,
                                  header: loc.earnings,
                                  format: 'point.x : \$point.y',
                                ),
                                series: <CartesianSeries<_ChartData, String>>[
                                  ColumnSeries<_ChartData, String>(
                                    dataSource: chartData,
                                    xValueMapper: (_ChartData data, _) => data.day,
                                    yValueMapper: (_ChartData data, _) => data.receivedAmount,
                                    color: const Color(0xFF2563EB),
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                                    borderWidth: 1,
                                    borderColor: isDarkMode ? Colors.white30 : Colors.black12,
                                    dataLabelSettings: DataLabelSettings(
                                      isVisible: true,
                                      labelAlignment: ChartDataLabelAlignment.outer,
                                      textStyle: TextStyle(
                                          color: theme.textTheme.bodyMedium?.color,
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
                  Text(loc.recentWalks, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
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
                              elevation: 1,
                              margin: const EdgeInsets.symmetric(vertical: 5),
                              child: ListTile(
                                leading: const Icon(Icons.pets, color: Color(0xFF2563EB)),
                                title: Text('$date, (${doc['dayOfWeek']})', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                                subtitle: Text('${doc['walkTitle']}', style: TextStyle(color: theme.hintColor)),
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

  Widget _buildEarningsCard(ThemeData theme, Color borderColor, String label, num amount, double width, double height) {
    return Container(
      width: width,
      height: height,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: borderColor)
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 10),
          Text(
            amount.toDouble() >= 1000
                ? '\$${(amount / 1000).toStringAsFixed(1)}K'
                : '\$${amount.toStringAsFixed(2).replaceAll('.00', '')}',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2563EB),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartData {
  _ChartData(this.day, this.receivedAmount);
  final String day;
  final double receivedAmount;
}

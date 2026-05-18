import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pawwalk/screens/walker/earnings_screen.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../models/booking_model.dart';
import '../widgets/walker_bottom_nav_bar.dart';
import '../widgets/walker_drawer.dart';
import 'package:intl/intl.dart';
import '../chat/chat_service.dart';
import '../auth/login_screen.dart';
import '../widgets/walker_notification_icon.dart';
import '/services/firestore_service.dart';
import '../shared/notification_screen.dart';

class WalkerHomeScreen extends StatefulWidget {
  const WalkerHomeScreen({super.key});

  @override
  State<WalkerHomeScreen> createState() => _WalkerHomeScreenState();
}

class _WalkerHomeScreenState extends State<WalkerHomeScreen> with SingleTickerProviderStateMixin {
  final String? uid = FirebaseAuth.instance.currentUser?.uid;
  final ChatService _chatService = ChatService();
  final FirestoreService _firestoreService = FirestoreService();

  final DateTime _presentDay = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  bool _isTimedOut = false;
  StreamSubscription? _statusSub;
  StreamSubscription? _notifSub;
  final Set<String> _seenNotifIds = {};
  OverlayEntry? _bannerEntry;
  AnimationController? _slideController;
  Timer? _autoDismissTimer;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) setState(() => _isTimedOut = true);
    });
    if (uid != null) {
      _firestoreService.initResetFields(uid!);
    }


    // Listen to the user's document and sign them out if they get suspended
    if (uid != null) {
      _statusSub = FirebaseFirestore.instance
          .collection('users').doc(uid).snapshots().listen((doc) {
          if (!doc.exists || !mounted) return;
          final status = (doc.data() as Map<String, dynamic>)['status'] ?? 'active';
          if (status == 'suspended') {
            FirebaseAuth.instance.signOut();
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            );
          }
      });
    }

    _initNotifListener();
  }

  @override
  void dispose() {
    _statusSub?.cancel();
    _notifSub?.cancel();
    _autoDismissTimer?.cancel();
    _bannerEntry?.remove();
    _bannerEntry = null;
    _slideController?.dispose();
    super.dispose();
  }

  void _initNotifListener() {
    if (uid == null) return;

    bool isFirstSnapshot = true;

    _notifSub = FirebaseFirestore.instance
        .collection('notifications')
        .where('receiverID', isEqualTo: uid)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .listen((snapshot) {
      if (isFirstSnapshot) {
        for (final doc in snapshot.docs) {
          _seenNotifIds.add(doc.id);
        }
        isFirstSnapshot = false;
        return;
      }
      for (final change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added &&
            !_seenNotifIds.contains(change.doc.id)) {
          _seenNotifIds.add(change.doc.id);
          final data = change.doc.data() as Map<String, dynamic>;
          final title = (data['title'] as String?) ?? '';
          final message = (data['message'] as String?) ?? '';
          if (mounted) _showBanner(title, message);
        }
      }
    });
  }

  void _showBanner(String title, String message) {
    _dismissBanner();

    _slideController?.dispose();
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    final slideAnim = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController!, curve: Curves.easeOut));

    _bannerEntry = OverlayEntry(
      builder: (ctx) => Positioned(
        top: MediaQuery.of(ctx).padding.top + 8,
        left: 16,
        right: 16,
        child: SlideTransition(
          position: slideAnim,
          child: Material(
            color: Colors.transparent,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF2563EB),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 4)),
                ],
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  _dismissBanner();
                  if (mounted) {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationScreen()));
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                            const SizedBox(height: 2),
                            Text(message, style: const TextStyle(color: Colors.white70, fontSize: 13), maxLines: 2, overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: _dismissBanner,
                        child: const Icon(Icons.close, color: Colors.white, size: 18),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_bannerEntry!);
    _slideController!.forward();
    _autoDismissTimer = Timer(const Duration(seconds: 4), _dismissBanner);
  }

  void _dismissBanner() {
    _autoDismissTimer?.cancel();
    _autoDismissTimer = null;
    _bannerEntry?.remove();
    _bannerEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
        builder: (context, snapshot) {
          String? name = "Walker";
          double todayEarnings = 0;
          double weeklyEarnings = 0;
          bool isPending = false;
          if (snapshot.hasData && snapshot.data!.exists) {
            final data = snapshot.data!.data() as Map<String, dynamic>;
            // Check and reset earnings
            _firestoreService.checkAndResetEarnings(data, uid!);

            // Update earnings and name
            name = data['name'] ?? 'Guest';
            todayEarnings = (data['todayEarnings'] ?? 0).toDouble();
            weeklyEarnings = (data['weeklyEarnings'] ?? 0).toDouble();
            isPending = !(data['isApproved'] ?? false) || data['status'] == 'pending';
          }
          return Scaffold(
            appBar: AppBar(
              title: Text(l10n.dashboard, style: const TextStyle(color: Colors.white)),
              backgroundColor: const Color(0xFF2563EB),
              iconTheme: const IconThemeData(color: Colors.white),
              actions: const [
                NotificationIcon(),
                SizedBox(width: 8,)
              ],
            ),
            drawer: WalkerDrawer(name: name!),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // Show banner if the walker has not been approved yet
                      if (isPending)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFF59E0B)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.access_time, color: Color(0xFFD97706), size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  l10n.accountPendingApproval,
                                  style: const TextStyle(color: Color(0xFF92400E), fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                        ),

                      Text(l10n.helloUser(name), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),),
                      const SizedBox(height: 10,),
                      Text(l10n.activityOverview),
                      const SizedBox(height: 10,),
                      // Earnings Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2563EB),
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
                                        Text(l10n.todaysEarnings, style: const TextStyle(color: Colors.white),),
                                        const SizedBox(height: 4,),
                                        Text('\$${todayEarnings.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),)
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(l10n.thisWeek, style: const TextStyle(color: Colors.white),),
                                        const SizedBox(height: 4,),
                                        Text('\$${weeklyEarnings.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),)
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
                                      MaterialPageRoute(builder: (context) => const EarningsScreen()),
                                    );
                                  },
                                  icon: Icon(Icons.attach_money, color: isDarkMode ? Colors.white : const Color(0xFF2563EB), size: 18),
                                  label: Text(l10n.viewAllEarnings, style: TextStyle(color: isDarkMode ? Colors.white : const Color(0xFF2563EB), fontWeight: FontWeight.bold),),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: theme.cardColor,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12),),
                                  ),
                                ),
                              ),
                            ]
                        ),
                      ),
                      const SizedBox(height: 20,),
                      Text(l10n.upcomingWalks, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),),
                      const SizedBox(height: 10,),
                      // Upcoming Walks
                      StreamBuilder<List<BookingModel>>(
                      stream: _firestoreService.getUpcomingWalksByWalkerID(uid!, _presentDay),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20.0),
                            child: Center(child: Text(l10n.noUpcomingWalks, style: const TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),),),
                          );
                        }
                        final requests = snapshot.data!;
                        return ListView.builder(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: requests.length,
                          itemBuilder: (context, index) {
                            final data = requests[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      const CircleAvatar(radius: 25, backgroundColor: Color(0xFFF1F5F9), child: Icon(Icons.pets, color: Colors.black, size: 24)),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(data.petName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                            Text(l10n.ownerWithName(data.ownerName), style: const TextStyle(color: Colors.grey, fontSize: 14)),
                                          ],
                                        ),
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Text(data.time, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                          Text(DateFormat('yyyy-MM-dd').format(data.date), style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const Divider(height: 24, thickness: 1),
                                  Row(
                                    children: [
                                      const Icon(Icons.access_time, size: 16, color: Colors.grey),
                                      const SizedBox(width: 4),
                                      Text(l10n.durationMinutes(data.duration), style: const TextStyle(color: Colors.grey, fontSize: 14)),
                                      const Spacer(),
                                      Text("\$${data.totalPrice}", style: const TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.bold, fontSize: 16)),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      }
                    ),
                      const SizedBox(height: 20,),
                      Text(l10n.newRequests, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),),
                      const SizedBox(height: 10,),
                      // New Requests
                      StreamBuilder<List<BookingModel>>(
                        stream: _firestoreService.getThreePendingRequestsByWalkerID(uid!, _presentDay),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting && !_isTimedOut) return const Center(child: CircularProgressIndicator());
                          if (!snapshot.hasData || snapshot.data!.isEmpty) return Center(child: Text(l10n.noUpcomingRequests));
                          final requests = snapshot.data!;
                          return ListView.separated(
                            shrinkWrap: true, 
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: requests.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final data = requests[index];
                              return Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: const Border(left: BorderSide(color: Color(0xFF2563EB), width: 5)),
                                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(data.ownerName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                        Text("\$${data.totalPrice}", style: const TextStyle(color: Color(0xFF2563EB), fontSize: 18, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                    Text(l10n.petDurationWalk(data.petName, data.duration), style: const TextStyle(color: Colors.grey)),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                                        const SizedBox(width: 4),
                                        Text("${DateFormat('yyyy-MM-dd').format(data.date)} at ${data.time}", style: const TextStyle(color: Colors.grey)),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: OutlinedButton(
                                            onPressed: () async {
                                              String ownerID = data.ownerId;
                                              String petName = data.petName;
                                              String ownerName = data.ownerName;

                                              await _firestoreService.updateBookingStatus(data.id, 'declined');
                                              if (ownerID.isNotEmpty) {
                                                // Notify Owner
                                                _firestoreService.sendNotification(
                                                  receiverID: ownerID,
                                                  title: l10n.requestDeclined,
                                                  message: l10n.requestDeclinedMessage(name!, petName),
                                                  type: 'request_declined',
                                                );
                                                // Notify Walker
                                                _firestoreService.sendNotification(
                                                  receiverID: uid!,
                                                  title: l10n.requestDeclined,
                                                  message: l10n.requestDeclinedWalkerMessage(petName, ownerName),
                                                  type: 'request_declined',
                                                );
                                              }
                                              if (!context.mounted) return;
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text(l10n.requestDeclinedSnackBar(petName, ownerName)),
                                                  backgroundColor: Colors.red,
                                                  duration: const Duration(seconds: 3),
                                                ),
                                              );
                                            },
                                            style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                                            child: Text(l10n.decline, style: const TextStyle(color: Colors.black)),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: ElevatedButton(
                                            onPressed: () async {
                                              String ownerID = data.ownerId;
                                              String petName = data.petName;
                                              String ownerName = data.ownerName;

                                              await _firestoreService.updateBookingStatus(data.id, 'accepted');
                                              _firestoreService.addEarnings(uid!, data.totalPrice);
                                              if (ownerID.isNotEmpty) {
                                                // Create Chat Room
                                                await _chatService.createChatRoom(ownerID, ownerName, petName, data.totalPrice, data.duration, data.id, l10n);

                                                // Notify Owner
                                                _firestoreService.sendNotification(
                                                  receiverID: ownerID,
                                                  title: l10n.walkRequestAccepted,
                                                  message: l10n.walkRequestAcceptedMessage(name!, petName),
                                                  type: 'request_accepted',
                                                );
                                                // Notify Walker
                                                _firestoreService.sendNotification(
                                                  receiverID: uid!,
                                                  title: l10n.walkRequestAccepted,
                                                  message: l10n.walkRequestAcceptedWalkerMessage(petName, ownerName),
                                                  type: 'request_accepted',
                                                );
                                              }
                                              if (!context.mounted) return;
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text(l10n.requestAcceptedSnackBar(petName, ownerName)),
                                                  backgroundColor: Colors.green,
                                                  duration: const Duration(seconds: 3),
                                                ),
                                              );
                                            },
                                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                                            child: Text(l10n.accept, style: const TextStyle(color: Colors.white)),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      )
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

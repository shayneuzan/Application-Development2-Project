import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'owner_home_screen.dart';
import 'booking_history_screen.dart';
import 'profile_screen.dart';
import 'notifications_screen.dart';
import 'walker_profile_screen.dart';
import '../../services/firestore_service.dart';
import '../../models/walker_model.dart';
import '../../models/user_model.dart';
import '../widgets/owner_drawer.dart';

class BrowseWalkersListScreen extends StatefulWidget {
  final bool showFavoritesOnly;

  const BrowseWalkersListScreen({super.key, this.showFavoritesOnly = false});

  @override
  State<BrowseWalkersListScreen> createState() => _BrowseWalkersListScreenState();
}

class _BrowseWalkersListScreenState extends State<BrowseWalkersListScreen> {
  late bool _isShowingFavorites;
  final FirestoreService _firestoreService = FirestoreService();
  final String? _userId = FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    _isShowingFavorites = widget.showFavoritesOnly;
  }

  void _toggleFavorite(String walkerId, List<String> currentFavorites) {
    if (_userId == null) return;
    bool isCurrentlyFavorite = currentFavorites.contains(walkerId);
    _firestoreService.toggleFavorite(_userId, walkerId, !isCurrentlyFavorite);
  }

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF2563EB);
    const backgroundGray = Color(0xFFF8FAFC);
    const textDark = Color(0xFF1E293B);

    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: backgroundGray,
      appBar: AppBar(
        backgroundColor: primaryBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () => scaffoldKey.currentState?.openDrawer(),
        ),
        title: Text(
          _isShowingFavorites ? 'Favorite Walkers' : 'Find Walkers',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white, size: 28),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NotificationsScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: const OwnerDrawer(currentPage: 'Walkers'),
      body: _userId == null 
        ? const Center(child: Text("Please log in"))
        : StreamBuilder<UserModel>(
            stream: _firestoreService.getUserStream(_userId),
            builder: (context, userSnapshot) {
              final favoriteIds = userSnapshot.data?.favoriteWalkers ?? [];

              return StreamBuilder<List<WalkerModel>>(
                stream: _firestoreService.getWalkers(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  List<WalkerModel> walkers = snapshot.data ?? [];
                  
                  if (_isShowingFavorites) {
                    walkers = walkers.where((w) => favoriteIds.contains(w.id)).toList();
                  }

                  return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!_isShowingFavorites)
                          Container(
                            height: 180,
                            width: double.infinity,
                            margin: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Stack(
                              children: [
                                Center(
                                  child: Container(
                                    width: 12,
                                    height: 12,
                                    decoration: const BoxDecoration(
                                      color: Colors.green,
                                      shape: BoxShape.circle,
                                      boxShadow: [BoxShadow(color: Colors.greenAccent, blurRadius: 10)],
                                    ),
                                  ),
                                ),
                                const Positioned(top: 40, left: 100, child: _MapDot()),
                                const Positioned(top: 100, left: 60, child: _MapDot()),
                                const Positioned(top: 60, right: 80, child: _MapDot()),
                                const Positioned(top: 30, right: 40, child: _MapDot()),
                                
                                Positioned(
                                  bottom: 12,
                                  left: 12,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.location_on, color: Color(0xFF2563EB), size: 14),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${walkers.length} walkers nearby',
                                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textDark),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _isShowingFavorites ? 'Your Favorites' : 'Available Walkers',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: textDark,
                                ),
                              ),
                              GestureDetector(
                                onTap: () => setState(() => _isShowingFavorites = !_isShowingFavorites),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: _isShowingFavorites ? primaryBlue : Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: primaryBlue),
                                  ),
                                  child: Text(
                                    _isShowingFavorites ? 'Show All' : 'Show Favorites',
                                    style: TextStyle(
                                      color: _isShowingFavorites ? Colors.white : primaryBlue,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        if (walkers.isEmpty)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 60),
                              child: Column(
                                children: [
                                  Icon(
                                    _isShowingFavorites ? Icons.favorite_border : Icons.search_off,
                                    size: 64, 
                                    color: Colors.grey.shade300
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    _isShowingFavorites ? 'No favorites yet!' : 'No walkers available.',
                                    style: const TextStyle(color: Colors.grey, fontSize: 16),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: walkers.length,
                            itemBuilder: (context, index) {
                              final walker = walkers[index];
                              return _buildWalkerCard(
                                context,
                                walker: walker,
                                isFavorite: favoriteIds.contains(walker.id),
                                onFavoriteToggle: () => _toggleFavorite(walker.id, favoriteIds),
                              );
                            },
                          ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  );
                }
              );
            },
          ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: 1,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white54,
          backgroundColor: const Color(0xFF2563EB),
          onTap: (index) {
            if (index == 0) {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const OwnerHomeScreen()));
            } else if (index == 2) {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const BookingHistoryScreen()));
            } else if (index == 4) {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const ProfileScreen()));
            }
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Walkers'),
            BottomNavigationBarItem(icon: Icon(Icons.calendar_month_outlined), label: 'Bookings'),
            BottomNavigationBarItem(icon: Icon(Icons.map_outlined), label: 'Map'),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
          ],
        ),
      ),
    );
  }

  Widget _buildWalkerCard(
    BuildContext context, {
    required WalkerModel walker,
    required bool isFavorite,
    required VoidCallback onFavoriteToggle,
  }) {
    const primaryBlue = Color(0xFF2563EB);
    const textDark = Color(0xFF1E293B);
    const textLight = Color(0xFF64748B);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WalkerProfileScreen(
              id: walker.id,
              name: walker.name,
              initials: walker.initials,
              rating: walker.rating,
              walksCount: walker.walksCount,
              price: walker.price,
              walker: walker,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 15,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Stack(
          children: [
            Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: const Color(0xFFF1F5F9),
                      child: Text(
                        walker.initials,
                        style: const TextStyle(color: textDark, fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                walker.name,
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textDark),
                              ),
                              Row(
                                children: [
                                  const Icon(Icons.star, color: Colors.orange, size: 18),
                                  const SizedBox(width: 4),
                                  Text(
                                    walker.rating.toString(),
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: textDark),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Text(
                            '${walker.walksCount} walks completed',
                            style: const TextStyle(color: textLight, fontSize: 14),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '\$ ${walker.price}/hr',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2563EB),
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => WalkerProfileScreen(
                                        id: walker.id,
                                        name: walker.name,
                                        initials: walker.initials,
                                        rating: walker.rating,
                                        walksCount: walker.walksCount,
                                        price: walker.price,
                                        walker: walker,
                                      ),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryBlue,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  elevation: 0,
                                ),
                                child: const Text('Book Now', style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Positioned(
              top: 0,
              left: 0,
              child: GestureDetector(
                onTap: onFavoriteToggle,
                child: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: Colors.red,
                  size: 24,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapDot extends StatelessWidget {
  const _MapDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: const Color(0xFF2563EB),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
    );
  }
}

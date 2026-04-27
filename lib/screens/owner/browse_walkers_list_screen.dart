import 'package:flutter/material.dart';
import 'owner_home_screen.dart';
import 'booking_history_screen.dart';
import 'profile_screen.dart';
import 'notifications_screen.dart';
import 'walker_profile_screen.dart';
import '../widgets/owner_drawer.dart';

class BrowseWalkersListScreen extends StatefulWidget {
  final bool showFavoritesOnly;

  const BrowseWalkersListScreen({super.key, this.showFavoritesOnly = false});

  @override
  State<BrowseWalkersListScreen> createState() => _BrowseWalkersListScreenState();
}

class _BrowseWalkersListScreenState extends State<BrowseWalkersListScreen> {
  late bool _isShowingFavorites;
  
  // Placeholder list of walkers with favorite status
  final List<Map<String, dynamic>> _allWalkers = [
    {
      'name': 'Sarah Johnson',
      'initials': 'SJ',
      'walksCount': 342,
      'rating': 4.9,
      'price': 25,
      'isFavorite': true,
    },
    {
      'name': 'Mike Chen',
      'initials': 'MC',
      'walksCount': 256,
      'rating': 4.8,
      'price': 30,
      'isFavorite': true,
    },
    {
      'name': 'Emily Davis',
      'initials': 'ED',
      'walksCount': 189,
      'rating': 5.0,
      'price': 28,
      'isFavorite': false,
    },
    {
      'name': 'James Wilson',
      'initials': 'JW',
      'walksCount': 128,
      'rating': 4.7,
      'price': 22,
      'isFavorite': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _isShowingFavorites = widget.showFavoritesOnly;
  }

  void _toggleFavorite(int index) {
    setState(() {
      _allWalkers[index]['isFavorite'] = !(_allWalkers[index]['isFavorite'] as bool);
    });
  }

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF2563EB);
    const backgroundGray = Color(0xFFF8FAFC);
    const textDark = Color(0xFF1E293B);

    final List<Map<String, dynamic>> displayedWalkers = _isShowingFavorites
        ? _allWalkers.where((w) => w['isFavorite'] == true).toList()
        : _allWalkers;

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
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!_isShowingFavorites)
              Container(
                height: 180,
                width: double.infinity,
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEDD5),
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
                        child: const Row(
                          children: [
                            Icon(Icons.location_on, color: Colors.orange, size: 14),
                            SizedBox(width: 4),
                            Text(
                              '4 walkers nearby',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textDark),
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

            if (displayedWalkers.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 60),
                  child: Column(
                    children: [
                      Icon(Icons.favorite_border, size: 64, color: Colors.grey.shade300),
                      const SizedBox(height: 16),
                      const Text(
                        'No favorites yet!',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
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
                itemCount: displayedWalkers.length,
                itemBuilder: (context, index) {
                  final walker = displayedWalkers[index];
                  // Find real index in _allWalkers to support toggling correctly
                  int realIndex = _allWalkers.indexWhere((w) => w['name'] == walker['name']);
                  
                  return _buildWalkerCard(
                    context,
                    index: realIndex,
                    name: walker['name'],
                    initials: walker['initials'],
                    walksCount: walker['walksCount'],
                    rating: walker['rating'],
                    price: walker['price'],
                    isFavorite: walker['isFavorite'],
                  );
                },
              ),
            const SizedBox(height: 20),
          ],
        ),
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
          selectedItemColor: primaryBlue,
          unselectedItemColor: const Color(0xFF94A3B8),
          backgroundColor: Colors.white,
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
    required int index,
    required String name,
    required String initials,
    required int walksCount,
    required double rating,
    required int price,
    required bool isFavorite,
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
              name: name,
              initials: initials,
              rating: rating,
              walksCount: walksCount,
              price: price,
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
                      backgroundColor: const Color(0xFFFFEDD5),
                      child: Text(
                        initials,
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
                                name,
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textDark),
                              ),
                              Row(
                                children: [
                                  const Icon(Icons.star, color: Colors.orange, size: 18),
                                  const SizedBox(width: 4),
                                  Text(
                                    rating.toString(),
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: textDark),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Text(
                            '$walksCount walks completed',
                            style: const TextStyle(color: textLight, fontSize: 14),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '\$ $price/hr',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange,
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => WalkerProfileScreen(
                                        name: name,
                                        initials: initials,
                                        rating: rating,
                                        walksCount: walksCount,
                                        price: price,
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
            // Favorite Heart Icon - Now Clickable
            Positioned(
              top: 0,
              left: 0,
              child: GestureDetector(
                onTap: () => _toggleFavorite(index),
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

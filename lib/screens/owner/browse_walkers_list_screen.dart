import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../l10n/generated/app_localizations.dart';
import 'owner_home_screen.dart';
import 'booking_history_screen.dart';
import 'profile_screen.dart';
import 'notifications_screen.dart';
import 'walker_profile_screen.dart';
import 'explore_map_screen.dart';
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
  
  static const LatLng _defaultPosition = LatLng(45.485, -73.625);
  LatLng _currentPosition = _defaultPosition;
  GoogleMapController? _miniMapController;
  final Set<Marker> _miniMapMarkers = {};

  @override
  void initState() {
    super.initState();
    _isShowingFavorites = widget.showFavoritesOnly;
    _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    if (permission == LocationPermission.deniedForever) return;

    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      if (mounted) {
        setState(() {
          _currentPosition = LatLng(position.latitude, position.longitude);
        });
        _miniMapController?.animateCamera(
          CameraUpdate.newLatLng(_currentPosition),
        );
      }
    } catch (e) {
      debugPrint("Error getting location: $e");
    }
  }

  void _toggleFavorite(String walkerId, List<String> currentFavorites) {
    if (_userId == null) return;
    bool isCurrentlyFavorite = currentFavorites.contains(walkerId);
    _firestoreService.toggleFavorite(_userId!, walkerId, !isCurrentlyFavorite);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    const primaryBlue = Color(0xFF2563EB);
    const backgroundGray = Color(0xFFF8FAFC);
    const textDark = Color(0xFF1E293B);
    const textLight = Color(0xFF64748B);

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
          _isShowingFavorites ? l10n.favoriteWalkers : l10n.findWalkers,
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
        ? Center(child: Text(l10n.pleaseLogin))
        : StreamBuilder<UserModel>(
            stream: _firestoreService.getUserStream(_userId!),
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
                  
                  _miniMapMarkers.clear();
                  for (var walker in walkers) {
                    _miniMapMarkers.add(
                      Marker(
                        markerId: MarkerId('mini_${walker.id}'),
                        position: LatLng(
                          _currentPosition.latitude + (0.005 * (walker.name.length % 5 - 2)),
                          _currentPosition.longitude + (0.005 * (walker.walksCount % 5 - 2)),
                        ),
                        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
                      ),
                    );
                  }

                  if (_isShowingFavorites) {
                    walkers = walkers.where((w) => favoriteIds.contains(w.id)).toList();
                  }

                  return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!_isShowingFavorites)
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const ExploreMapScreen()),
                              );
                            },
                            child: Container(
                              height: 190,
                              width: double.infinity,
                              margin: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.08),
                                    blurRadius: 20,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: Stack(
                                children: [
                                  AbsorbPointer(
                                    child: GoogleMap(
                                      initialCameraPosition: CameraPosition(
                                        target: _currentPosition,
                                        zoom: 13.5,
                                      ),
                                      onMapCreated: (controller) {
                                        _miniMapController = controller;
                                        controller.setMapStyle(_mapStyle);
                                      },
                                      markers: _miniMapMarkers,
                                      myLocationEnabled: true,
                                      myLocationButtonEnabled: false,
                                      zoomControlsEnabled: false,
                                      mapToolbarEnabled: false,
                                      compassEnabled: false,
                                      liteModeEnabled: false,
                                    ),
                                  ),
                                  
                                  // Nearby Badge
                                  Positioned(
                                    bottom: 16,
                                    left: 16,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.1),
                                            blurRadius: 8,
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.location_on, color: primaryBlue, size: 16),
                                          const SizedBox(width: 6),
                                          Text(
                                            l10n.countWalkersNearby(walkers.length),
                                            style: const TextStyle(
                                              fontSize: 13, 
                                              fontWeight: FontWeight.bold, 
                                              color: textDark
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  
                                  // Fullscreen Icon
                                  Positioned(
                                    top: 16,
                                    right: 16,
                                    child: Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.9),
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.1),
                                            blurRadius: 8,
                                          ),
                                        ],
                                      ),
                                      child: const Icon(Icons.fullscreen_rounded, color: primaryBlue, size: 24),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                l10n.availableWalkers,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: textDark,
                                ),
                              ),
                              OutlinedButton(
                                onPressed: () => setState(() => _isShowingFavorites = !_isShowingFavorites),
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: _isShowingFavorites ? primaryBlue : Colors.white,
                                  side: const BorderSide(color: primaryBlue),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                ),
                                child: Text(
                                  _isShowingFavorites ? l10n.showAll : l10n.showFavorites,
                                  style: TextStyle(
                                    color: _isShowingFavorites ? Colors.white : primaryBlue,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        if (walkers.isEmpty)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 60, bottom: 60),
                              child: Column(
                                children: [
                                  Icon(
                                    _isShowingFavorites ? Icons.favorite_border : Icons.search_off,
                                    size: 64, 
                                    color: Colors.grey.shade300
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    _isShowingFavorites ? l10n.noFavoritesYet : l10n.noWalkersAvailable,
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
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
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
            } else if (index == 3) {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const ExploreMapScreen()));
            } else if (index == 4) {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const ProfileScreen()));
            }
          },
          items: [
            BottomNavigationBarItem(icon: const Icon(Icons.home_outlined), label: l10n.home),
            BottomNavigationBarItem(icon: const Icon(Icons.search), label: l10n.walkers),
            BottomNavigationBarItem(icon: const Icon(Icons.calendar_month_outlined), label: l10n.bookings),
            BottomNavigationBarItem(icon: const Icon(Icons.map_outlined), label: l10n.map),
            BottomNavigationBarItem(icon: const Icon(Icons.person_outline), label: l10n.profile),
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
    final l10n = AppLocalizations.of(context)!;
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
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 15,
              offset: const Offset(0, 5),
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
                            l10n.walksCompletedCount(walker.walksCount),
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
                                  color: Colors.orange,
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
                                child: Text(l10n.bookNow, style: const TextStyle(fontWeight: FontWeight.bold)),
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

  final String _mapStyle = '''
[
  {
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#f5f5f5"
      }
    ]
  },
  {
    "elementType": "labels.icon",
    "stylers": [
      {
        "visibility": "off"
      }
    ]
  },
  {
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#616161"
      }
    ]
  },
  {
    "elementType": "labels.text.stroke",
    "stylers": [
      {
        "color": "#f5f5f5"
      }
    ]
  },
  {
    "featureType": "administrative.land_parcel",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#bdbdbd"
      }
    ]
  },
  {
    "featureType": "poi",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#eeeeee"
      }
    ]
  },
  {
    "featureType": "poi",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#757575"
      }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#e5e5e5"
      }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#9e9e9e"
      }
    ]
  },
  {
    "featureType": "road",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#ffffff"
      }
    ]
  },
  {
    "featureType": "road.arterial",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#757575"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#dadada"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#616161"
      }
    ]
  },
  {
    "featureType": "road.local",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#9e9e9e"
      }
    ]
  },
  {
    "featureType": "transit.line",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#e5e5e5"
      }
    ]
  },
  {
    "featureType": "transit.station",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#eeeeee"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#c9c9c9"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#9e9e9e"
      }
    ]
  }
]
''';
}

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import '../shared/notification_screen.dart';
import '../widgets/owner_bottom_nav_bar.dart';
import '../widgets/walker_notification_icon.dart';
import '../../l10n/generated/app_localizations.dart';
import 'owner_home_screen.dart';
import 'booking_history_screen.dart';
import 'profile_screen.dart';

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
    _firestoreService.toggleFavorite(_userId, walkerId, !isCurrentlyFavorite);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    const primaryBlue = Color(0xFF2563EB);

    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      key: scaffoldKey,
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
        actions: const [
          SizedBox(width: 8),
          NotificationIcon(), 
        ],
      ),
      drawer: const OwnerDrawer(currentPage: 'Walkers'),
      body: _userId == null
        ? Center(child: Text(l10n.pleaseLogin))
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
                                color: theme.cardColor,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.08),
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
                                  
                                  Positioned(
                                    bottom: 16,
                                    left: 16,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: theme.cardColor,
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
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  
                                  Positioned(
                                    top: 16,
                                    right: 16,
                                    child: Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: theme.cardColor.withOpacity(0.9),
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
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  setState(() => _isShowingFavorites = !_isShowingFavorites);
                                },
                                child: Text(
                                  _isShowingFavorites ? l10n.showAll : l10n.showFavorites,
                                  style: const TextStyle(color: primaryBlue, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ),

                        if (walkers.isEmpty)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 40),
                              child: Text(
                                _isShowingFavorites ? l10n.noFavoritesYet : l10n.noWalkersAvailable,
                                style: TextStyle(color: theme.textTheme.bodySmall?.color),
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
                              final isFavorite = favoriteIds.contains(walker.id);
                              return _buildWalkerCard(context, walker, isFavorite, favoriteIds);
                            },
                          ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  );
                },
              );
            },
          ),
      bottomNavigationBar: const OwnerBottomNavBar(currentIndex: 1),
    );
  }

  Widget _buildWalkerCard(BuildContext context, WalkerModel walker, bool isFavorite, List<String> currentFavorites) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    const primaryBlue = Color(0xFF2563EB);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(theme.brightness == Brightness.dark ? 0.3 : 0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WalkerProfileScreen(
                id: walker.id,
                name: walker.name,
                initials: walker.name.isNotEmpty ? walker.name[0] : 'W',
                rating: walker.rating,
                walksCount: walker.walksCount,
                price: walker.hourlyRate,
                walker: walker,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 35,
                    backgroundColor: const Color(0xFFF1F5F9),
                    child: Text(
                      walker.name.isNotEmpty ? walker.name[0] : 'W',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981),
                        shape: BoxShape.circle,
                        border: Border.all(color: theme.cardColor, width: 2),
                      ),
                    ),
                  ),
                ],
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
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        GestureDetector(
                          onTap: () => _toggleFavorite(walker.id, currentFavorites),
                          child: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: isFavorite ? Colors.red : Colors.grey[400],
                            size: 22,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.orange, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          walker.rating.toStringAsFixed(2),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          l10n.walksCompletedCount(walker.walksCount),
                          style: TextStyle(color: theme.textTheme.bodySmall?.color, fontSize: 13),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '\$${walker.hourlyRate}/hr',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primaryBlue),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            l10n.bookNow,
                            style: const TextStyle(color: primaryBlue, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

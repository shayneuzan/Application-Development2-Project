import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../../l10n/generated/app_localizations.dart';
import 'owner_home_screen.dart';
import 'browse_walkers_list_screen.dart';
import 'booking_history_screen.dart';
import 'profile_screen.dart';
import '../../services/firestore_service.dart';

class ExploreMapScreen extends StatefulWidget {
  const ExploreMapScreen({super.key});

  @override
  State<ExploreMapScreen> createState() => _ExploreMapScreenState();
}

class _ExploreMapScreenState extends State<ExploreMapScreen> {
  late GoogleMapController mapController;
  final FirestoreService _firestoreService = FirestoreService();

  static const LatLng _defaultPosition = LatLng(45.485, -73.625);
  LatLng _currentMapPosition = _defaultPosition;
  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _checkPermissionsAndGetLocation();
  }

  Future<void> _checkPermissionsAndGetLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    
    if (permission == LocationPermission.deniedForever) return;

    _goToCurrentLocation();
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    _updateMapStyle();
    _loadWalkerMarkers();
  }

  void _updateMapStyle() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    mapController.setMapStyle(isDarkMode ? _darkMapStyle : _lightMapStyle);
  }

  Future<void> _goToCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high
      );
      setState(() {
        _currentMapPosition = LatLng(position.latitude, position.longitude);
      });
      mapController.animateCamera(
        CameraUpdate.newLatLng(_currentMapPosition),
      );
      _loadWalkerMarkers();
    } catch (e) {
      debugPrint("Could not get current location: $e");
    }
  }

  void _loadWalkerMarkers() {
    _firestoreService.getWalkers().listen((walkers) {
      if (mounted) {
        setState(() {
          _markers.clear();
          for (var walker in walkers) {
            _markers.add(
              Marker(
                markerId: MarkerId(walker.id),
                position: LatLng(
                  _currentMapPosition.latitude + (0.005 * (walker.name.length % 5 - 2)),
                  _currentMapPosition.longitude + (0.005 * (walker.walksCount % 5 - 2)),
                ),
                infoWindow: InfoWindow(
                  title: walker.name,
                  snippet: '${walker.rating} ⭐ • \$${walker.hourlyRate}/hr',
                ),
                icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
              ),
            );
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    const primaryBlue = Color(0xFF2563EB);

    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: _currentMapPosition,
              zoom: 14.0,
            ),
            markers: _markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            compassEnabled: false,
          ),

          // Search Bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Container(
                height: 54,
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.06),
                      blurRadius: 15,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: l10n.searchHint,
                    prefixIcon: const Icon(Icons.search, color: primaryBlue),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ),
          ),

          // Location Button
          Positioned(
            right: 16,
            top: MediaQuery.of(context).size.height * 0.14,
            child: FloatingActionButton(
              mini: true,
              backgroundColor: theme.cardColor,
              elevation: 4,
              onPressed: _goToCurrentLocation,
              child: const Icon(Icons.my_location, color: primaryBlue),
            ),
          ),

          // Bottom Info Card
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDarkMode ? 0.4 : 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.walkersNearby,
                              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              l10n.discoverWalkers,
                              style: TextStyle(color: theme.textTheme.bodySmall?.color, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const BrowseWalkersListScreen()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryBlue,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        ),
                        child: Text(l10n.viewList, style: const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildBottomNavIcon(Icons.home_filled, l10n.home, 0),
                      _buildBottomNavIcon(Icons.search, l10n.walkers, 1),
                      _buildBottomNavIcon(Icons.calendar_today, l10n.bookings, 2),
                      _buildBottomNavIcon(Icons.location_on, l10n.map, 3, isActive: true),
                      _buildBottomNavIcon(Icons.person, l10n.profile, 4),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavIcon(IconData icon, String label, int index, {bool isActive = false}) {
    final theme = Theme.of(context);
    const primaryBlue = Color(0xFF2563EB);
    return GestureDetector(
      onTap: () => _navigateTo(context, index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isActive ? primaryBlue.withOpacity(0.1) : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: isActive ? primaryBlue : theme.textTheme.bodySmall?.color?.withOpacity(0.7),
              size: 26,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              color: isActive ? primaryBlue : theme.textTheme.bodySmall?.color,
            ),
          ),
        ],
      ),
    );
  }

  void _navigateTo(BuildContext context, int index) {
    if (index == 3) return;
    Widget screen;
    switch (index) {
      case 0: screen = const OwnerHomeScreen(); break;
      case 1: screen = const BrowseWalkersListScreen(); break;
      case 2: screen = const BookingHistoryScreen(); break;
      case 4: screen = const ProfileScreen(); break;
      default: screen = const OwnerHomeScreen();
    }
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => screen));
  }

  final String _lightMapStyle = '''[]''';
  final String _darkMapStyle = '''[
    {"elementType": "geometry", "stylers": [{"color": "#212121"}]},
    {"elementType": "labels.icon", "stylers": [{"visibility": "off"}]},
    {"elementType": "labels.text.fill", "stylers": [{"color": "#757575"}]},
    {"elementType": "labels.text.stroke", "stylers": [{"color": "#212121"}]},
    {"featureType": "administrative", "elementType": "geometry", "stylers": [{"color": "#757575"}]},
    {"featureType": "road", "elementType": "geometry.fill", "stylers": [{"color": "#2c2c2c"}]},
    {"featureType": "water", "elementType": "geometry", "stylers": [{"color": "#000000"}]}
  ]''';
}

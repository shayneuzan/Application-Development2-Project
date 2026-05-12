import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'owner_home_screen.dart';
import 'browse_walkers_list_screen.dart';
import 'booking_history_screen.dart';
import 'profile_screen.dart';
import '../../models/walker_model.dart';
import '../../services/firestore_service.dart';

class ExploreMapScreen extends StatefulWidget {
  const ExploreMapScreen({super.key});

  @override
  State<ExploreMapScreen> createState() => _ExploreMapScreenState();
}

class _ExploreMapScreenState extends State<ExploreMapScreen> {
  late GoogleMapController mapController;
  final FirestoreService _firestoreService = FirestoreService();

  // Default initial position (Montreal area as in the reference image)
  static const LatLng _initialPosition = LatLng(45.485, -73.625);
  
  final Set<Marker> _markers = {};

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    _loadWalkerMarkers();
  }

  void _loadWalkerMarkers() {
    _firestoreService.getWalkers().listen((walkers) {
      if (mounted) {
        setState(() {
          _markers.clear();
          for (var walker in walkers) {
            // Placing markers around the initial position for demo purposes
            _markers.add(
              Marker(
                markerId: MarkerId(walker.id),
                position: LatLng(
                  _initialPosition.latitude + (0.01 * (walker.name.length % 5 - 2)),
                  _initialPosition.longitude + (0.01 * (walker.walksCount % 5 - 2)),
                ),
                infoWindow: InfoWindow(
                  title: walker.name,
                  snippet: '${walker.rating} ⭐ • \$${walker.price}/hr',
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
    const textDark = Color(0xFF1E293B);

    return Scaffold(
      body: Stack(
        children: [
          // 1. Google Map
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: const CameraPosition(
              target: _initialPosition,
              zoom: 14.0,
            ),
            markers: _markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
          ),

          // 2. Floating Search Bar (Chips removed as requested)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const TextField(
                  decoration: InputDecoration(
                    hintText: 'Search for walkers nearby',
                    hintStyle: TextStyle(color: Colors.grey, fontSize: 15),
                    prefixIcon: Icon(Icons.search, color: Colors.black54),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ),
          ),

          // 3. Current Location Button
          Positioned(
            right: 16,
            top: MediaQuery.of(context).size.height * 0.12,
            child: FloatingActionButton(
              mini: true,
              backgroundColor: Colors.white,
              elevation: 4,
              onPressed: () {
                mapController.animateCamera(CameraUpdate.newLatLng(_initialPosition));
              },
              child: const Icon(Icons.my_location, color: Colors.black87),
            ),
          ),

          // 4. Bottom Info Card styled exactly like the photo
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Walkers in Montreal',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: textDark,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '12 available walkers found near you',
                            style: TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const BrowseWalkersListScreen()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF1F5F9),
                          foregroundColor: textDark,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                        ),
                        child: const Text('View List', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Bottom icons in circles as seen in photo
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildBottomCircleIcon(Icons.home_outlined, () => _navigateTo(context, 0)),
                      _buildBottomCircleIcon(Icons.location_on, () => _navigateTo(context, 3), isActive: true),
                      _buildBottomCircleIcon(Icons.search, () => _navigateTo(context, 1)),
                      _buildBottomCircleIcon(Icons.calendar_month_outlined, () => _navigateTo(context, 2)),
                      _buildBottomCircleIcon(Icons.person_outline, () => _navigateTo(context, 4)),
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

  Widget _buildBottomCircleIcon(IconData icon, VoidCallback onTap, {bool isActive = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFEFF6FF) : Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: isActive ? const Color(0xFF2563EB).withOpacity(0.2) : Colors.black12),
        ),
        child: Icon(icon, color: isActive ? const Color(0xFF2563EB) : Colors.black54),
      ),
    );
  }

  void _navigateTo(BuildContext context, int index) {
    if (index == 0) Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const OwnerHomeScreen()));
    else if (index == 1) Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const BrowseWalkersListScreen()));
    else if (index == 2) Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const BookingHistoryScreen()));
    else if (index == 3) return; // Already on map
    else if (index == 4) Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const ProfileScreen()));
  }
}

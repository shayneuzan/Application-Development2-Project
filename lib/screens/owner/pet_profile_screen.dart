import 'package:flutter/material.dart';
import 'owner_home_screen.dart';
import 'booking_history_screen.dart';
import 'profile_screen.dart';
import 'notifications_screen.dart';
import 'browse_walkers_list_screen.dart';
import 'add_pet_screen.dart';
import 'edit_pet_screen.dart';
import '../widgets/owner_drawer.dart';

class PetProfileScreen extends StatefulWidget {
  const PetProfileScreen({super.key});

  @override
  State<PetProfileScreen> createState() => _PetProfileScreenState();
}

class _PetProfileScreenState extends State<PetProfileScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  
  final List<Map<String, String>> pets = [
    {
      'name': 'Max',
      'breed': 'Golden Retriever',
      'age': '3 years old',
      'instructions': 'Loves treats, pull gently on leash'
    },
    {
      'name': 'Bella',
      'breed': 'French Bulldog',
      'age': '2 years old',
      'instructions': 'Needs water breaks every 15 minutes'
    },
  ];

  void _showDeleteDialog(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Pet'),
        content: Text('Are you sure you want to delete ${pets[index]['name']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                pets.removeAt(index);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Pet deleted successfully')),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF2563EB);
    const backgroundGray = Color(0xFFF8FAFC);
    const textDark = Color(0xFF1E293B);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: backgroundGray,
      appBar: AppBar(
        backgroundColor: primaryBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: const Text(
          'My Pets',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.notifications_outlined, color: Colors.white, size: 28),
                Positioned(
                  right: 4,
                  top: 4,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
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
      drawer: const OwnerDrawer(currentPage: 'Pets'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Add New Pet Button
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddPetScreen()),
                );
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.add, color: textDark, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Add New Pet',
                      style: TextStyle(fontWeight: FontWeight.bold, color: textDark),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Pets List
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: pets.length,
              itemBuilder: (context, index) {
                return _buildPetCard(index);
              },
            ),
          ],
        ),
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
          currentIndex: 4, // Settings/Profile related
          type: BottomNavigationBarType.fixed,
          selectedItemColor: primaryBlue,
          unselectedItemColor: const Color(0xFF94A3B8),
          backgroundColor: Colors.white,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          onTap: (index) {
            if (index == 0) {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const OwnerHomeScreen()));
            } else if (index == 1) {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const BrowseWalkersListScreen()));
            } else if (index == 2) {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const BookingHistoryScreen()));
            } else if (index == 3) {
              // TODO: Navigate to Map Screen when built
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

  Widget _buildPetCard(int index) {
    final pet = pets[index];
    const textDark = Color(0xFF1E293B);
    const textLight = Color(0xFF64748B);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF7ED),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.pets, color: Colors.orange, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pet['name']!,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textDark),
                      ),
                      Text(
                        pet['breed']!,
                        style: const TextStyle(fontSize: 14, color: textLight),
                      ),
                      Text(
                        pet['age']!,
                        style: const TextStyle(fontSize: 13, color: textLight),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, color: textLight, size: 20),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditPetScreen(pet: pet),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                      onPressed: () => _showDeleteDialog(index),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          Padding(
            padding: const EdgeInsets.all(16),
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 13, color: textDark),
                children: [
                  const TextSpan(text: 'Special instructions: ', style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: pet['instructions']!, style: const TextStyle(color: textLight)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

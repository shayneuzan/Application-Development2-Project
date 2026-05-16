import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../shared/notification_screen.dart';
import 'owner_home_screen.dart';
import 'booking_history_screen.dart';
import 'profile_screen.dart';
import 'notifications_screen.dart';
import 'browse_walkers_list_screen.dart';
import 'add_pet_screen.dart';
import 'edit_pet_screen.dart';
import 'explore_map_screen.dart';
import '../../services/firestore_service.dart';
import '../../models/pet_model.dart';
import '../widgets/owner_drawer.dart';
import '../../l10n/generated/app_localizations.dart';

class PetProfileScreen extends StatefulWidget {
  const PetProfileScreen({super.key});

  @override
  State<PetProfileScreen> createState() => _PetProfileScreenState();
}

class _PetProfileScreenState extends State<PetProfileScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final FirestoreService _firestoreService = FirestoreService();
  final String? _userId = FirebaseAuth.instance.currentUser?.uid;

  void _showDeleteDialog(PetModel pet, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deletePet),
        content: Text(l10n.deletePetConfirmation(pet.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () async {
              try {
                await _firestoreService.deletePet(pet.id);
                if (!context.mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${pet.name} deleted successfully')),
                );
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error deleting pet: $e')),
                );
              }
            },
            child: Text(l10n.delete, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
        title: Text(
          l10n.myPets,
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
                MaterialPageRoute(builder: (context) => const NotificationScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: const OwnerDrawer(currentPage: 'Pets'),
      body: _userId == null 
        ? Center(child: Text(l10n.pleaseLogin))
        : StreamBuilder<List<PetModel>>(
            stream: _firestoreService.getPetsByOwner(_userId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              final pets = snapshot.data ?? [];

              return SingleChildScrollView(
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
                          children: [
                            const Icon(Icons.add, color: textDark, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              l10n.addNewPet,
                              style: const TextStyle(fontWeight: FontWeight.bold, color: textDark),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    if (pets.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 40),
                        child: Text(l10n.noPetsFound),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: pets.length,
                        itemBuilder: (context, index) {
                          return _buildPetCard(pets[index], l10n);
                        },
                      ),
                  ],
                ),
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
          currentIndex: 4, // Profile/Settings related
          type: BottomNavigationBarType.fixed,
          selectedItemColor: primaryBlue,
          unselectedItemColor: const Color(0xFF94A3B8),
          backgroundColor: Colors.white,
          onTap: (index) {
            if (index == 0) {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const OwnerHomeScreen()));
            } else if (index == 1) {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const BrowseWalkersListScreen()));
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

  Widget _buildPetCard(PetModel pet, AppLocalizations l10n) {
    const textDark = Color(0xFF1E293B);
    const textLight = Color(0xFF64748B);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
                        pet.name,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textDark),
                      ),
                      Text(
                        pet.breed,
                        style: const TextStyle(fontSize: 14, color: textLight),
                      ),
                      Text(
                        l10n.yearsOld(pet.age),
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
                            builder: (context) => EditPetScreen(pet: {
                              'id': pet.id,
                              'name': pet.name,
                              'breed': pet.breed,
                              'age': '${pet.age} years old',
                              'instructions': pet.description,
                            }),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                      onPressed: () => _showDeleteDialog(pet, l10n),
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
                  TextSpan(text: '${l10n.specialInstructions}: ', style: const TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: pet.description, style: const TextStyle(color: textLight)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

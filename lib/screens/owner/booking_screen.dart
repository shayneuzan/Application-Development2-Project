import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'schedule_screen.dart';
import 'add_pet_screen.dart';
import '../../services/firestore_service.dart';
import '../../models/pet_model.dart';
import '../../l10n/generated/app_localizations.dart';

class BookingScreen extends StatefulWidget {
  final String walkerId;
  final String walkerName;
  final double hourlyRate;

  const BookingScreen({
    super.key,
    required this.walkerId,
    required this.walkerName,
    required this.hourlyRate,
  });

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  int _selectedDuration = 60; 
  String? _selectedPetId;
  String? _selectedPetName;
  String? _ownerName;
  
  final FirestoreService _firestoreService = FirestoreService();
  final String? _userId = FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    _getOwnerName();
  }

  Future<void> _getOwnerName() async {
    if (_userId == null) return;
    final ownerData = await FirebaseFirestore.instance.collection('users').doc(_userId).get();

    if (ownerData.exists) {
      setState(() {
        _ownerName = ownerData['name'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    const primaryBlue = Color(0xFF2563EB);

    double totalPrice = (widget.hourlyRate / 60) * _selectedDuration;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.cardColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.iconTheme.color),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n.bookAWalk,
          style: TextStyle(color: theme.textTheme.titleLarge?.color, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Walker Summary
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.dividerColor),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: isDarkMode ? Colors.white10 : const Color(0xFFEFF6FF),
                    child: const Icon(Icons.person, color: primaryBlue),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.walkerName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        l10n.hourlyRateValue(widget.hourlyRate.toStringAsFixed(2)),
                        style: TextStyle(color: theme.textTheme.bodySmall?.color, fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            Text(
              l10n.selectPet,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _userId == null 
              ? Text(l10n.pleaseLogin)
              : StreamBuilder<List<PetModel>>(
                  stream: _firestoreService.getPetsByOwner(_userId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SizedBox(
                        height: 100,
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    
                    final pets = snapshot.data ?? [];
                    
                    return SizedBox(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: pets.length + 1,
                        itemBuilder: (context, index) {
                          if (index == pets.length) {
                            return _buildAddPetCard(context, l10n);
                          }
                          final pet = pets[index];
                          bool isSelected = _selectedPetId == pet.id;
                          return _buildPetCard(pet, isSelected, l10n);
                        },
                      ),
                    );
                  },
                ),

            const SizedBox(height: 32),

            Text(
              l10n.walkDuration,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildDurationOption(30, l10n),
                const SizedBox(width: 12),
                _buildDurationOption(60, l10n),
                const SizedBox(width: 12),
                _buildDurationOption(90, l10n),
              ],
            ),

            const SizedBox(height: 40),

            // Price Summary Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.white.withValues(alpha: 0.05) : primaryBlue.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: primaryBlue.withValues(alpha: 0.1)),
              ),
              child: Column(
                children: [
                  _buildSummaryRow(l10n.baseRate, l10n.hourlyRateValue(widget.hourlyRate.toStringAsFixed(2))),
                  const SizedBox(height: 12),
                  _buildSummaryRow(l10n.duration, l10n.durationMinutes(_selectedDuration)),
                  const Divider(height: 24),
                  _buildSummaryRow(
                    l10n.totalPrice,
                    l10n.priceAmount(totalPrice.toStringAsFixed(2)),
                    isTotal: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20),
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _selectedPetId == null
                ? null
                : () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ScheduleScreen(
                          walkerId: widget.walkerId,
                          walkerName: widget.walkerName,
                          hourlyRate: widget.hourlyRate,
                          selectedPet: _selectedPetName!,
                          selectedDuration: _selectedDuration,
                        ),
                      ),
                    );
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryBlue,
              foregroundColor: Colors.white,
              disabledBackgroundColor: theme.disabledColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            child: Text(
              l10n.selectDateTime,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPetCard(PetModel pet, bool isSelected, AppLocalizations l10n) {
    final theme = Theme.of(context);
    const primaryBlue = Color(0xFF2563EB);
    return GestureDetector(
      onTap: () => setState(() {
        _selectedPetId = pet.id;
        _selectedPetName = pet.name;
      }),
      child: Container(
        width: 120,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: isSelected ? primaryBlue : theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? primaryBlue : theme.dividerColor),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.pets, color: isSelected ? Colors.white : primaryBlue, size: 30),
            const SizedBox(height: 8),
            Text(
              pet.name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : theme.textTheme.bodyLarge?.color,
              ),
            ),
            Text(
              pet.breed,
              style: TextStyle(
                fontSize: 10,
                color: isSelected ? Colors.white70 : theme.textTheme.bodySmall?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddPetCard(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const AddPetScreen()));
      },
      child: Container(
        width: 100,
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.dividerColor, style: BorderStyle.solid),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle_outline, color: theme.textTheme.bodySmall?.color),
            const SizedBox(height: 4),
            Text(
              l10n.addPet,
              style: TextStyle(fontSize: 12, color: theme.textTheme.bodySmall?.color),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDurationOption(int minutes, AppLocalizations l10n) {
    final theme = Theme.of(context);
    bool isSelected = _selectedDuration == minutes;
    const primaryBlue = Color(0xFF2563EB);

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedDuration = minutes),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected ? primaryBlue : theme.cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isSelected ? primaryBlue : theme.dividerColor),
          ),
          child: Center(
            child: Text(
              l10n.durationMinutes(minutes),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : theme.textTheme.bodyLarge?.color,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    final theme = Theme.of(context);
    const primaryBlue = Color(0xFF2563EB);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 18 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal ? theme.textTheme.bodyLarge?.color : theme.textTheme.bodySmall?.color,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 18 : 14,
            fontWeight: FontWeight.bold,
            color: isTotal ? primaryBlue : theme.textTheme.bodyLarge?.color,
          ),
        ),
      ],
    );
  }
}

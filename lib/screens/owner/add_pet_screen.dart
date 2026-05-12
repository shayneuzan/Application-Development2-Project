import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/firestore_service.dart';
import '../../models/pet_model.dart';

class AddPetScreen extends StatefulWidget {
  const AddPetScreen({super.key});

  @override
  State<AddPetScreen> createState() => _AddPetScreenState();
}

class _AddPetScreenState extends State<AddPetScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirestoreService _firestoreService = FirestoreService();
  final String? _userId = FirebaseAuth.instance.currentUser?.uid;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _breedController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _instructionController = TextEditingController();
  
  String _selectedSize = 'Medium';
  final List<String> _sizes = ['Small', 'Medium', 'Large'];
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _breedController.dispose();
    _ageController.dispose();
    _instructionController.dispose();
    super.dispose();
  }

  Future<void> _savePet() async {
    if (_formKey.currentState!.validate()) {
      if (_userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please log in to add a pet')),
        );
        return;
      }

      setState(() => _isLoading = true);

      try {
        final newPet = PetModel(
          id: '', // Firestore will generate this
          ownerId: _userId!,
          name: _nameController.text.trim(),
          breed: _breedController.text.trim(),
          age: int.parse(_ageController.text.trim()),
          gender: '', // Add gender field to UI if needed
          weight: 0.0, // Add weight field to UI if needed
          description: _instructionController.text.trim(),
          imageUrl: '', // TODO: Implement image upload to Firebase Storage
        );

        await _firestoreService.addPet(newPet);

        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Pet added successfully!')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error adding pet: $e')),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF2563EB);
    const textDark = Color(0xFF1E293B);
    const backgroundGray = Color(0xFFF8FAFC);

    return Scaffold(
      backgroundColor: backgroundGray,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Add New Pet',
          style: TextStyle(color: textDark, fontWeight: FontWeight.bold),
        ),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image Picker Placeholder
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        // Placeholder for image picker
                      },
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFFE2E8F0), width: 2),
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.camera_alt_outlined, color: primaryBlue, size: 32),
                            SizedBox(height: 4),
                            Text(
                              'Add Photo',
                              style: TextStyle(fontSize: 12, color: primaryBlue, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Pet Name
                  const Text(
                    'Pet Name',
                    style: TextStyle(fontWeight: FontWeight.bold, color: textDark),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _nameController,
                    decoration: _inputStyle('e.g. Max'),
                    validator: (value) => value == null || value.isEmpty ? 'Please enter a name' : null,
                  ),

                  const SizedBox(height: 20),

                  // Breed
                  const Text(
                    'Breed',
                    style: TextStyle(fontWeight: FontWeight.bold, color: textDark),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _breedController,
                    decoration: _inputStyle('e.g. Golden Retriever'),
                    validator: (value) => value == null || value.isEmpty ? 'Please enter a breed' : null,
                  ),

                  const SizedBox(height: 20),

                  // Age
                  const Text(
                    'Age (Years)',
                    style: TextStyle(fontWeight: FontWeight.bold, color: textDark),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _ageController,
                    keyboardType: TextInputType.number,
                    decoration: _inputStyle('e.g. 3'),
                    validator: (value) => value == null || value.isEmpty ? 'Please enter age' : null,
                  ),

                  const SizedBox(height: 24),

                  // Size Selector
                  const Text(
                    'Pet Size',
                    style: TextStyle(fontWeight: FontWeight.bold, color: textDark),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: _sizes.map((size) => _buildSizeOption(size)).toList(),
                  ),

                  const SizedBox(height: 24),

                  // Special Instructions
                  const Text(
                    'Special Instructions',
                    style: TextStyle(fontWeight: FontWeight.bold, color: textDark),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _instructionController,
                    maxLines: 4,
                    decoration: _inputStyle('e.g. Allergies, temperament, favorite treats...'),
                  ),

                  const SizedBox(height: 40),

                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _savePet,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Save Pet',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  InputDecoration _inputStyle(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
      ),
    );
  }

  Widget _buildSizeOption(String size) {
    bool isSelected = _selectedSize == size;
    const primaryBlue = Color(0xFF2563EB);

    return GestureDetector(
      onTap: () => setState(() => _selectedSize = size),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.25,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? primaryBlue : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? primaryBlue : const Color(0xFFE2E8F0),
          ),
        ),
        child: Center(
          child: Text(
            size,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : const Color(0xFF1E293B),
            ),
          ),
        ),
      ),
    );
  }
}

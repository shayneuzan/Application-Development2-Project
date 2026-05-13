import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/firestore_service.dart';
import '../../models/user_model.dart';

class EditAddressScreen extends StatefulWidget {
  final Map<String, dynamic> address;
  final int index;

  const EditAddressScreen({super.key, required this.address, required this.index});

  @override
  State<EditAddressScreen> createState() => _EditAddressScreenState();
}

class _EditAddressScreenState extends State<EditAddressScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final String? _userId = FirebaseAuth.instance.currentUser?.uid;

  late TextEditingController _labelController;
  late TextEditingController _streetController;
  late TextEditingController _cityController;
  late TextEditingController _postalController;

  @override
  void initState() {
    super.initState();
    _labelController = TextEditingController(text: widget.address['label']);
    
    // Split the address: "Street, City, PostalCode"
    List<String> parts = widget.address['address']?.split(', ') ?? [];
    _streetController = TextEditingController(text: parts.isNotEmpty ? parts[0] : '');
    _cityController = TextEditingController(text: parts.length > 1 ? parts[1] : '');
    _postalController = TextEditingController(text: parts.length > 2 ? parts[2] : '');
  }

  @override
  void dispose() {
    _labelController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _postalController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (_userId == null) return;

    final String label = _labelController.text.trim();
    final String street = _streetController.text.trim();
    final String city = _cityController.text.trim();
    final String postal = _postalController.text.trim();

    if (label.isEmpty || street.isEmpty || city.isEmpty || postal.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    final String fullAddress = "$street, $city, $postal";

    try {
      // Get current user data to update the specific address in the list
      UserModel user = await _firestoreService.getUserById(_userId);
      List<Map<String, dynamic>> updatedAddresses = List.from(user.savedAddresses);
      
      bool wasDefault = updatedAddresses[widget.index]['isDefault'] == true;

      updatedAddresses[widget.index] = {
        'label': label,
        'address': fullAddress,
        'isDefault': wasDefault,
      };

      Map<String, dynamic> updateData = {'savedAddresses': updatedAddresses};
      
      // If this was the default address, update the main address field too
      if (wasDefault) {
        updateData['address'] = fullAddress;
      }

      await _firestoreService.updateUser(_userId, updateData);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Address updated successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating address: $e')),
        );
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
          'Edit Address',
          style: TextStyle(color: textDark, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel('Address Label'),
            const SizedBox(height: 8),
            _buildTextField(_labelController, 'e.g. Home, Office'),
            const SizedBox(height: 24),
            _buildLabel('Street Address'),
            const SizedBox(height: 8),
            _buildTextField(_streetController, 'Enter street name and number'),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('City'),
                      const SizedBox(height: 8),
                      _buildTextField(_cityController, 'City'),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Postal Code'),
                      const SizedBox(height: 8),
                      _buildTextField(_postalController, 'Postal Code'),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _saveChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: const Text('Save Changes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B), fontSize: 14));
  }

  Widget _buildTextField(TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5)),
      ),
    );
  }
}

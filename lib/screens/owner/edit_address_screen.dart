import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../l10n/generated/app_localizations.dart';
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
      final loc = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.pleaseEnterAllFields)),
      );
      return;
    }

    final String fullAddress = "$street, $city, $postal";

    try {
      UserModel user = await _firestoreService.getUserById(_userId);
      List<Map<String, dynamic>> updatedAddresses = List.from(user.savedAddresses);
      bool wasDefault = updatedAddresses[widget.index]['isDefault'] == true;

      updatedAddresses[widget.index] = {
        'label': label,
        'address': fullAddress,
        'isDefault': wasDefault,
      };

      Map<String, dynamic> updateData = {'savedAddresses': updatedAddresses};
      if (wasDefault) {
        updateData['address'] = fullAddress;
      }

      await _firestoreService.updateUser(_userId, updateData);

      if (mounted) {
        final loc = AppLocalizations.of(context)!;
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loc.addressUpdatedSuccessfully)),
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
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    const primaryBlue = Color(0xFF2563EB);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.cardColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.iconTheme.color),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          loc.editAddress,
          style: TextStyle(color: theme.textTheme.titleLarge?.color, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel(loc.addressLabel),
            const SizedBox(height: 8),
            _buildTextField(_labelController, loc.addressExample),
            const SizedBox(height: 24),
            _buildLabel(loc.streetAddress),
            const SizedBox(height: 8),
            _buildTextField(_streetController, loc.streetAddress),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel(loc.city),
                      const SizedBox(height: 8),
                      _buildTextField(_cityController, loc.city),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel(loc.postalCode),
                      const SizedBox(height: 8),
                      _buildTextField(_postalController, loc.postalCode),
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
                child: Text(loc.saveChanges, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14));
  }

  Widget _buildTextField(TextEditingController controller, String hint) {
    final theme = Theme.of(context);
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class EditAddressScreen extends StatefulWidget {
  final Map<String, String> address;

  const EditAddressScreen({super.key, required this.address});

  @override
  State<EditAddressScreen> createState() => _EditAddressScreenState();
}

class _EditAddressScreenState extends State<EditAddressScreen> {
  late TextEditingController _labelController;
  late TextEditingController _streetController;
  late TextEditingController _cityController;
  late TextEditingController _postalController;

  @override
  void initState() {
    super.initState();
    _labelController = TextEditingController(text: widget.address['label']);
    
    // Attempt to split the address for placeholder fields
    // Assuming format: "Street, City, State PostalCode"
    List<String> parts = widget.address['address']?.split(', ') ?? [];
    _streetController = TextEditingController(text: parts.isNotEmpty ? parts[0] : '');
    _cityController = TextEditingController(text: parts.length > 1 ? parts[1] : '');
    
    // Extract postal code (assuming it's at the end)
    String lastPart = parts.length > 2 ? parts.last : '';
    List<String> lastParts = lastPart.split(' ');
    _postalController = TextEditingController(text: lastParts.last);
  }

  @override
  void dispose() {
    _labelController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _postalController.dispose();
    super.dispose();
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
                onPressed: () {
                  // Placeholder for update logic
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Address updated successfully!')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Save Changes',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Text(
      label,
      style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B), fontSize: 14),
    );
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
      ),
    );
  }
}

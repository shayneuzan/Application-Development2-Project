import 'package:flutter/material.dart';

class AddPetScreen extends StatefulWidget {
  const AddPetScreen({super.key});

  @override
  State<AddPetScreen> createState() => _AddPetScreenState();
}

class _AddPetScreenState extends State<AddPetScreen> {
  final _formKey = GlobalKey<FormState>();
  String _selectedSize = 'Medium';
  
  final List<String> _sizes = ['Small', 'Medium', 'Large'];

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
      body: SingleChildScrollView(
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
                decoration: _inputStyle('e.g. Max'),
              ),

              const SizedBox(height: 20),

              // Breed
              const Text(
                'Breed',
                style: TextStyle(fontWeight: FontWeight.bold, color: textDark),
              ),
              const SizedBox(height: 8),
              TextFormField(
                decoration: _inputStyle('e.g. Golden Retriever'),
              ),

              const SizedBox(height: 20),

              // Age
              const Text(
                'Age (Years)',
                style: TextStyle(fontWeight: FontWeight.bold, color: textDark),
              ),
              const SizedBox(height: 8),
              TextFormField(
                keyboardType: TextInputType.number,
                decoration: _inputStyle('e.g. 3'),
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
                maxLines: 4,
                decoration: _inputStyle('e.g. Allergies, temperament, favorite treats...'),
              ),

              const SizedBox(height: 40),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    // Placeholder save logic
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Pet added successfully!')),
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

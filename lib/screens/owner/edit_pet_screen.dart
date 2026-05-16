import 'package:flutter/material.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../services/firestore_service.dart';

class EditPetScreen extends StatefulWidget {
  final Map<String, String> pet;

  const EditPetScreen({super.key, required this.pet});

  @override
  State<EditPetScreen> createState() => _EditPetScreenState();
}

class _EditPetScreenState extends State<EditPetScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirestoreService _firestoreService = FirestoreService();
  
  late TextEditingController _nameController;
  late TextEditingController _breedController;
  late TextEditingController _ageController;
  late TextEditingController _instructionsController;
  
  String _selectedSize = 'Medium';
  final List<String> _sizes = ['Small', 'Medium', 'Large'];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.pet['name']);
    _breedController = TextEditingController(text: widget.pet['breed']);
    String ageText = widget.pet['age']?.replaceAll(RegExp(r'[^0-9]'), '') ?? '0';
    _ageController = TextEditingController(text: ageText);
    _instructionsController = TextEditingController(text: widget.pet['instructions']);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _breedController.dispose();
    _ageController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  Future<void> _updatePet() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final String? petId = widget.pet['id'];
        if (petId == null) throw Exception("Pet ID is missing");

        await _firestoreService.updatePet(petId, {
          'name': _nameController.text.trim(),
          'breed': _breedController.text.trim(),
          'age': int.parse(_ageController.text.trim()),
          'description': _instructionsController.text.trim(),
        });

        if (mounted) {
          final loc = AppLocalizations.of(context)!;
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(loc.petUpdatedSuccessfully)),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error updating pet: $e')),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
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
          loc.editPet,
          style: TextStyle(color: theme.textTheme.titleLarge?.color, fontWeight: FontWeight.bold),
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
                  Center(
                    child: GestureDetector(
                      onTap: () {},
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: theme.dividerColor, width: 2),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.camera_alt_outlined, color: primaryBlue, size: 32),
                            const SizedBox(height: 4),
                            Text(
                              loc.changePhoto,
                              style: const TextStyle(fontSize: 12, color: primaryBlue, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  Text(
                    loc.petName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _nameController,
                    decoration: _inputStyle('e.g. Max'),
                    validator: (value) => value == null || value.isEmpty ? loc.enterPetName : null,
                  ),

                  const SizedBox(height: 20),

                  Text(
                    loc.breed,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _breedController,
                    decoration: _inputStyle('e.g. Golden Retriever'),
                    validator: (value) => value == null || value.isEmpty ? loc.enterBreed : null,
                  ),

                  const SizedBox(height: 20),

                  Text(
                    loc.ageYears,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _ageController,
                    keyboardType: TextInputType.number,
                    decoration: _inputStyle('e.g. 3'),
                    validator: (value) => value == null || value.isEmpty ? loc.enterAge : null,
                  ),

                  const SizedBox(height: 24),

                  Text(
                    loc.petSize,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: _sizes.map((size) => _buildSizeOption(size)).toList(),
                  ),

                  const SizedBox(height: 24),

                  Text(
                    loc.specialInstructions,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _instructionsController,
                    maxLines: 4,
                    decoration: _inputStyle('e.g. Allergies, temperament, favorite treats...'),
                  ),

                  const SizedBox(height: 40),

                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _updatePet,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        loc.saveChanges,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  Widget _buildSizeOption(String size) {
    final theme = Theme.of(context);
    bool isSelected = _selectedSize == size;
    const primaryBlue = Color(0xFF2563EB);

    return GestureDetector(
      onTap: () => setState(() => _selectedSize = size),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.25,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? primaryBlue : theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? primaryBlue : theme.dividerColor,
          ),
        ),
        child: Center(
          child: Text(
            size,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : theme.textTheme.bodyLarge?.color,
            ),
          ),
        ),
      ),
    );
  }
}

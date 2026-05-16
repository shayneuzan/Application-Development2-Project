import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../services/firestore_service.dart';

class EditProfileScreen extends StatefulWidget {
  final String currentName;
  final String currentEmail;
  final String? currentPhone;
  final String? currentAddress;

  const EditProfileScreen({
    super.key,
    required this.currentName,
    required this.currentEmail,
    this.currentPhone,
    this.currentAddress,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  
  final FirestoreService _firestoreService = FirestoreService();
  final User? _user = FirebaseAuth.instance.currentUser;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentName);
    _emailController = TextEditingController(text: widget.currentEmail);
    _phoneController = TextEditingController(text: widget.currentPhone ?? '');
    _addressController = TextEditingController(text: widget.currentAddress ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    if (_user == null) return;
    final loc = AppLocalizations.of(context)!;

    setState(() => _isLoading = true);

    try {
      await _firestoreService.updateUser(_user.uid, {
        'name': _nameController.text.trim(),
        'phoneNumber': _phoneController.text.trim(),
        'address': _addressController.text.trim(),
      });

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loc.profileUpdatedSuccessfully)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating profile: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;
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
          loc.editProfile,
          style: TextStyle(color: theme.textTheme.titleLarge?.color, fontWeight: FontWeight.bold),
        ),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: theme.brightness == Brightness.dark ? Colors.white10 : const Color(0xFFF1F5F9),
                        child: Icon(Icons.person, size: 60, color: theme.hintColor),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: primaryBlue,
                            shape: BoxShape.circle,
                            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                          ),
                          child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                _buildLabel(loc.fullName),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameController,
                  decoration: _inputStyle(loc.enterFullName),
                ),
                const SizedBox(height: 20),

                _buildLabel(loc.emailAddress),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _emailController,
                  enabled: false,
                  keyboardType: TextInputType.emailAddress,
                  decoration: _inputStyle(loc.enterEmail),
                ),
                const SizedBox(height: 20),

                _buildLabel(loc.phoneNumber),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: _inputStyle(loc.enterPhoneNumber),
                ),
                const SizedBox(height: 20),

                _buildLabel(loc.address),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _addressController,
                  maxLines: 2,
                  decoration: _inputStyle(loc.enterAddress),
                ),
                const SizedBox(height: 40),

                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _updateProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
    );
  }

  Widget _buildLabel(String label) {
    return Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14));
  }

  InputDecoration _inputStyle(String hint) {
    return InputDecoration(
      hintText: hint,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }
}

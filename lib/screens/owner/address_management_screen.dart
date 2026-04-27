import 'package:flutter/material.dart';
import 'edit_address_screen.dart';

class AddressManagementScreen extends StatefulWidget {
  const AddressManagementScreen({super.key});

  @override
  State<AddressManagementScreen> createState() => _AddressManagementScreenState();
}

class _AddressManagementScreenState extends State<AddressManagementScreen> {
  final List<Map<String, String>> _addresses = [
    {
      'label': 'Home',
      'address': '123 Maple Street, Springfield, IL 62704',
      'isDefault': 'true'
    },
    {
      'label': 'Office',
      'address': '456 Business Way, Chicago, IL 60601',
      'isDefault': 'false'
    },
  ];

  void _setDefaultAddress(int index) {
    setState(() {
      for (int i = 0; i < _addresses.length; i++) {
        _addresses[i]['isDefault'] = (i == index).toString();
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${_addresses[index]['label']} set as default address')),
    );
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
          'Saved Addresses',
          style: TextStyle(color: textDark, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your Locations',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textDark),
            ),
            const SizedBox(height: 16),
            ..._addresses.asMap().entries.map((entry) => _buildAddressItem(entry.key, entry.value)),
            const SizedBox(height: 24),
            
            // Add New Address Button
            GestureDetector(
              onTap: () {
                _showAddAddressBottomSheet(context);
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0), style: BorderStyle.solid),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_location_alt_outlined, color: primaryBlue),
                    SizedBox(width: 8),
                    Text(
                      'Add New Address',
                      style: TextStyle(color: primaryBlue, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressItem(int index, Map<String, String> address) {
    bool isDefault = address['isDefault'] == 'true';
    const primaryBlue = Color(0xFF2563EB);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: isDefault ? primaryBlue : Colors.transparent, width: 2),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              address['label'] == 'Home' ? Icons.home_outlined : Icons.work_outline,
              color: const Color(0xFF64748B),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      address['label']!,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    if (isDefault) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'DEFAULT',
                          style: TextStyle(color: primaryBlue, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  address['address']!,
                  style: const TextStyle(color: Color(0xFF64748B), fontSize: 13, height: 1.4),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Color(0xFFCBD5E1)),
            onSelected: (value) {
              if (value == 'default') {
                _setDefaultAddress(index);
              } else if (value == 'edit') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditAddressScreen(address: address),
                  ),
                );
              } else if (value == 'delete') {
                setState(() {
                  _addresses.removeAt(index);
                });
              }
            },
            itemBuilder: (context) => [
              if (!isDefault) const PopupMenuItem(value: 'default', child: Text('Set as default')),
              const PopupMenuItem(value: 'edit', child: Text('Edit address')),
              const PopupMenuItem(value: 'delete', child: Text('Remove', style: TextStyle(color: Colors.red))),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddAddressBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          top: 24,
          left: 24,
          right: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Add New Address',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            _buildTextField('Address Label (e.g. Home, Work)'),
            const SizedBox(height: 16),
            _buildTextField('Street Address', prefix: Icons.location_on_outlined),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildTextField('City')),
                const SizedBox(width: 16),
                Expanded(child: _buildTextField('Postal Code')),
              ],
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Save Address', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String hint, {IconData? prefix}) {
    return TextField(
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: prefix != null ? Icon(prefix, size: 20, color: const Color(0xFF64748B)) : null,
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}

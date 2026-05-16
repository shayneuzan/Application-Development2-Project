import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geocoding/geocoding.dart';
import '../../l10n/generated/app_localizations.dart';
import 'edit_address_screen.dart';
import '../../services/firestore_service.dart';
import '../../services/location_service.dart';
import '../../models/user_model.dart';

class AddressManagementScreen extends StatefulWidget {
  const AddressManagementScreen({super.key});

  @override
  State<AddressManagementScreen> createState() => _AddressManagementScreenState();
}

class _AddressManagementScreenState extends State<AddressManagementScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final LocationService _locationService = LocationService();
  final String? _userId = FirebaseAuth.instance.currentUser?.uid;
  
  bool _isVerifying = false;
  bool _isSearching = false;
  String? _searchError;
  
  final TextEditingController _labelController = TextEditingController();
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _postalController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> _predictions = [];
  Timer? _debounce;

  @override
  void dispose() {
    _labelController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _postalController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _onSearchChanged(String query, StateSetter setModalState) async {
    final loc = AppLocalizations.of(context)!;
    if (query.isEmpty) {
      setModalState(() {
        _predictions = [];
        _isSearching = false;
        _searchError = null;
      });
      return;
    }

    if (_debounce?.isActive ?? false) _debounce?.cancel();
    
    setModalState(() {
      _isSearching = true;
      _searchError = null;
    });

    _debounce = Timer(const Duration(milliseconds: 500), () async {
      try {
        final predictions = await _locationService.getAutocomplete(query);
        if (mounted) {
          setModalState(() {
            _predictions = predictions;
            _isSearching = false;
            if (predictions.isEmpty && query.length > 2) {
              _searchError = loc.noAddressesFound;
            }
          });
        }
      } catch (e) {
        if (mounted) {
          setModalState(() {
            _isSearching = false;
            _searchError = e.toString().replaceFirst("Exception: ", "");
          });
        }
      }
    });
  }

  Future<void> _selectPrediction(Map<String, dynamic> prediction, StateSetter setModalState) async {
    final placeId = prediction['place_id'];
    
    setModalState(() => _isSearching = true);
    final details = await _locationService.getPlaceDetails(placeId);

    if (mounted) {
      setModalState(() {
        if (details.isNotEmpty) {
          _streetController.text = details['street'] ?? "";
          _cityController.text = details['city'] ?? "";
          _postalController.text = details['postalCode'] ?? "";
        }
        _predictions = [];
        _isSearching = false;
        _searchController.clear();
      });
    }
  }

  Future<void> _setDefaultAddress(List<Map<String, dynamic>> addresses, int index) async {
    if (_userId == null) return;
    final loc = AppLocalizations.of(context)!;

    List<Map<String, dynamic>> updatedAddresses = List.from(addresses);
    for (int i = 0; i < updatedAddresses.length; i++) {
      updatedAddresses[i]['isDefault'] = (i == index);
    }

    String mainAddress = updatedAddresses[index]['address'];

    await _firestoreService.updateUser(_userId, {
      'savedAddresses': updatedAddresses,
      'address': mainAddress,
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.setAsDefaultSuccess(updatedAddresses[index]['label']))),
      );
    }
  }

  Future<void> _deleteAddress(List<Map<String, dynamic>> addresses, int index) async {
    if (_userId == null) return;

    List<Map<String, dynamic>> updatedAddresses = List.from(addresses);
    updatedAddresses.removeAt(index);

    await _firestoreService.updateUser(_userId, {
      'savedAddresses': updatedAddresses,
    });
  }

  Future<void> _addNewAddress(List<Map<String, dynamic>> addresses) async {
    if (_userId == null) return;
    final loc = AppLocalizations.of(context)!;

    final String label = _labelController.text.trim();
    final String street = _streetController.text.trim();
    final String city = _cityController.text.trim();
    final String postal = _postalController.text.trim();

    if (label.isEmpty || street.isEmpty || city.isEmpty || postal.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.pleaseFillAllFields)),
      );
      return;
    }

    final String fullAddress = "$street, $city, $postal";
    
    setState(() => _isVerifying = true);

    try {
      List<Location> locations = await locationFromAddress(fullAddress);
      
      if (locations.isNotEmpty) {
        List<Map<String, dynamic>> updatedAddresses = List.from(addresses);
        updatedAddresses.add({
          'label': label,
          'address': fullAddress,
          'isDefault': updatedAddresses.isEmpty,
        });

        Map<String, dynamic> updateData = {'savedAddresses': updatedAddresses};
        if (updatedAddresses.length == 1) {
          updateData['address'] = fullAddress;
        }

        await _firestoreService.updateUser(_userId, updateData);
        
        _labelController.clear();
        _streetController.clear();
        _cityController.clear();
        _postalController.clear();
        
        if (mounted) Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(loc.verifyAddressError),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isVerifying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;
    const primaryBlue = Color(0xFF2563EB);

    if (_userId == null) {
      return Scaffold(body: Center(child: Text(loc.pleaseLogin)));
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.cardColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.iconTheme.color),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          loc.savedAddresses,
          style: TextStyle(color: theme.textTheme.titleLarge?.color, fontWeight: FontWeight.bold),
        ),
      ),
      body: StreamBuilder<UserModel>(
        stream: _firestoreService.getUserStream(_userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return Center(child: Text(loc.errorLoadingData));
          }

          final user = snapshot.data!;
          final addresses = user.savedAddresses;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loc.yourLocation,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                if (addresses.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Text(loc.noSavedAddresses, style: const TextStyle(color: Colors.grey)),
                    ),
                  )
                else
                  ...addresses.asMap().entries.map((entry) => _buildAddressItem(entry.key, entry.value, addresses)),
                
                const SizedBox(height: 24),
                
                GestureDetector(
                  onTap: () => _showAddAddressBottomSheet(context, addresses),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: theme.dividerColor, style: BorderStyle.solid),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.add_location_alt_outlined, color: primaryBlue),
                        const SizedBox(width: 8),
                        Text(
                          loc.addNewAddress,
                          style: const TextStyle(color: primaryBlue, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAddressItem(int index, Map<String, dynamic> address, List<Map<String, dynamic>> allAddresses) {
    final theme = Theme.of(context);
    bool isDefault = address['isDefault'] == true;
    const primaryBlue = Color(0xFF2563EB);
    final loc = AppLocalizations.of(context)!;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
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
              color: theme.brightness == Brightness.dark ? Colors.white10 : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              address['label'] == 'Home' ? Icons.home_outlined : Icons.work_outline,
              color: theme.brightness == Brightness.dark ? Colors.white70 : const Color(0xFF64748B),
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
                      address['label'] ?? loc.addressFallback,
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
                        child: Text(
                          loc.defaultTag,
                          style: const TextStyle(color: primaryBlue, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  address['address'] ?? '',
                  style: TextStyle(color: theme.textTheme.bodySmall?.color, fontSize: 13, height: 1.4),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: theme.iconTheme.color?.withAlpha(127)),
            onSelected: (value) {
              if (value == 'default') {
                _setDefaultAddress(allAddresses, index);
              } else if (value == 'edit') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditAddressScreen(
                      address: address,
                      index: index,
                    ),
                  ),
                );
              } else if (value == 'delete') {
                _deleteAddress(allAddresses, index);
              }
            },
            itemBuilder: (context) => [
              if (!isDefault) PopupMenuItem(value: 'default', child: Text(loc.setAsDefault)),
              PopupMenuItem(value: 'edit', child: Text(loc.editAddress)),
              PopupMenuItem(value: 'delete', child: Text(loc.remove, style: const TextStyle(color: Colors.red))),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddAddressBottomSheet(BuildContext context, List<Map<String, dynamic>> currentAddresses) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;
    const primaryBlue = Color(0xFF2563EB);

    _searchController.clear();
    _predictions = [];
    _searchError = null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              top: 24,
              left: 24,
              right: 24,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        loc.addNewAddress,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      )
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Search Bar
                  _buildTextField(
                    _searchController, 
                    loc.searchAddressHint,
                    prefix: Icons.search,
                    suffix: _isSearching 
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) 
                        : _searchController.text.isNotEmpty 
                          ? IconButton(icon: const Icon(Icons.clear, size: 18), onPressed: () {
                              _searchController.clear();
                              _onSearchChanged("", setModalState);
                            }) 
                          : null,
                    onChanged: (val) => _onSearchChanged(val, setModalState),
                  ),

                  // Predictions List or Error Message
                  if (_searchError != null)
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      padding: const EdgeInsets.all(12),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.red.withAlpha(12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _searchError!, 
                        style: const TextStyle(color: Colors.redAccent, fontSize: 13)
                      ),
                    ),

                  if (_predictions.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(25),
                            blurRadius: 10,
                          )
                        ],
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _predictions.length,
                        separatorBuilder: (context, index) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final p = _predictions[index];
                          final mainText = p['structured_formatting']?['main_text'] ?? p['description'];
                          final secondaryText = p['structured_formatting']?['secondary_text'] ?? "";
                          
                          return ListTile(
                            leading: Icon(Icons.location_on_outlined, size: 20, color: theme.brightness == Brightness.dark ? Colors.white70 : const Color(0xFF64748B)),
                            title: Text(mainText, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            subtitle: secondaryText.isNotEmpty ? Text(secondaryText, style: const TextStyle(fontSize: 12)) : null,
                            onTap: () => _selectPrediction(p, setModalState),
                          );
                        },
                      ),
                    ),

                  const SizedBox(height: 32),
                  _buildLabel(loc.addressLabel),
                  const SizedBox(height: 8),
                  _buildTextField(_labelController, loc.addressExample),
                  
                  const SizedBox(height: 24),
                  _buildLabel(loc.manualEntryDetails),
                  const SizedBox(height: 8),
                  _buildTextField(_streetController, loc.streetAddress, prefix: Icons.location_on_outlined),
                  
                  const SizedBox(height: 16),
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
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isVerifying 
                        ? null 
                        : () async {
                            setModalState(() => _isVerifying = true);
                            await _addNewAddress(currentAddresses);
                            if (mounted) setModalState(() => _isVerifying = false);
                          },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      child: _isVerifying 
                        ? const SizedBox(
                            height: 20, 
                            width: 20, 
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                          )
                        : Text(loc.verifyAndSaveAddress, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        }
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Text(
      label,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, {IconData? prefix, Widget? suffix, Function(String)? onChanged}) {
    final theme = Theme.of(context);
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: prefix != null ? Icon(prefix, size: 20, color: theme.brightness == Brightness.dark ? Colors.white70 : const Color(0xFF64748B)) : null,
        suffixIcon: suffix,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}

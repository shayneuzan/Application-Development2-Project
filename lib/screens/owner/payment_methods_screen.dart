import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/firestore_service.dart';
import '../../models/user_model.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final String? _userId = FirebaseAuth.instance.currentUser?.uid;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();
  final TextEditingController _expiryController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _numberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  Future<void> _setDefaultCard(List<Map<String, dynamic>> cards, int index) async {
    if (_userId == null) return;
    List<Map<String, dynamic>> updatedCards = List.from(cards);
    for (int i = 0; i < updatedCards.length; i++) {
      updatedCards[i]['isDefault'] = (i == index);
    }
    await _firestoreService.updateUser(_userId!, {'paymentMethods': updatedCards});
  }

  Future<void> _removeCard(List<Map<String, dynamic>> cards, int index) async {
    if (_userId == null) return;
    List<Map<String, dynamic>> updatedCards = List.from(cards);
    updatedCards.removeAt(index);
    await _firestoreService.updateUser(_userId!, {'paymentMethods': updatedCards});
  }

  Future<void> _addCard(List<Map<String, dynamic>> cards) async {
    if (_userId == null) return;
    
    String name = _nameController.text.trim();
    String number = _numberController.text.replaceAll(' ', '');
    String expiry = _expiryController.text.trim();
    
    if (name.isEmpty || number.length < 12 || expiry.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid card details')),
      );
      return;
    }
    
    String last4 = number.substring(number.length - 4);
    String type = number.startsWith('4') ? 'Visa' : 'Mastercard';

    List<Map<String, dynamic>> updatedCards = List.from(cards);
    updatedCards.add({
      'cardholderName': name,
      'type': type,
      'last4': last4,
      'expiry': expiry,
      'isDefault': updatedCards.isEmpty,
    });

    await _firestoreService.updateUser(_userId!, {'paymentMethods': updatedCards});
    
    _nameController.clear();
    _numberController.clear();
    _expiryController.clear();
    _cvvController.clear();
    
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF2563EB);
    const textDark = Color(0xFF1E293B);
    const backgroundGray = Color(0xFFF8FAFC);

    if (_userId == null) return const Scaffold(body: Center(child: Text("Please log in")));

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
          'Payment Methods',
          style: TextStyle(color: textDark, fontWeight: FontWeight.bold),
        ),
      ),
      body: StreamBuilder<UserModel>(
        stream: _firestoreService.getUserStream(_userId!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final user = snapshot.data;
          final cards = user?.paymentMethods ?? [];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your Cards',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textDark),
                ),
                const SizedBox(height: 16),
                if (cards.isEmpty)
                  const Center(child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Text("No cards saved yet", style: TextStyle(color: Colors.grey)),
                  ))
                else
                  ...cards.asMap().entries.map((entry) => _buildCardItem(entry.key, entry.value, cards)),
                
                const SizedBox(height: 24),
                GestureDetector(
                  onTap: () => _showAddCardBottomSheet(context, cards),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_circle_outline, color: primaryBlue),
                        SizedBox(width: 8),
                        Text('Add New Card', style: TextStyle(color: primaryBlue, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                const Text('Other Methods', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textDark)),
                const SizedBox(height: 16),
                _buildOtherMethod(Icons.account_balance_wallet_outlined, 'Apple Pay'),
                const SizedBox(height: 12),
                _buildOtherMethod(Icons.paypal_outlined, 'PayPal'),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCardItem(int index, Map<String, dynamic> card, List<Map<String, dynamic>> allCards) {
    bool isDefault = card['isDefault'] == true;
    const primaryBlue = Color(0xFF2563EB);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
        border: Border.all(color: isDefault ? primaryBlue : Colors.transparent, width: 2),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(12)),
            child: Icon(card['type'] == 'Visa' ? Icons.credit_card : Icons.credit_card_outlined, color: const Color(0xFF64748B)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('${card['type']} •••• ${card['last4']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    if (isDefault) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(6)),
                        child: const Text('DEFAULT', style: TextStyle(color: primaryBlue, fontSize: 9, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ],
                ),
                Text('Expires ${card['expiry']}', style: const TextStyle(color: Color(0xFF64748B), fontSize: 13)),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Color(0xFFCBD5E1), size: 20),
            onSelected: (value) {
              if (value == 'default') _setDefaultCard(allCards, index);
              if (value == 'remove') _removeCard(allCards, index);
            },
            itemBuilder: (context) => [
              if (!isDefault) const PopupMenuItem(value: 'default', child: Text('Set as default')),
              const PopupMenuItem(value: 'remove', child: Text('Remove card', style: TextStyle(color: Colors.red))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOtherMethod(IconData icon, String title) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF64748B)),
          const SizedBox(width: 16),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15)),
          const Spacer(),
          const Icon(Icons.chevron_right, color: Color(0xFFCBD5E1)),
        ],
      ),
    );
  }

  void _showAddCardBottomSheet(BuildContext context, List<Map<String, dynamic>> currentCards) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, top: 24, left: 24, right: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Add New Card', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            _buildTextField(_nameController, 'Cardholder Name'),
            const SizedBox(height: 16),
            _buildTextField(_numberController, 'Card Number', prefix: Icons.credit_card),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildTextField(_expiryController, 'Expiry (MM/YY)')),
                const SizedBox(width: 16),
                Expanded(child: _buildTextField(_cvvController, 'CVV', obscure: true)),
              ],
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () => _addCard(currentCards),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Add Card', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, {IconData? prefix, bool obscure = false}) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: prefix != null ? Icon(prefix, size: 20, color: const Color(0xFF64748B)) : null,
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}

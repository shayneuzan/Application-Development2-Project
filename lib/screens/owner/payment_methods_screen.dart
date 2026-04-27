import 'package:flutter/material.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  final List<Map<String, String>> _cards = [
    {'type': 'Visa', 'last4': '4242', 'expiry': '12/26', 'isDefault': 'true'},
    {'type': 'Mastercard', 'last4': '8888', 'expiry': '09/25', 'isDefault': 'false'},
  ];

  void _setDefaultCard(int index) {
    setState(() {
      for (int i = 0; i < _cards.length; i++) {
        _cards[i]['isDefault'] = (i == index).toString();
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${_cards[index]['type']} •••• ${_cards[index]['last4']} set as default card')),
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
          'Payment Methods',
          style: TextStyle(color: textDark, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your Cards',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textDark),
            ),
            const SizedBox(height: 16),
            ..._cards.asMap().entries.map((entry) => _buildCardItem(entry.key, entry.value)),
            const SizedBox(height: 24),
            
            // Add New Card Button
            GestureDetector(
              onTap: () {
                _showAddCardBottomSheet(context);
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
                    Icon(Icons.add_circle_outline, color: primaryBlue),
                    SizedBox(width: 8),
                    Text(
                      'Add New Card',
                      style: TextStyle(color: primaryBlue, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 40),

            // Other Payment Methods
            const Text(
              'Other Methods',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textDark),
            ),
            const SizedBox(height: 16),
            _buildOtherMethod(Icons.account_balance_wallet_outlined, 'Apple Pay'),
            const SizedBox(height: 12),
            _buildOtherMethod(Icons.paypal_outlined, 'PayPal'),
          ],
        ),
      ),
    );
  }

  Widget _buildCardItem(int index, Map<String, String> card) {
    bool isDefault = card['isDefault'] == 'true';
    const primaryBlue = Color(0xFF2563EB);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
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
              card['type'] == 'Visa' ? Icons.credit_card : Icons.credit_card_outlined,
              color: const Color(0xFF64748B),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        '${card['type']} •••• ${card['last4']}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold, 
                          fontSize: 15,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    if (isDefault) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'DEFAULT',
                          style: TextStyle(color: primaryBlue, fontSize: 9, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  'Expires ${card['expiry']}',
                  style: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: const Icon(Icons.more_vert, color: Color(0xFFCBD5E1), size: 20),
            onSelected: (value) {
              if (value == 'default') {
                _setDefaultCard(index);
              } else if (value == 'remove') {
                setState(() {
                  _cards.removeAt(index);
                });
              }
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
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF64748B)),
          const SizedBox(width: 16),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
          ),
          const Spacer(),
          const Icon(Icons.chevron_right, color: Color(0xFFCBD5E1)),
        ],
      ),
    );
  }

  void _showAddCardBottomSheet(BuildContext context) {
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
              'Add New Card',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            _buildTextField('Cardholder Name'),
            const SizedBox(height: 16),
            _buildTextField('Card Number', prefix: Icons.credit_card),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildTextField('Expiry (MM/YY)')),
                const SizedBox(width: 16),
                Expanded(child: _buildTextField('CVV', obscure: true)),
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
                child: const Text('Add Card', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String hint, {IconData? prefix, bool obscure = false}) {
    return TextField(
      obscureText: obscure,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: prefix != null ? Icon(prefix, size: 20) : null,
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}

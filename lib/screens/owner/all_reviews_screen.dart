import 'package:flutter/material.dart';
import '../../services/firestore_service.dart';
import 'package:intl/intl.dart';

class AllReviewsScreen extends StatelessWidget {
  final String walkerId;
  final String walkerName;

  const AllReviewsScreen({
    super.key, 
    required this.walkerId, 
    required this.walkerName
  });

  @override
  Widget build(BuildContext context) {
    const textDark = Color(0xFF1E293B);
    const backgroundGray = Color(0xFFF8FAFC);
    final FirestoreService firestoreService = FirestoreService();

    return Scaffold(
      backgroundColor: backgroundGray,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Reviews for $walkerName',
          style: const TextStyle(color: textDark, fontWeight: FontWeight.bold),
        ),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: firestoreService.getReviewsByWalker(walkerId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final reviews = snapshot.data ?? [];

          if (reviews.isEmpty) {
            return const Center(child: Text('No reviews yet.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: reviews.length,
            itemBuilder: (context, index) {
              final review = reviews[index];
              return _buildReviewCard(review);
            },
          );
        },
      ),
    );
  }

  Widget _buildReviewCard(Map<String, dynamic> review) {
    String dateStr = 'Recent';
    if (review['createdAt'] != null) {
      final date = (review['createdAt'] as dynamic).toDate();
      dateStr = DateFormat('MMM dd, yyyy').format(date);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
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
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                review['userName'] ?? 'User',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Text(
                dateStr,
                style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: List.generate(5, (index) {
              return Icon(
                index < (review['rating'] ?? 0) ? Icons.star : Icons.star_border,
                color: Colors.orange,
                size: 16,
              );
            }),
          ),
          const SizedBox(height: 12),
          Text(
            review['comment'] ?? '',
            style: const TextStyle(color: Color(0xFF64748B), fontSize: 14, height: 1.5),
          ),
        ],
      ),
    );
  }
}

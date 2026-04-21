import 'package:flutter/material.dart';

class AllReviewsScreen extends StatelessWidget {
  final String walkerName;

  const AllReviewsScreen({super.key, required this.walkerName});

  @override
  Widget build(BuildContext context) {
    const textDark = Color(0xFF1E293B);
    const backgroundGray = Color(0xFFF8FAFC);

    final List<Map<String, dynamic>> reviews = [
      {
        'name': 'John Doe',
        'comment': 'Sarah is amazing! My dog Max loves her and always comes back happy.',
        'rating': 5.0,
        'date': '2 days ago'
      },
      {
        'name': 'Emily Wilson',
        'comment': 'Very professional and punctual. Highly recommended!',
        'rating': 4.5,
        'date': '1 week ago'
      },
      {
        'name': 'Michael Brown',
        'comment': 'Great communication throughout the walk.',
        'rating': 5.0,
        'date': '2 weeks ago'
      },
    ];

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
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: reviews.length,
        itemBuilder: (context, index) {
          final review = reviews[index];
          return _buildReviewCard(review);
        },
      ),
    );
  }

  Widget _buildReviewCard(Map<String, dynamic> review) {
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
                review['name'],
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Text(
                review['date'],
                style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: List.generate(5, (index) {
              return Icon(
                index < review['rating'] ? Icons.star : Icons.star_border,
                color: Colors.orange,
                size: 16,
              );
            }),
          ),
          const SizedBox(height: 12),
          Text(
            review['comment'],
            style: const TextStyle(color: Color(0xFF64748B), fontSize: 14, height: 1.5),
          ),
        ],
      ),
    );
  }
}

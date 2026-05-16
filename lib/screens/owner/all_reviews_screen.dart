import 'package:flutter/material.dart';
import '../../l10n/generated/app_localizations.dart';
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
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;
    final FirestoreService firestoreService = FirestoreService();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.cardColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.iconTheme.color),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          loc.reviewsFor(walkerName),
          style: TextStyle(color: theme.textTheme.titleLarge?.color, fontWeight: FontWeight.bold),
        ),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: firestoreService.getReviewsByWalker(walkerId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('${loc.error}: ${snapshot.error}'),
            );
          }

          final reviews = snapshot.data ?? [];

          if (reviews.isEmpty) {
            return Center(child: Text(loc.noReviewsYet),);
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: reviews.length,
            itemBuilder: (context, index) {
              final review = reviews[index];
              return _buildReviewCard(context, review);
            },
          );
        },
      ),
    );
  }

  Widget _buildReviewCard(BuildContext context, Map<String, dynamic> review) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;
    String dateStr = loc.recent;
    if (review['createdAt'] != null) {
      final date = (review['createdAt'] as dynamic).toDate();
      dateStr = DateFormat('MMM dd, yyyy').format(date);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
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
                review['userName'] ?? loc.user,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Text(
                dateStr,
                style: TextStyle(color: theme.textTheme.bodySmall?.color, fontSize: 12),
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
            style: TextStyle(color: theme.textTheme.bodyMedium?.color, fontSize: 14, height: 1.5),
          ),
        ],
      ),
    );
  }
}

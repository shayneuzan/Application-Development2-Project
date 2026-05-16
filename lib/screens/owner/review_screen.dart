import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../services/firestore_service.dart';
import '../../services/auth_service.dart';

class ReviewScreen extends StatefulWidget {
  final String walkerId;
  final String walkerName;
  final String dogName;
  final String? bookingId;

  const ReviewScreen({
    super.key,
    required this.walkerId,
    required this.walkerName,
    required this.dogName,
    this.bookingId,
  });

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  int _rating = 0;
  final _commentController = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);

    try {
      final userData = await _authService.getCurrentUserData();
      
      await _firestoreService.addReview({
        'walkerId': widget.walkerId,
        'ownerId': user.uid,
        'userName': userData?.name ?? 'User',
        'rating': _rating,
        'comment': _commentController.text.trim(),
        'dogName': widget.dogName,
      });

      if (widget.bookingId != null) {
        await _firestoreService.markBookingAsReviewed(widget.bookingId!);
      }

      if (mounted) {
        final loc = AppLocalizations.of(context)!;
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loc.thankYouForReview)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error submitting review: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
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
          loc.writeReview,
          style: TextStyle(color: theme.textTheme.titleLarge?.color, fontWeight: FontWeight.bold),
        ),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                CircleAvatar(
                  radius: 40,
                  backgroundColor: isDarkMode ? Colors.white10 : const Color(0xFFEFF6FF),
                  child: const Icon(Icons.person, size: 40, color: primaryBlue),
                ),
                const SizedBox(height: 16),
                Text(
                  loc.howWasWalk(widget.walkerName),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  loc.forYourDog(widget.dogName),
                  style: TextStyle(color: theme.textTheme.bodySmall?.color, fontSize: 16),
                ),
                const SizedBox(height: 32),
                
                // Star Rating
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return IconButton(
                      onPressed: () => setState(() => _rating = index + 1),
                      icon: Icon(
                        index < _rating ? Icons.star : Icons.star_border,
                        color: Colors.orange,
                        size: 40,
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 32),

                // Comment Box
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    loc.tellUsMoreAbout,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _commentController,
                  maxLines: 5,
                  decoration: InputDecoration(
                    hintText: loc.describeWalk,
                    contentPadding: const EdgeInsets.all(16),
                  ),
                ),
                const SizedBox(height: 40),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _rating == 0 ? null : _submitReview,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBlue,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: theme.disabledColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      loc.submitReview,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../l10n/generated/app_localizations.dart';
import 'booking_screen.dart';
import 'all_reviews_screen.dart';
import '../../models/walker_model.dart';
import '../../models/user_model.dart';
import '../../services/firestore_service.dart';

class WalkerProfileScreen extends StatefulWidget {
  final String id;
  final String name;
  final String initials;
  final double rating;
  final int walksCount;
  final double price;
  final WalkerModel? walker;

  const WalkerProfileScreen({
    super.key,
    required this.id,
    required this.name,
    required this.initials,
    required this.rating,
    required this.walksCount,
    required this.price,
    this.walker,
  });

  @override
  State<WalkerProfileScreen> createState() => _WalkerProfileScreenState();
}

class _WalkerProfileScreenState extends State<WalkerProfileScreen> {
  bool _showReviews = false;
  final FirestoreService _firestoreService = FirestoreService();
  final String? _userId = FirebaseAuth.instance.currentUser?.uid;

  void _toggleFavorite(bool isCurrentlyFavorite) {
    if (_userId == null) return;
    _firestoreService.toggleFavorite(_userId, widget.id, !isCurrentlyFavorite);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final loc = AppLocalizations.of(context)!;
    const primaryBlue = Color(0xFF2563EB);

    return Scaffold(
      body: StreamBuilder<UserModel>(
        stream: _userId != null ? _firestoreService.getUserStream(_userId) : const Stream.empty(),
        builder: (context, userSnapshot) {
          final isFavorite = userSnapshot.data?.favoriteWalkers.contains(widget.id) ?? false;

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 260,
                pinned: true,
                backgroundColor: primaryBlue,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                actions: [
                  IconButton(
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.red : Colors.white,
                    ),
                    onPressed: () => _toggleFavorite(isFavorite),
                  ),
                  const SizedBox(width: 8),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    color: primaryBlue,
                    child: Center(
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.white.withOpacity(0.2),
                        child: Text(
                          widget.initials,
                          style: const TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                  decoration: BoxDecoration(
                    color: theme.scaffoldBackgroundColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.name,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  loc.professionalWalker,
                                  style: TextStyle(color: theme.hintColor, fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '\$${widget.price % 1 == 0 ? widget.price.toInt() : widget.price.toStringAsFixed(2)}/hr',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: primaryBlue,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatColumn(loc.rating, widget.rating.toStringAsFixed(2), Icons.star, Colors.orange),
                          _buildStatColumn(loc.walks, widget.walksCount.toString(), Icons.pets, primaryBlue),
                          _buildStatColumn(loc.experience, '${widget.walker?.experienceYears ?? 3} ${loc.years}', Icons.timer, Colors.green),
                        ],
                      ),

                      const SizedBox(height: 32),

                      Container(
                        height: 50,
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: isDarkMode ? Colors.black26 : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _showReviews = false),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: !_showReviews ? theme.cardColor : Colors.transparent,
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: !_showReviews 
                                      ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))]
                                      : [],
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    loc.about,
                                    style: TextStyle(
                                      color: !_showReviews ? primaryBlue : theme.hintColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _showReviews = true),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: _showReviews ? theme.cardColor : Colors.transparent,
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: _showReviews 
                                      ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))]
                                      : [],
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    loc.reviews,
                                    style: TextStyle(
                                      color: _showReviews ? primaryBlue : theme.hintColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: _showReviews ? _buildReviewsList() : _buildAboutSection(),
                      ),
                      
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          );
        }
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.cardColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BookingScreen(
                    walkerId: widget.id,
                    walkerName: widget.name,
                    hourlyRate: widget.price,
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            child: Text(
              loc.bookNow,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, IconData icon, Color color) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        Text(label, style: TextStyle(color: theme.hintColor, fontSize: 12)),
      ],
    );
  }

  Widget _buildAboutSection() {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final String bio = widget.walker?.bio ?? 'Passionate dog lover with years of experience.';
    final List<String> services = widget.walker?.services ?? ['GPS Tracking', 'Photo Updates', 'Feeding', 'Fresh Water'];

    return Column(
      key: const ValueKey('about'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(loc.about, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Text(bio, style: TextStyle(color: theme.textTheme.bodyMedium?.color, height: 1.5)),
        const SizedBox(height: 24),
        Text(loc.servicesIncluded, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: services.map((s) => _buildServiceChip(s)).toList(),
        ),
      ],
    );
  }

  Widget _buildServiceChip(String label) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
    );
  }

  Widget _buildReviewsList() {
    final loc = AppLocalizations.of(context)!;
    return StreamBuilder<List<Map<String, dynamic>>>(
      key: const ValueKey('reviews'),
      stream: _firestoreService.getReviewsByWalker(widget.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()));
        }
        final reviews = snapshot.data ?? [];
        if (reviews.isEmpty) return Center(child: Padding(padding: const EdgeInsets.all(40), child: Text(loc.noReviewsYet)));

        return Column(
          children: [
            ...reviews.take(3).map((r) => _buildReviewItem(r)),
            if (reviews.length > 3)
              TextButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => AllReviewsScreen(walkerId: widget.id, walkerName: widget.name)));
                },
                child: Text(loc.seeAll, style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
          ],
        );
      },
    );
  }

  Widget _buildReviewItem(Map<String, dynamic> review) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(review['userName'] ?? 'User', style: const TextStyle(fontWeight: FontWeight.bold)),
              Row(children: List.generate(5, (i) => Icon(Icons.star, size: 14, color: i < (review['rating'] ?? 0) ? Colors.orange : Colors.grey[300]))),
            ],
          ),
          const SizedBox(height: 8),
          Text(review['comment'] ?? '', style: TextStyle(color: theme.textTheme.bodySmall?.color, fontSize: 13)),
        ],
      ),
    );
  }
}

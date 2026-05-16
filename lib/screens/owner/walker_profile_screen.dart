import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  final WalkerModel? walker; // Optional full model

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
    const primaryBlue = Color(0xFF2563EB);
    const textDark = Color(0xFF1E293B);
    const textLight = Color(0xFF64748B);
    const backgroundGray = Color(0xFFF8FAFC);

    return Scaffold(
      backgroundColor: backgroundGray,
      body: StreamBuilder<UserModel>(
        stream: _userId != null ? _firestoreService.getUserStream(_userId) : const Stream.empty(),
        builder: (context, userSnapshot) {
          final isFavorite = userSnapshot.data?.favoriteWalkers.contains(widget.id) ?? false;

          return CustomScrollView(
            slivers: [
              // Custom App Bar with Profile Image/Initials
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
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name and Price Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.name,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: textDark,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Professional Dog Walker',
                                style: TextStyle(color: textLight, fontSize: 16),
                              ),
                            ],
                          ),
                          Text(
                            '\$ ${widget.price % 1 == 0 ? widget.price.toInt() : widget.price.toStringAsFixed(2)}/hr',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2563EB),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Stats Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatColumn('Rating', widget.rating.toStringAsFixed(2), Icons.star, Colors.orange),
                          _buildStatColumn('Walks', widget.walksCount.toString(), Icons.pets, primaryBlue),
                          _buildStatColumn('Experience', '${widget.walker?.experienceYears ?? 3} years', Icons.timer, Colors.green),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // Toggle Section (About vs Reviews)
                      Container(
                        height: 50,
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _showReviews = false),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: !_showReviews ? Colors.white : Colors.transparent,
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: !_showReviews 
                                      ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))]
                                      : [],
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    'About',
                                    style: TextStyle(
                                      color: !_showReviews ? primaryBlue : textLight,
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
                                    color: _showReviews ? Colors.white : Colors.transparent,
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: _showReviews 
                                      ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))]
                                      : [],
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    'Reviews',
                                    style: TextStyle(
                                      color: _showReviews ? primaryBlue : textLight,
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

                      // Dynamic Content Area
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: _showReviews ? _buildReviewsList() : _buildAboutSection(),
                      ),
                      
                      const SizedBox(height: 100), // Space for bottom button
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
          color: Colors.white,
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Book Now',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAboutSection() {
    const textDark = Color(0xFF1E293B);
    const textLight = Color(0xFF64748B);

    final String bio = widget.walker?.bio ?? 'I am a passionate dog lover with years of experience walking dogs of all sizes and temperaments. I ensure your furry friend gets the exercise and attention they need while you are away.';
    final List<String> services = widget.walker?.services ?? ['GPS Tracking', 'Photo Updates', 'Feeding', 'Fresh Water'];

    return Column(
      key: const ValueKey('about'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'About',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textDark),
        ),
        const SizedBox(height: 12),
        Text(
          bio,
          style: const TextStyle(color: textLight, fontSize: 15, height: 1.5),
        ),
        const SizedBox(height: 32),
        const Text(
          'Services Included',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textDark),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: services.map((s) => _buildServiceChip(s)).toList(),
        ),
      ],
    );
  }

  Widget _buildReviewsList() {
    const primaryBlue = Color(0xFF2563EB);
    
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _firestoreService.getReviewsByWalker(widget.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        final reviews = snapshot.data ?? [];

        return Column(
          key: const ValueKey('reviews'),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Reviews',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AllReviewsScreen(
                          walkerId: widget.id, 
                          walkerName: widget.name
                        ),
                      ),
                    );
                  },
                  child: const Text('See All', style: TextStyle(color: primaryBlue)),
                ),
              ],
            ),
            if (reviews.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text('No reviews yet.'),
              )
            else
              ...reviews.take(3).map((r) => _buildReviewItem(
                r['userName'] ?? 'User',
                r['comment'] ?? '',
                (r['rating'] ?? 0.0).toDouble(),
              )),
          ],
        );
      }
    );
  }

  Widget _buildStatColumn(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildServiceChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(color: Color(0xFF475569), fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildReviewItem(String name, String comment, double rating) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.orange, size: 16),
                  const SizedBox(width: 4),
                  Text(rating.toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            comment,
            style: const TextStyle(color: Color(0xFF64748B), fontSize: 14),
          ),
        ],
      ),
    );
  }
}

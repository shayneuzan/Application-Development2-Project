import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/walker_model.dart';
import '../models/pet_model.dart';
import '../models/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- Walker Operations ---
  Stream<List<WalkerModel>> getWalkers() {
    return _db.collection('walkers').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => WalkerModel.fromFirestore(doc)).toList());
  }

  Future<WalkerModel> getWalkerById(String id) async {
    var doc = await _db.collection('walkers').doc(id).get();
    return WalkerModel.fromFirestore(doc);
  }

  // --- Pet Operations ---
  Stream<List<PetModel>> getPetsByOwner(String ownerId) {
    return _db
        .collection('pets')
        .where('ownerId', isEqualTo: ownerId)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => PetModel.fromFirestore(doc)).toList());
  }

  Future<void> addPet(PetModel pet) {
    return _db.collection('pets').add(pet.toMap());
  }

  // --- User Operations ---
  Future<UserModel> getUserById(String id) async {
    var doc = await _db.collection('users').doc(id).get();
    return UserModel.fromFirestore(doc);
  }

  Future<void> createUser(UserModel user) {
    return _db.collection('users').doc(user.id).set(user.toMap());
  }

  Future<void> updateUser(String userId, Map<String, dynamic> data) {
    return _db.collection('users').doc(userId).update(data);
  }

  // --- Favorite Operations ---
  Future<void> toggleFavorite(String userId, String walkerId, bool isFavorite) {
    return _db.collection('users').doc(userId).update({
      'favoriteWalkers': isFavorite
          ? FieldValue.arrayUnion([walkerId])
          : FieldValue.arrayRemove([walkerId])
    });
  }

  Stream<UserModel> getUserStream(String userId) {
    return _db.collection('users').doc(userId).snapshots().map((doc) => UserModel.fromFirestore(doc));
  }

  // --- Booking Operations ---
  Future<void> createBooking(Map<String, dynamic> bookingData) {
    return _db.collection('bookings').add({
      ...bookingData,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<Map<String, dynamic>>> getBookingsByOwner(String ownerId) {
    return _db
        .collection('bookings')
        .where('ownerId', isEqualTo: ownerId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {'id': doc.id, ...doc.data()})
            .toList());
  }

  Future<void> updateBookingStatus(String bookingId, String status) {
    return _db.collection('bookings').doc(bookingId).update({'status': status});
  }

  // --- Review Operations ---
  Stream<List<Map<String, dynamic>>> getReviewsByWalker(String walkerId) {
    return _db
        .collection('reviews')
        .where('walkerId', isEqualTo: walkerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {'id': doc.id, ...doc.data()})
            .toList());
  }

  Future<void> addReview(Map<String, dynamic> reviewData) {
    return _db.collection('reviews').add({
      ...reviewData,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}

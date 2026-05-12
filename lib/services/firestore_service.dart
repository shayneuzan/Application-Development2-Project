import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/walker_model.dart';
import '../models/pet_model.dart';
import '../models/user_model.dart';
import '../models/booking_model.dart';


class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- Walker Operations ---
  Stream<List<WalkerModel>> getWalkers() {
    return _db.collection('users').where('role', isEqualTo: 'walker').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => WalkerModel.fromFirestore(doc)).toList());
  }

  Future<WalkerModel> getWalkerById(String id) async {
    final doc = await _db.collection('users').doc(id).get();
    if (!doc.exists || doc['role'] != 'walker') {
      throw Exception('Pet Walker not found or this user is not a Pet Walker.');
    }
    return WalkerModel.fromFirestore(doc);
  }

  Future<UserModel> getOwnerById(String id) async {
    final doc = await _db.collection('users').doc(id).get();
    if (!doc.exists || doc['role'] != 'owner') {
      throw Exception('Pet Owner not found or this user is not a Pet Owner.');
    }
    return UserModel.fromFirestore(doc);
  }

  // --- Booking Operations ---
  Stream<List<BookingModel>> getBookingsByWalkerID(String walkerID) {
    return _db.collection('bookings').where('walkerId', isEqualTo: walkerID).snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => BookingModel.fromFirestore(doc)).toList()
    );
  }

  Stream<List<BookingModel>> getThreePendingRequestsByWalkerID(String walkerID, DateTime presentDay) {
    return getBookingsByWalkerID(walkerID).map((bookings) => bookings
        .where((request) => request.status == 'pending' && !request.date.isBefore(presentDay))
        .take(3)
        .toList()
    );
  }

  Stream<List<BookingModel>> getUpcomingRequestsByWalkerID(String walkerID, DateTime presentDay) {
    return getBookingsByWalkerID(walkerID).map((bookings) => bookings
        .where((request) => request.status == 'accepted' && !request.date.isBefore(presentDay))
        .toList()
    );
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

  Future<void> updatePet(String petId, Map<String, dynamic> data) {
    return _db.collection('pets').doc(petId).update(data);
  }

  Future<void> deletePet(String petId) {
    return _db.collection('pets').doc(petId).delete();
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

  // --- Notification Operations ---
  // Helper method to send notifications to Firestore
  Future<void> sendNotification({required String receiverID, required String title, required String message, required String type,}) async {
    await FirebaseFirestore.instance.collection('notifications').add({
      'receiverID': receiverID,
      'title': title,
      'message': message,
      'type': type,
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': false,
    });
  }
}

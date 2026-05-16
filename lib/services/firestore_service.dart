import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../models/walker_model.dart';
import '../models/pet_model.dart';
import '../models/user_model.dart';
import '../models/booking_model.dart';
import '../models/notification_model.dart';

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

  // --- Pet Operations ---
  Stream<List<PetModel>> getPetsByOwner(String ownerId) {
    return _db
        .collection('pets')
        .where('ownerId', isEqualTo: ownerId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => PetModel.fromFirestore(doc)).toList());
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
    return _db.collection('requests').add({
      ...bookingData,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<Map<String, dynamic>>> getBookingsByOwner(String ownerId) {
    return _db
        .collection('requests')
        .where('ownerId', isEqualTo: ownerId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {'id': doc.id, ...doc.data()})
            .where((doc) => doc['status'] != 'cancelled')
            .toList());
  }

  Future<void> updateBookingStatus(String bookingId, String status) {
    return _db.collection('requests').doc(bookingId).update({'status': status});
  }

  Future<void> rescheduleBooking(String bookingId, String date, String time, int duration) {
    return _db.collection('requests').doc(bookingId).update({
      'date': date,
      'time': time,
      'duration': duration,
      'status': 'pending',
    });
  }

  Future<void> markBookingAsReviewed(String bookingId) {
    return _db.collection('requests').doc(bookingId).update({'isReviewed': true});
  }

  Stream<List<BookingModel>> getAllBookingsByWalkerID(String walkerID) {
    return _db.collection('requests')
        .where('walkerID', isEqualTo: walkerID)
        .where('status', isEqualTo: 'pending')
        .snapshots().map((snapshot) => snapshot.docs
        .map((doc) => BookingModel.fromFirestore(doc)).toList());
  }

  // Home screen - 3 pending from today
  Stream<List<BookingModel>> getThreePendingRequestsByWalkerID(String walkerID, DateTime presentDay) {
    return _db
        .collection('requests')
        .where('walkerID', isEqualTo: walkerID)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => BookingModel.fromFirestore(doc))
        .where((b) => !b.date.isBefore(presentDay))
        .take(3)
        .toList());
  }

  // Home screen - accepted from today
  Stream<List<BookingModel>> getUpcomingWalksByWalkerID(String walkerID, DateTime presentDay) {
    return _db
        .collection('requests')
        .where('walkerID', isEqualTo: walkerID)
        .where('status', isEqualTo: 'accepted')
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => BookingModel.fromFirestore(doc))
        .where((b) => !b.date.isBefore(presentDay))
        .toList());
  }

  Stream<List<BookingModel>> getUpcomingWalksByDay(String walkerID, DateTime selectedDay) {
    return _db
        .collection('requests')
        .where('walkerID', isEqualTo: walkerID)
        .where('status', isEqualTo: 'accepted')
        .where('date', isEqualTo: DateFormat('yyyy-MM-dd').format(selectedDay))
        .snapshots()
        .map((snapshot) => snapshot.docs)
        .map((docs) => docs.map((doc) => BookingModel.fromFirestore(doc)).toList());
  }

  // --- Review Operations ---
  Stream<List<Map<String, dynamic>>> getReviewsByWalker(String walkerId) {
    return _db
        .collection('reviews')
        .where('walkerID', isEqualTo: walkerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {'id': doc.id, ...doc.data()})
            .toList());
  }

  Future<void> deleteUser(String userId) {
    return _db.collection('users').doc(userId).delete();
  }
  Future<void> addReview(Map<String, dynamic> reviewData) {
    return _db.collection('reviews').add({
      ...reviewData,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // --- Notification Operations ---
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

  Stream<List<NotificationModel>> getAllNotificationsByUserID(String uid) {
    return _db.collection('notifications')
        .where('receiverID', isEqualTo: uid)
        .orderBy('timestamp', descending: true)
        .snapshots().map((snapshot) => snapshot.docs
        .map((doc) => NotificationModel.fromFirestore(doc)).toList());
  }

  Future<void> markAllRead(String uid) async {
    final snapshot = await _db.collection('notifications')
        .where('receiverID', isEqualTo: uid)
        .where('isRead', isEqualTo: false)
        .get();

    if (snapshot.docs.isEmpty) return;
    final batch = _db.batch();
    for (final doc in snapshot.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }

  Future<List<NotificationModel>> getNotificationsByUserID(String uid) async {
    final snapshot = await _db.collection('notifications').where('receiverID', isEqualTo: uid).get();
    return snapshot.docs.map((d) => NotificationModel.fromFirestore(d)).toList();
  }

  Future<void> clearAll(String uid) async {
    final snapshot = await _db
        .collection('notifications')
        .where('receiverID', isEqualTo: uid)
        .get();

    if (snapshot.docs.isEmpty) return;

    final batch = _db.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  Future<void> checkAndResetEarnings(Map<String, dynamic> data, String uid) async {
    DateTime now = DateTime.now();
    DateTime lastDaily = (data['lastResetDaily'] as Timestamp?)?.toDate() ?? now;
    DateTime lastWeekly = (data['lastResetWeekly'] as Timestamp?)?.toDate() ?? now;
    DateTime lastMonthly = (data['lastResetMonthly'] as Timestamp?)?.toDate() ?? now;

    Map<String, dynamic> updates = {};

    if (now.day != lastDaily.day || now.month != lastDaily.month || now.year != lastDaily.year) {
      updates['todayEarnings'] = 0.0;
      updates['lastResetDaily'] = FieldValue.serverTimestamp();
    }

    if (now.weekday == DateTime.monday && now.day != lastWeekly.day) {
      updates['weeklyEarnings'] = 0.0;
      updates['lastResetWeekly'] = FieldValue.serverTimestamp();
    }

    if (now.month != lastMonthly.month || now.year != lastMonthly.year) {
      updates['monthEarnings'] = 0.0;
      updates['lastResetMonthly'] = FieldValue.serverTimestamp();
    }

    if (updates.isNotEmpty) {
      await FirebaseFirestore.instance.collection('users').doc(uid).update(updates);
    }
  }

  Future<void> markAsRead(String notificationId) async {
    await _db.collection('notifications').doc(notificationId).update({'isRead': true});
  }

  Future<void> deleteNotification(String notificationId) async {
    await _db.collection('notifications').doc(notificationId).delete();
  }

  // --- Earnings & Refund Operations ---
  Future<void> addEarnings(String walkerId, double amount) async {
    await _db.collection('users').doc(walkerId).update({
      'todayEarnings': FieldValue.increment(amount),
      'weeklyEarnings': FieldValue.increment(amount),
      'monthEarnings': FieldValue.increment(amount),
    });
  }

  Future<void> refundEarnings(String walkerId, double amount) async {
    await _db.collection('users').doc(walkerId).update({
      'todayEarnings': FieldValue.increment(-amount),
      'weeklyEarnings': FieldValue.increment(-amount),
      'monthEarnings': FieldValue.increment(-amount),
    });
  }

  Future<void> addEarningsRecord(String walkerID, String petName, int duration, double amount) async {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final dayOfWeek = days[DateTime.now().weekday - 1];

    await _db
        .collection('users')
        .doc(walkerID)
        .collection('earnings')
        .add({
      'amount': amount,
      'date': FieldValue.serverTimestamp(),
      'dayOfWeek': dayOfWeek,
      'walkTitle': '$petName - $duration min walk',
    });
  }

  // --- Reset Fields Operations ---
  // this is for existing Walker users who have not reset their fields,
  Future<void> initResetFields(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    final data = doc.data() as Map<String, dynamic>;

    Map<String, dynamic> updates = {};

    if (data['lastResetDaily'] == null)   updates['lastResetDaily']   = FieldValue.serverTimestamp();
    if (data['lastResetWeekly'] == null)  updates['lastResetWeekly']  = FieldValue.serverTimestamp();
    if (data['lastResetMonthly'] == null) updates['lastResetMonthly'] = FieldValue.serverTimestamp();

    // Also initialize earnings fields if missing
    if (data['todayEarnings'] == null)    updates['todayEarnings']    = 0.0;
    if (data['weeklyEarnings'] == null)   updates['weeklyEarnings']   = 0.0;
    if (data['monthEarnings'] == null)    updates['monthEarnings']    = 0.0;
    if (data['walksCount'] == null)       updates['walksCount']       = 0;

    if (updates.isNotEmpty) {
      await _db.collection('users').doc(uid).update(updates);
    }
  }
}

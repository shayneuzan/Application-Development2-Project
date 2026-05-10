import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Stream of chat rooms the current user is part of
  Stream<QuerySnapshot> getChatRoomsStream({String? status}) {
    final String currentUserID = _auth.currentUser!.uid;
    Query query = _firestore
        .collection('chat_rooms')
        .where('participants', arrayContains: currentUserID);

    if (status != null) {
      query = query.where('status', isEqualTo: status);
    }

    return query.orderBy('timestamp', descending: true).snapshots();
  }

  // Create or re-open a chat room
  Future<void> createChatRoom(String receiverID, String receiverName, String petName) async {
    final String currentUserID = _auth.currentUser!.uid;

    // Fetch current user details for metadata and role-based messaging
    DocumentSnapshot currentUserDoc = await _firestore.collection('users').doc(currentUserID).get();
    Map<String, dynamic> userData = currentUserDoc.data() as Map<String, dynamic>;
    String currentUserName = userData['name'] ?? 'User';
    String role = userData['role'] ?? 'walker';

    List<String> ids = [currentUserID, receiverID];
    ids.sort();
    String chatRoomID = ids.join('_');

    DocumentReference chatRoomRef = _firestore.collection("chat_rooms").doc(chatRoomID);
    DocumentSnapshot chatRoomSnapshot = await chatRoomRef.get();

    // Determine if we should send the automated welcome (new chat or previously closed)
    bool isNewOrReopened = !chatRoomSnapshot.exists || (chatRoomSnapshot.data() as Map<String, dynamic>?)?['status'] == 'closed';

    // Set or Update chat room status to active
    await chatRoomRef.set({
      'participants': ids,
      'lastMessage': 'Chat started for $petName',
      'timestamp': FieldValue.serverTimestamp(),
      'status': 'active',
      'users': {
        currentUserID: {'name': currentUserName, 'role': role},
        receiverID: {'name': receiverName},
      },
      'petName': petName,
    }, SetOptions(merge: true));

    // Send the initial preset message only if it's a fresh/reopened session
    if (isNewOrReopened) {
      String welcomeMsg = role == 'walker'
        ? "👋 $currentUserName has accepted the walk request for $petName. You can now coordinate details here!\n\nIf the walk is finished, type 'the deed is done' or 'completed'. If the walk is cancelled, type 'unable to do the walk' or 'cancel'."
        : "👋 $currentUserName has started a chat regarding $petName's walk.\n\nIf the walk is finished, type 'the deed is done' or 'completed'. If the walk is cancelled, type 'unable to do the walk' or 'cancel'.";

      await sendMessage(receiverID, welcomeMsg);
    }
  }

  // Method to close a chat room with a specific reason (completion vs cancellation)
  Future<void> closeChatRoom(String otherUserID, String closingMessage) async {
    final String currentUserID = _auth.currentUser!.uid;
    List<String> ids = [currentUserID, otherUserID];
    ids.sort();
    String chatRoomID = ids.join('_');

    await _firestore.collection("chat_rooms").doc(chatRoomID).update({
      'status': 'closed',
      'lastMessage': closingMessage,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // Send a message (checks if chat is active)
  Future<void> sendMessage(String receiverID, String message) async {
    final String currentUserID = _auth.currentUser!.uid;
    final Timestamp timestamp = Timestamp.now();

    List<String> ids = [currentUserID, receiverID];
    ids.sort();
    String chatRoomID = ids.join('_');

    // Check if chat is still active before sending
    DocumentSnapshot chatDoc = await _firestore.collection("chat_rooms").doc(chatRoomID).get();
    if (chatDoc.exists && (chatDoc.data() as Map<String, dynamic>?)?['status'] == 'closed') {
      return;
    }

    Message newMessage = Message(
      senderID: currentUserID,
      receiverID: receiverID,
      message: message,
      timestamp: timestamp,
    );

    await _firestore
        .collection("chat_rooms")
        .doc(chatRoomID)
        .collection("messages")
        .add(newMessage.toMap());

    await _firestore.collection("chat_rooms").doc(chatRoomID).update({
      'lastMessage': message,
      'timestamp': timestamp,
    });
  }

  // Get messages for a specific chat
  Stream<QuerySnapshot> getMessages(String userID, String otherUserID) {
    List<String> ids = [userID, otherUserID];
    ids.sort();
    String chatRoomID = ids.join('_');
    return _firestore
        .collection('chat_rooms')
        .doc(chatRoomID)
        .collection('messages')
        .orderBy("timestamp", descending: false)
        .snapshots();
  }

  String getChatRoomID(String user1, String user2) {  List<String> ids = [user1, user2];
    ids.sort();
    return ids.join('_');
  }
}

class Message {
  final String senderID;
  final String receiverID;
  final String message;
  final Timestamp timestamp;

  Message({
    required this.senderID,
    required this.receiverID,
    required this.message,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'senderID': senderID,
      'receiverID': receiverID,
      'message': message,
      'timestamp': timestamp
    };
  }
}

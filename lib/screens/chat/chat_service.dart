import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Stream of chat rooms the current user is part of
  Stream<QuerySnapshot> getChatRoomsStream({String? status}) {
    final String currentUserID = _auth.currentUser!.uid;
    // Get all chat rooms where the current user is a participant
    Query query = _firestore.collection('chat_rooms').where('participants', arrayContains: currentUserID);

    // Filter by status if provided
    if (status != null) {
      query = query.where('status', isEqualTo: status);
    }

    // Order by timestamp
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

    String sessionID = DateTime.now().millisecondsSinceEpoch.toString();
    String chatRoomID = "${ids.join('_')}_$sessionID";

    DocumentReference chatRoomRef = _firestore.collection("chat_rooms").doc(chatRoomID);

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

    // Send the initial preset message
    String welcomeMsg = role == 'walker'
      ? "👋 $currentUserName has accepted the walk request for $petName. You can now coordinate details here!"
      : "👋 $currentUserName has started a chat regarding $petName's walk.";

    await sendMessage(chatRoomID, receiverID, welcomeMsg);
  }

  // Method to close a chat room with a specific reason (completion vs cancellation)
  Future<void> closeChatRoom(String chatRoomID, String closingMessage) async {
    await _firestore.collection("chat_rooms").doc(chatRoomID).update({
      'status': 'closed',
      'lastMessage': closingMessage,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // Send a message (checks if chat is active)
  Future<void> sendMessage(String chatRoomID, String receiverID, String message) async {
    final String currentUserID = _auth.currentUser!.uid;
    final Timestamp timestamp = Timestamp.now();

    DocumentSnapshot chatDoc = await _firestore
        .collection("chat_rooms")
        .doc(chatRoomID)
        .get();

    if (chatDoc.exists &&
        (chatDoc.data() as Map<String, dynamic>?)?['status'] == 'closed') {
      return;
    }

    // Create a new message
    Message newMessage = Message(
      senderID: currentUserID,
      receiverID: receiverID,
      message: message,
      timestamp: timestamp,
    );

    // Add the message to the chat room
    await _firestore
        .collection("chat_rooms")
        .doc(chatRoomID)
        .collection("messages")
        .add(newMessage.toMap());

    // Update the last message in the chat room
    await _firestore
        .collection("chat_rooms")
        .doc(chatRoomID)
        .update({
      'lastMessage': message,
      'timestamp': timestamp,
    });
  }

  // Get messages for a specific chat
  Stream<QuerySnapshot> getMessages(String chatRoomID) {
    return _firestore
        .collection('chat_rooms')
        .doc(chatRoomID)
        .collection('messages')
        .orderBy("timestamp", descending: false)
        .snapshots();
  }
}

// Message Model
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

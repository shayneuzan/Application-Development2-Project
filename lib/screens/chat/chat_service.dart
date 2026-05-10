import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Stream of chat rooms the current user is part of AND are active
  Stream<QuerySnapshot> getChatRoomsStream() {
    final String currentUserID = _auth.currentUser!.uid;
    return _firestore
        .collection('chat_rooms')
        .where('participants', arrayContains: currentUserID)
        .where('status', isEqualTo: 'active') // Only show active chats
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // Create or re-open a chat room
  Future<void> createChatRoom(String receiverID, String receiverName, String petName) async {
    final String currentUserID = _auth.currentUser!.uid;
    
    DocumentSnapshot currentUserDoc = await _firestore.collection('users').doc(currentUserID).get();
    String currentUserName = (currentUserDoc.data() as Map<String, dynamic>?)?['name'] ?? 'User';

    List<String> ids = [currentUserID, receiverID];
    ids.sort();
    String chatRoomID = ids.join('_');

    DocumentReference chatRoomRef = _firestore.collection("chat_rooms").doc(chatRoomID);
    
    // Always set status to active when a request is accepted (re-opening if closed)
    await chatRoomRef.set({
      'participants': ids,
      'lastMessage': 'Chat started for $petName',
      'timestamp': FieldValue.serverTimestamp(),
      'status': 'active', // Chat is now active
      'users': {
        currentUserID: {'name': currentUserName}, 
        receiverID: {'name': receiverName},
      },
      'petName': petName,
    }, SetOptions(merge: true));

    // Send the initial preset message automatically
    await sendMessage(receiverID, "👋 This chat group has been formed for $petName's walk request. You can now coordinate details here!");
  }

  // Method to close a chat room when walk is finished or cancelled
  Future<void> closeChatRoom(String otherUserID) async {
    final String currentUserID = _auth.currentUser!.uid;
    List<String> ids = [currentUserID, otherUserID];
    ids.sort();
    String chatRoomID = ids.join('_');

    await _firestore.collection("chat_rooms").doc(chatRoomID).update({
      'status': 'closed',
      'lastMessage': 'Walk ended. Chat closed.',
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
      // Chat is closed, prevent sending
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

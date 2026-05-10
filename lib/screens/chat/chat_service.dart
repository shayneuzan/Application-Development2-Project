import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Stream of chat rooms the current user is part of
  Stream<QuerySnapshot> getChatRoomsStream() {
    final String currentUserID = _auth.currentUser!.uid;
    return _firestore
        .collection('chat_rooms')
        .where('participants', arrayContains: currentUserID)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // Create or initialize a chat room
  Future<void> createChatRoom(String receiverID, String receiverName, String petName) async {
    final String currentUserID = _auth.currentUser!.uid;
    
    // Fetch current user's name for the metadata
    DocumentSnapshot currentUserDoc = await _firestore.collection('users').doc(currentUserID).get();
    String currentUserName = (currentUserDoc.data() as Map<String, dynamic>?)?['name'] ?? 'User';

    List<String> ids = [currentUserID, receiverID];
    ids.sort();
    String chatRoomID = ids.join('_');

    DocumentReference chatRoomRef = _firestore.collection("chat_rooms").doc(chatRoomID);
    DocumentSnapshot chatRoomSnapshot = await chatRoomRef.get();

    // If chat room doesn't exist, create it and send initial preset message
    if (!chatRoomSnapshot.exists) {
      await chatRoomRef.set({
        'participants': ids,
        'lastMessage': 'Chat started for $petName',
        'timestamp': FieldValue.serverTimestamp(),
        'users': {
          currentUserID: {'name': currentUserName}, 
          receiverID: {'name': receiverName},
        },
        'petName': petName,
      });

      // Send the initial preset message automatically
      await sendMessage(receiverID, "👋 This chat group has been formed for $petName's walk request. You can now coordinate details here!");
    }
  }

  // Send a message
  Future<void> sendMessage(String receiverID, String message) async {
    final String currentUserID = _auth.currentUser!.uid;
    final Timestamp timestamp = Timestamp.now();

    Message newMessage = Message(
      senderID: currentUserID,
      receiverID: receiverID,
      message: message,
      timestamp: timestamp,
    );

    List<String> ids = [currentUserID, receiverID];
    ids.sort();
    String chatRoomID = ids.join('_');

    // Add message to sub-collection
    await _firestore
        .collection("chat_rooms")
        .doc(chatRoomID)
        .collection("messages")
        .add(newMessage.toMap());

    // Update main chat room document with last message info
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

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'chat_service.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatelessWidget {
  ChatListScreen({super.key});

  final ChatService _chatService = ChatService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Chats'),
        backgroundColor: Colors.blueAccent,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _chatService.getChatRoomsStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("Error loading chats"));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No active chats yet."));
          }

          return ListView(
            children: snapshot.data!.docs.map<Widget>((doc) => _buildChatListItem(context, doc)).toList(),
          );
        },
      ),
    );
  }

  Widget _buildChatListItem(BuildContext context, DocumentSnapshot document) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;
    final String currentUserID = _auth.currentUser!.uid;

    // Get the other participant's ID
    List<dynamic> participants = data['participants'];
    String otherUserID = participants.firstWhere((id) => id != currentUserID);

    // Get metadata stored during createChatRoom
    Map<String, dynamic> users = data['users'] ?? {};
    String otherUserName = users[otherUserID]?['name'] ?? "Unknown User";
    String petName = data['petName'] ?? "";
    String lastMessage = data['lastMessage'] ?? "";

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.blue.shade100,
        child: Text(otherUserName.isNotEmpty ? otherUserName[0].toUpperCase() : "?"),
      ),
      title: Text(otherUserName),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (petName.isNotEmpty)
            Text("Pet: $petName", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          Text(lastMessage, maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              receiverID: otherUserID,
              receiverName: otherUserName,
            ),
          ),
        );
      },
    );
  }
}

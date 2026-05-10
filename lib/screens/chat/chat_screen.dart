import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'chat_service.dart';

class ChatScreen extends StatefulWidget {
  final String receiverID;
  final String receiverName;

  const ChatScreen({super.key, required this.receiverID, required this.receiverName});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ScrollController _scrollController = ScrollController();

  void sendMessage() async {
    if (_messageController.text.trim().isNotEmpty) {
      await _chatService.sendMessage(widget.receiverID, _messageController.text.trim());
      _messageController.clear();
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF2563EB);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: primaryBlue,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.white24,
              child: Text(widget.receiverName[0], style: const TextStyle(color: Colors.white)),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.receiverName, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                const Text("Active Coordination", style: TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(child: _buildMessageList()),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    return StreamBuilder(
      stream: _chatService.getMessages(_auth.currentUser!.uid, widget.receiverID),
      builder: (context, snapshot) {
        if (snapshot.hasError) return const Center(child: Text("Error loading messages"));
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            return _buildMessageItem(snapshot.data!.docs[index]);
          },
        );
      },
    );
  }

  Widget _buildMessageItem(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    bool isCurrentUser = data['senderID'] == _auth.currentUser!.uid;
    var timestamp = data['timestamp'] as Timestamp?;
    String timeString = timestamp != null ? DateFormat('hh:mm a').format(timestamp.toDate()) : "";

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isCurrentUser ? const Color(0xFF2563EB) : Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(isCurrentUser ? 16 : 0),
                bottomRight: Radius.circular(isCurrentUser ? 0 : 16),
              ),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 2)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  data['message'],
                  style: TextStyle(color: isCurrentUser ? Colors.white : Colors.black87, fontSize: 15),
                ),
                const SizedBox(height: 4),
                Text(timeString, style: TextStyle(color: isCurrentUser ? Colors.white70 : Colors.black45, fontSize: 10)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: "Type a message...",
                  fillColor: const Color(0xFFF1F5F9),
                  filled: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: sendMessage,
              child: const CircleAvatar(
                backgroundColor: Color(0xFF2563EB),
                child: Icon(Icons.send, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

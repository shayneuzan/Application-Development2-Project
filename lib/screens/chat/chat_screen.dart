import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'chat_service.dart';

class ChatScreen extends StatefulWidget {
  final String receiverID;
  final String receiverName;
  final String chatRoomID;

  const ChatScreen({super.key, required this.chatRoomID, required this.receiverID, required this.receiverName,});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ScrollController _scrollController = ScrollController();

  // Helper method to send notifications to Firestore
  Future<void> _sendNotification({
    required String receiverID,
    required String title,
    required String message,
    required String type,
  }) async {
    await FirebaseFirestore.instance.collection('notifications').add({
      'receiverID': receiverID,
      'title': title,
      'message': message,
      'type': type,
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': false,
    });
  }

  void sendMessage() async {
    String messageText = _messageController.text.trim();

    if (messageText.isEmpty) return;

    await _chatService.sendMessage(
      widget.chatRoomID,
      widget.receiverID,
      messageText,
    );

    // Get current user name to show in notification
    final uid = _auth.currentUser!.uid;
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final name = userDoc.data()?['name'] ?? 'User';

    // Notify the receiver
    await _sendNotification(
      receiverID: widget.receiverID,
      title: "New Message from $name",
      message: messageText,
      type: 'chat',
    );

    _messageController.clear();
    _scrollToBottom();
  }

  void _showEndSessionConfirmation(String message, bool isCompletion) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(isCompletion ? "Complete Walk Session?" : "Emergency / Cancel Walk?"),
        content: Text(isCompletion
            ? "Are you sure you want to finish this session? This will finalize the walk and close the chat room."
            : "Are you reporting an emergency or cancelling the walk? This will end coordination immediately and close the chat."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("Go Back", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              final messenger = ScaffoldMessenger.of(context);
              // Close the Dialog
              navigator.pop();
              try {
                // Send the final trigger message (e.g., "The deed is done")
                await _chatService.sendMessage(widget.chatRoomID, widget.receiverID, message,);
                _messageController.clear();

                final uid = _auth.currentUser!.uid;
                final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
                final role = userDoc.data()?['role'] ?? 'user';
                final name = userDoc.data()?['name'] ?? 'User';

                String closingReason = isCompletion ? "Finished: Walk marked complete by $role ($name)" : "Ended: $role ($name) requested to cancel/stop coordination";

                // Notify the other user
                await _sendNotification(
                  receiverID: widget.receiverID,
                  title: isCompletion ? "Walk Completed!" : "Walk Ended Early",
                  message: closingReason,
                  type: isCompletion ? 'walk_completed' : 'walk_cancelled',
                );

                // Update status to 'closed' in Firestore
                await _chatService.closeChatRoom(widget.chatRoomID, closingReason,);

                if (!mounted) return;
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(isCompletion ? "Session Completed" : "Session Cancelled"),
                    backgroundColor: isCompletion ? Colors.green : Colors.red,
                  ),
                );
              } catch (e) {
                if (!mounted) return;
                messenger.showSnackBar(
                  SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isCompletion ? Colors.green : Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text("Confirm & End"),
          ),
        ],
      ),
    );
  }

  // Helper method to scroll to the bottom of the message list
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
              child: Text(widget.receiverName.isNotEmpty ? widget.receiverName[0] : "?", style: const TextStyle(color: Colors.white),),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.receiverName, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),),
                StreamBuilder<DocumentSnapshot>(
                // Now chatRoomID is defined and accessible
                  stream: FirebaseFirestore.instance
                      .collection('chat_rooms')
                      .doc(widget.chatRoomID)
                      .snapshots(),
                  builder: (context, snapshot) {
                    bool isClosed = snapshot.hasData && snapshot.data?.exists == true && snapshot.data?.get('status') == 'closed';
                    return Text(
                      isClosed ? "Session Closed" : "Active Coordination",
                      style: TextStyle(color: isClosed ? Colors.redAccent[100] : Colors.white70, fontSize: 12, fontWeight: isClosed ? FontWeight.bold : FontWeight.normal),
                    );
                  }),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(child: _buildMessageList()),
          _buildMessageInput(), // This also uses logic to check the same ID
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    return StreamBuilder(
      stream: _chatService.getMessages(widget.chatRoomID),
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
    // We need to listen to the chat room document to check its status
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('chat_rooms')
          .doc(widget.chatRoomID)
          .snapshots(),
      builder: (context, snapshot) {
        // Default to "not closed" while loading
        bool isClosed = false;
        bool isWalker = false;

        if (snapshot.hasData && snapshot.data!.exists) {
          var data = snapshot.data!.data() as Map<String, dynamic>;
          isClosed = data['status'] == 'closed';
          final currentUID = _auth.currentUser!.uid;
          Map<String, dynamic> users = data['users'] ?? {};
          String currentRole = users[currentUID]?['role'] ?? 'owner';
          isWalker = currentRole == 'walker';
        }

        // If closed, show a "Chat Ended" banner instead of the text field
        if (isClosed) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              border: Border(top: BorderSide(color: Colors.grey[300]!)),
            ),
            child: const Text(
              "This chat has ended. You can no longer send messages.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold),
            ),
          );
        }

        // OTHERWISE: Show the normal input field
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // The buttons to end the session
                Row(
                  children: [
                    // WALKER ONLY
                    if (isWalker)
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            _showEndSessionConfirmation(
                              "Walk completed successfully.",
                              true,
                            );
                          },
                          icon: const Icon(Icons.check_circle),
                          label: const Text("Complete Walk"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),

                    if (isWalker) const SizedBox(width: 10),
                    // EVERYONE CAN END EARLY
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          _showEndSessionConfirmation("Walk ended early.", false,);
                        },
                        icon: const Icon(Icons.warning_amber),
                        label: Text(isWalker ? "End Early" : "Cancel Walk"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // The message input field
                Row(
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
              ],
            ),
          ),
        );
      },
    );
  }
}

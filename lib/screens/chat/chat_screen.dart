import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../services/firestore_service.dart';
import 'chat_service.dart';

class ChatScreen extends StatefulWidget {
  final String receiverID;
  final String receiverName;
  final String chatRoomID;
  final double totalPrice;
  final String petName;
  final int duration;
  final String bookingId;

  const ChatScreen({
    super.key,
    required this.chatRoomID,
    required this.receiverID,
    required this.receiverName,
    required this.totalPrice,
    required this.petName,
    required this.duration,
    required this.bookingId,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ScrollController _scrollController = ScrollController();
  final FirestoreService _firestoreService = FirestoreService();

  void sendMessage() async {
    String messageText = _messageController.text.trim();

    if (messageText.isEmpty) return;

    await _chatService.sendMessage(
      widget.chatRoomID,
      widget.receiverID,
      messageText,
    );

    final uid = _auth.currentUser!.uid;
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final name = userDoc.data()?['name'] ?? 'User';

    _firestoreService.sendNotification(
      receiverID: widget.receiverID,
      title: "New Message from $name",
      message: messageText,
      type: 'chat',
    );

    _messageController.clear();
    _scrollToBottom();
  }

  void _showEndSessionConfirmation(String message, bool isCompletion) {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(isCompletion ? l10n.completeWalkSessionTitle : l10n.emergencyCancelWalkTitle),
        content: Text(isCompletion
            ? l10n.completeWalkSessionMessage
            : l10n.emergencyCancelWalkMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.goBack, style: const TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              final messenger = ScaffoldMessenger.of(context);
              navigator.pop();
              try {
                final chatRoomDoc = await FirebaseFirestore.instance.collection('chat_rooms').doc(widget.chatRoomID).get();
                final chatRoomData = chatRoomDoc.data() ?? {};
                final double totalPrice = (chatRoomData['totalPrice'] ?? 0.0).toDouble();
                final String walkerID = chatRoomData['walkerID'] ?? '';

                await _chatService.sendMessage(widget.chatRoomID, widget.receiverID, message,);
                _messageController.clear();

                final uid = _auth.currentUser!.uid;
                final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
                final role = userDoc.data()?['role'] ?? 'user';
                final name = userDoc.data()?['name'] ?? 'User';

                String closingReason = isCompletion 
                    ? l10n.closingReasonComplete(role, name) 
                    : l10n.closingReasonCancelled(role, name);

                _firestoreService.sendNotification(
                  receiverID: widget.receiverID,
                  title: isCompletion ? l10n.walkCompletedTitle : l10n.walkEndedEarlyTitle,
                  message: closingReason,
                  type: isCompletion ? 'walk_completed' : 'walk_cancelled',
                );

                await _chatService.closeChatRoom(widget.chatRoomID, closingReason,);

                if (isCompletion) {
                  await FirebaseFirestore.instance.collection('users').doc(walkerID).update({
                    'walksCount': FieldValue.increment(1),
                  });
                  await _firestoreService.addEarnings(uid, widget.totalPrice);
                  await _firestoreService.addEarningsRecord(uid, widget.petName, widget.duration, widget.totalPrice,);

                } else {
                  if (role == 'walker' && totalPrice > 0) {
                    await _firestoreService.refundEarnings(walkerID, totalPrice);

                    _firestoreService.sendNotification(
                      receiverID: widget.receiverID,
                      title: l10n.refundProcessed,
                      message: l10n.refundNotification(l10n.priceAmount(totalPrice.toStringAsFixed(2))),
                      type: 'refund_issued',
                    );
                  }
                }

                if (!mounted) return;
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(isCompletion ? l10n.sessionCompleted : (role == 'walker' ? l10n.sessionEndedRefunded : l10n.sessionCancelled)),
                    backgroundColor: isCompletion ? Colors.green : Colors.red,
                  ),
                );
              } catch (e) {
                if (!mounted) return;
                messenger.showSnackBar(
                  SnackBar(content: Text("${l10n.error}: $e"), backgroundColor: Colors.red),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isCompletion ? Colors.green : Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.confirmAndEnd),
          ),
        ],
      ),
    );
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
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    const primaryBlue = Color(0xFF2563EB);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: primaryBlue,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.white24,
              child: Text(
                widget.receiverName.isNotEmpty ? widget.receiverName[0] : "?",
                style: const TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.receiverName,
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('chat_rooms')
                      .doc(widget.chatRoomID)
                      .snapshots(),
                  builder: (context, snapshot) {
                    bool isClosed = snapshot.hasData && snapshot.data?.exists == true && snapshot.data?.get('status') == 'closed';
                    return Text(
                      isClosed ? l10n.sessionClosed : l10n.activeCoordination,
                      style: TextStyle(
                        color: isClosed ? Colors.redAccent[100] : Colors.white70,
                        fontSize: 12,
                        fontWeight: isClosed ? FontWeight.bold : FontWeight.normal,
                      ),
                    );
                  }
                ),
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
    final l10n = AppLocalizations.of(context)!;
    return StreamBuilder(
      stream: _chatService.getMessages(widget.chatRoomID),
      builder: (context, snapshot) {
        if (snapshot.hasError) return Center(child: Text(l10n.errorLoadingMessages));
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

    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isCurrentUser ? const Color(0xFF2563EB) : (isDarkMode ? const Color(0xFF334155) : Colors.white),
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
                  style: TextStyle(color: isCurrentUser ? Colors.white : theme.textTheme.bodyLarge?.color, fontSize: 15),
                ),
                const SizedBox(height: 4),
                Text(timeString, style: TextStyle(color: isCurrentUser ? Colors.white70 : theme.textTheme.bodySmall?.color, fontSize: 10)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('chat_rooms')
          .doc(widget.chatRoomID)
          .snapshots(),
      builder: (context, snapshot) {
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

        if (isClosed) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.black26 : Colors.grey[200],
              border: Border(top: BorderSide(color: isDarkMode ? Colors.white10 : Colors.grey[300]!)),
            ),
            child: Text(
              l10n.chatEnded,
              textAlign: TextAlign.center,
              style: TextStyle(color: isDarkMode ? Colors.white60 : Colors.grey[200], fontSize: 16, fontWeight: FontWeight.bold),
            ),
          );
        }

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.cardColor,
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))
            ],
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    if (isWalker)
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            _showEndSessionConfirmation(l10n.walkCompletedSuccessfully, true);
                          },
                          icon: const Icon(Icons.check_circle),
                          label: Text(l10n.completeWalk),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    if (isWalker) const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          _showEndSessionConfirmation(l10n.walkEndedEarly, false);
                        },
                        icon: const Icon(Icons.warning_amber),
                        label: Text(isWalker ? l10n.endEarly : l10n.cancelWalk),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: l10n.typeAMessage,
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

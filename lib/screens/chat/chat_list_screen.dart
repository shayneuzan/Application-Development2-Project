import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../l10n/generated/app_localizations.dart';
import '../walker/walker_home_screen.dart';
import '../owner/owner_home_screen.dart';
import 'chat_service.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatelessWidget {
  ChatListScreen({super.key});

  final ChatService _chatService = ChatService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void _goHome(BuildContext context) async {
    final String? uid = _auth.currentUser?.uid;
    if (uid == null) return;

    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (doc.exists && context.mounted) {
        String role = doc.data()?['role'] ?? 'owner';
        Widget homeScreen = (role == 'walker') ? const WalkerHomeScreen() : const OwnerHomeScreen();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => homeScreen),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop(); 
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.myChats, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          backgroundColor: const Color(0xFF2563EB),
          iconTheme: const IconThemeData(color: Colors.white),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              if (Navigator.canPop(context)) {
                Navigator.of(context).pop();
              } else {
                _goHome(context);
              }
            },
          ),
          bottom: TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: l10n.active),
              Tab(text: l10n.past),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildChatList(status: 'active', l10n: l10n),
            _buildChatList(status: 'closed', l10n: l10n),
          ],
        ),
      ),
    );
  }

  // Helper method to build a chat list
  Widget _buildChatList({String? status, required AppLocalizations l10n}) {
    return StreamBuilder<QuerySnapshot>(
      stream: _chatService.getChatRoomsStream(status: status),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text(l10n.errorLoadingChats));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text(
              status == 'active' ? l10n.noActiveChats : l10n.noPastChats,
              style: const TextStyle(color: Colors.grey),
            ),
          );
        }

        return ListView(
          children: snapshot.data!.docs.map<Widget>((doc) => _buildChatListItem(context, doc, l10n)).toList(),
        );
      },
    );
  }

  // Helper method to build a chat list item
  Widget _buildChatListItem(BuildContext context, DocumentSnapshot document, AppLocalizations l10n) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;
    final String currentUserID = _auth.currentUser!.uid;
    String chatRoomID = document.id;

    List<dynamic> participants = data['participants'] ?? [];
    if (participants.isEmpty) return const SizedBox.shrink();

    String otherUserID = participants.firstWhere((id) => id != currentUserID, orElse: () => "");

    Map<String, dynamic> users = data['users'] ?? {};
    String otherUserName = users[otherUserID]?['name'] ?? l10n.unknownUser;
    String petName = data['petName'] ?? "";
    String lastMessage = data['lastMessage'] ?? "";
    String status = data['status'] ?? 'active';
    
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: status == 'active' ? Colors.blue.shade100 : (isDarkMode ? Colors.white10 : Colors.grey.shade200),
        child: Text(otherUserName.isNotEmpty ? otherUserName[0].toUpperCase() : "?", style: TextStyle(color: status == 'active' ? Colors.blue : Colors.grey),),
      ),
      title: Text(otherUserName, style: TextStyle(fontWeight: FontWeight.bold, color: status == 'active' ? (isDarkMode ? Colors.white : Colors.black) : Colors.grey,)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (petName.isNotEmpty) Text(l10n.petLabel(petName), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: status == 'active' ? Colors.blueAccent : Colors.grey)),
          Text(lastMessage, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: status == 'active' ? (isDarkMode ? Colors.white70 : Colors.black87) : Colors.grey),),
        ],
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              chatRoomID: chatRoomID,
              receiverID: otherUserID,
              receiverName: otherUserName,
              totalPrice: (data['totalPrice'] ?? 0.0).toDouble(),
              petName: petName,
              duration: data['duration'] ?? 0,
              bookingId: data['bookingId'] ?? '',
            ),
          ),
        );
      },
    );
  }
}

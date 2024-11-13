import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:travel_app/Views/MessageBubble.dart';

class MessageList extends StatelessWidget {
  final String chatId;

  MessageList(this.chatId);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text(""));
        }

        final messages = snapshot.data!.docs;

        return ListView.builder(
          reverse: true, // Mostra i messaggi più recenti in cima
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final message = messages[index].data() as Map<String, dynamic>;
            return MessageBubble(
              text: message['text'] ?? '',
              senderUsername: message['senderUsername'] ?? 'Anonimo',
              isMe:
                  message['senderId'] == FirebaseAuth.instance.currentUser?.uid,
              timestamp: (message['timestamp'] as Timestamp?)?.toDate(),
            );
          },
        );
      },
    );
  }
}

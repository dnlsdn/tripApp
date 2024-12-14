import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // Importa la libreria intl

import 'package:travel_app/Controllers/UserProvider.dart';
import 'package:travel_app/models/Utente.dart';
import 'package:travel_app/Views/Contact.dart';

class Chat extends StatefulWidget {
  final String chatId;
  final Map<String, dynamic> profile; // l'altro utente

  const Chat({
    Key? key,
    required this.chatId,
    required this.profile,
  }) : super(key: key);

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  /// Set per tenere traccia dei messaggi cliccati
  final Set<String> _expandedMessages = {};

  Future<void> _sendMessage() async {
    try {
      if (_messageController.text.trim().isEmpty) return;
      final currentUser =
          Provider.of<UserProvider>(context, listen: false).getUser;
      if (currentUser == null) return;

      final text = _messageController.text.trim();
      _messageController.clear();

      final now = FieldValue.serverTimestamp();
      final chatDocRef =
          FirebaseFirestore.instance.collection('chats').doc(widget.chatId);

      print(
          'DEBUG: Sending message to chatId = ${widget.chatId}, text = $text');

      // Aggiungo messaggio in subcollection "messages"
      await chatDocRef.collection('messages').add({
        'text': text,
        'senderId': currentUser.uid,
        'receiverId': widget.profile['uid'],
        'timestamp': now,
        'read': false, // se vuoi gestire read/unread
      });

      // Aggiorno i metadati nel doc principale "chats/chatId"
      await chatDocRef.update({
        'lastMessage': text,
        'lastMessageTimestamp': now,
        'unreadMap.${currentUser.uid}': 0, // chi invia azzera
        'unreadMap.${widget.profile['uid']}':
            FieldValue.increment(1), // destinatario incrementa
      });

      print(
          'DEBUG: Chat metadata updated successfully. ChatId=${widget.chatId}');
    } catch (e) {
      print('ERROR in _sendMessage: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).getUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.profile['username'] ?? 'Chat'),
        actions: [
          if (widget.profile['photoUrl'] != null &&
              widget.profile['photoUrl'].isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Contact(profile: widget.profile),
                    ),
                  );
                },
                child: CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage(widget.profile['photoUrl']),
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 18,
            ),
            // Lista messaggi
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('chats')
                    .doc(widget.chatId)
                    .collection('messages')
                    .orderBy('timestamp', descending: false)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final docs = snapshot.data!.docs;
                  if (docs.isEmpty) {
                    return const Center(child: Text('Nessun messaggio...'));
                  }
                  return ListView.builder(
                    controller: _scrollController,
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final doc = docs[index];
                      final data = doc.data() as Map<String, dynamic>;
                      final isMe = (data['senderId'] == user?.uid);

                      return _buildMessageBubble(doc.id, data, isMe);
                    },
                  );
                },
              ),
            ),

            // TextField per inviare messaggio
            _buildMessageInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(
      String messageId, Map<String, dynamic> data, bool isMe) {
    final text = data['text'] ?? '';
    final alignment = isMe ? Alignment.centerRight : Alignment.centerLeft;
    final bubbleColor = isMe ? Colors.blue : Colors.grey[700];
    final radius = isMe
        ? const BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
            bottomLeft: Radius.circular(12),
          )
        : const BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
            bottomRight: Radius.circular(12),
          );

    // Controlla se il messaggio è espanso
    final isExpanded = _expandedMessages.contains(messageId);

    // Converte il timestamp in un formato leggibile
    String formattedDate = '';
    if (data['timestamp'] != null) {
      final timestamp = data['timestamp'] as Timestamp;
      final date = timestamp.toDate();
      formattedDate = DateFormat('dd/MM/yyyy HH:mm').format(date);
    }

    return Container(
      alignment: alignment,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                if (isExpanded) {
                  _expandedMessages.remove(messageId);
                } else {
                  _expandedMessages.add(messageId);
                }
              });
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: bubbleColor,
                borderRadius: radius,
              ),
              child: Text(
                text,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                formattedDate,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      //color: Colors.grey[900],
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Scrivi un messaggio...',
                hintStyle: TextStyle(color: Colors.grey),
                border: InputBorder.none,
              ),
            ),
          ),
          IconButton(
            onPressed: _sendMessage,
            icon: const Icon(Icons.send, color: Colors.blue),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:travel_app/Controllers/ChatMethods.dart';
import 'package:travel_app/Controllers/UserMethods.dart';
import 'package:travel_app/Controllers/UserProvider.dart';
import 'package:travel_app/Views/Contact.dart';
import 'package:travel_app/Views/MessageList.dart';

class Chat extends StatefulWidget {
  final String chatId;
  final Map<String, dynamic>? profile; // Dati del destinatario della chat

  const Chat({super.key, required this.chatId, required this.profile});

  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final _controller = TextEditingController();
  ChatMethods chatMethods = ChatMethods();
  UserMethods userMethods = UserMethods();
  UserProvider userProvider = UserProvider();

  void _sendMessage() async {
    if (_controller.text.trim().isNotEmpty) {
      final recipientId = widget.profile?['uid']; // Assumi che il profilo contenga l'ID del destinatario

      if (recipientId != null) {
        // Invia il messaggio e invia la notifica push
        await chatMethods.sendMessage(widget.chatId, _controller.text.trim(), recipientId);
      }

      _controller.clear(); // Pulisce il campo di testo
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.profile?['username'] ?? 'Chat'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: InkWell(
              highlightColor: Colors.transparent,
              splashColor: Colors.transparent,
              onTap: () async {
                // Vai alla pagina del profilo del contatto
                final profileId = await userMethods
                    .getIdByUsername(widget.profile?['username']);
                if (profileId != null) {
                  final profileDetails =
                      await userProvider.getProfileDetails(profileId);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Contact(profile: profileDetails!),
                    ),
                  );
                }
              },
              child: CircleAvatar(
                backgroundColor: Colors.blue,
                backgroundImage: widget.profile?['photoUrl'] != ''
                    ? NetworkImage(widget.profile?['photoUrl'])
                    : null,
                child: widget.profile?['photoUrl'] == ''
                    ? Icon(Icons.person, color: Colors.white)
                    : null,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Expanded(child: MessageList(widget.chatId)),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration:
                            InputDecoration(labelText: 'Write a Message...'),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.send),
                      onPressed: _sendMessage,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

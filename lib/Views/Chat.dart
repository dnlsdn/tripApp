import 'package:flutter/material.dart';
import 'package:travel_app/Controllers/ChatMethods.dart';
import 'package:travel_app/Views/MessageList.dart';

class Chat extends StatefulWidget {
  final String chatId;

  Chat(this.chatId);

  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final _controller = TextEditingController();
  ChatMethods chatMethods = ChatMethods();

  void _sendMessage() {
    if (_controller.text.trim().isNotEmpty) {
      chatMethods.sendMessage(widget.chatId, _controller.text.trim());
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat'),
      ),
      body: Column(
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
                        InputDecoration(labelText: 'Scrivi un messaggio...'),
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
    );
  }
}

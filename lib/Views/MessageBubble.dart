import 'package:flutter/material.dart';

class MessageBubble extends StatelessWidget {
  final String text;
  final String senderUsername;
  final bool isMe;
  final DateTime? timestamp;

  MessageBubble({
    required this.text,
    required this.senderUsername,
    required this.isMe,
    this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
    final timeString = timestamp != null
        ? "${timestamp!.hour}:${timestamp!.minute.toString().padLeft(2, '0')}"
        : '';

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isMe ? Colors.blue[100] : Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              senderUsername,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            ),
            SizedBox(height: 4),
            Text(
              text,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 4),
            Text(
              timeString,
              style: TextStyle(
                fontSize: 10,
                color: Colors.black38,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

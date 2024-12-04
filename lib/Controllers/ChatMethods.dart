import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:travel_app/Controllers/NotificationMethods.dart';
import 'package:travel_app/Controllers/UserProvider.dart';

class ChatMethods {
  final NotificationMethods notificationService = NotificationMethods();

  Future<void> sendMessage(
      String chatId, String text, String recipientId) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add({
      'senderId': user.uid,
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
      'read': false,
    });

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(recipientId)
        .get();
    String? token;

    if (!Platform.isIOS) {
      token = doc['fcmToken'];
    }

    if (token != null) {
      await notificationService.sendNotification(
        token: token,
        title: 'Nuovo messaggio',
        body: text,
      );
    }
  }

  Stream<List<Map<String, dynamic>>> getMessages(String chatId) {
    return FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList());
  }

  Future<String> startChat(String currentUserId, String otherUserId) async {
    final query = await FirebaseFirestore.instance
        .collection('chats')
        .where('participants', arrayContains: currentUserId)
        .get();

    for (var doc in query.docs) {
      final participants = doc['participants'] as List;
      if (participants.contains(otherUserId)) {
        return doc.id;
      }
    }

    final newChat = await FirebaseFirestore.instance.collection('chats').add({
      'participants': [currentUserId, otherUserId],
      'lastMessage': '',
      'lastMessageTimestamp': FieldValue.serverTimestamp(),
      'lastMessageSenderId': null,
      'lastMessageRead': true,
    });

    return newChat.id;
  }

  Future<String?> findChatId(String userId1, String userId2) async {
    final firestore = FirebaseFirestore.instance;

    try {
      final querySnapshot = await firestore
          .collection('chats')
          .where('participants', arrayContains: userId1)
          .get();

      for (var doc in querySnapshot.docs) {
        final participants = List<String>.from(doc['participants']);
        if (participants.contains(userId2)) {
          return doc.id;
        }
      }

      return null;
    } catch (e) {
      print("Errore nel trovare la chat: $e");
      return null;
    }
  }
}

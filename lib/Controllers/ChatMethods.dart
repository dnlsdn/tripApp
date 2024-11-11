import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatMethods {
  Future<void> sendMessage(String chatId, String text) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    final message = {
      'senderId': user.uid,
      'senderUsername': user.displayName ?? 'Anonymous',
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
    };

    await FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add(message);
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
    // Controlla se esiste già una chat tra i due utenti
    final query = await FirebaseFirestore.instance
        .collection('chats')
        .where('participants', arrayContains: currentUserId)
        .get();

    for (var doc in query.docs) {
      final participants = doc['participants'] as List;
      if (participants.contains(otherUserId)) {
        return doc.id; // Ritorna l'ID della chat esistente
      }
    }

    // Se non esiste, crea una nuova chat
    final newChat = await FirebaseFirestore.instance.collection('chats').add({
      'participants': [currentUserId, otherUserId],
      'lastMessage': '',
      'lastMessageTimestamp': FieldValue.serverTimestamp(),
    });

    return newChat.id; // Ritorna il nuovo ID della chat
  }
}

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:rxdart/rxdart.dart';
import 'package:travel_app/Controllers/NotificationMethods.dart';

class UserMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final NotificationMethods notificationService = NotificationMethods();

  Future<List<String>> getSuggestions(String query) async {
    if (query.isEmpty) return [];

    final snapshot = await _firestore
        .collection('users')
        .where('username', isGreaterThanOrEqualTo: query)
        .where('username', isLessThan: query + '\uf8ff')
        .get();

    return snapshot.docs.map((doc) => doc['username'] as String).toList();
  }

  Future<String?> getIdByUsername(String username) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('username', isEqualTo: username)
          .get();
      if (snapshot.size != 0) {
        return snapshot.docs.first['uid'];
      } else {
        print('Utente non trovato');
        return null;
      }
    } catch (e) {
      print('Errore: $e');
      return null;
    }
  }

  Future<void> sendFriendRequest(
      String currentUserId, String friendUserId) async {
    await FirebaseFirestore.instance
        .collection('friendships')
        .doc('${currentUserId}_$friendUserId')
        .set({
      'mittente': currentUserId,
      'destinatario': friendUserId,
      'status': 'pending',
    });

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(friendUserId)
        .get();
    String? token;

    if (!Platform.isIOS) {
      token = doc['fcmToken'];
    }

    if (token != null) {
      await notificationService.sendNotification(
        token: token,
        title: 'Nuova richiesta di amicizia',
        body: 'Hai ricevuto una nuova richiesta di amicizia!',
      );
    }
  }

  Future<String> getFriendshipStatus(
      String destinatario, String mittente) async {
    try {
      final docId = '${mittente}_$destinatario';

      final docSnapshot = await FirebaseFirestore.instance
          .collection('friendships')
          .doc(docId)
          .get();

      if (docSnapshot.exists) {
        return docSnapshot.data()?['status'];
      } else {
        final docId = '${destinatario}_$mittente';

        final docSnapshot = await FirebaseFirestore.instance
            .collection('friendships')
            .doc(docId)
            .get();

        if (docSnapshot.exists) {
          return docSnapshot.data()?['status'];
        } else {
          return 'none';
        }
      }
    } catch (e) {
      print("Errore nel recupero dello stato di amicizia: $e");
      return 'error';
    }
  }

  Future<String> getFriendshipDestinatario(
      String destinatario, String mittente) async {
    try {
      final docId = '${mittente}_$destinatario';

      final docSnapshot = await FirebaseFirestore.instance
          .collection('friendships')
          .doc(docId)
          .get();

      if (docSnapshot.exists) {
        return docSnapshot.data()?['destinatario'];
      } else {
        final docId = '${destinatario}_$mittente';

        final docSnapshot = await FirebaseFirestore.instance
            .collection('friendships')
            .doc(docId)
            .get();

        if (docSnapshot.exists) {
          return docSnapshot.data()?['status'];
        } else {
          return 'none';
        }
      }
    } catch (e) {
      print("Errore nel recupero dello stato di amicizia: $e");
      return 'error';
    }
  }

  Future<void> acceptFriendRequest(
      String currentUserId, String friendUserId) async {
    final docId = '${friendUserId}_$currentUserId';

    try {
      final docSnapshot =
          await _firestore.collection('friendships').doc(docId).get();

      if (docSnapshot.exists &&
          docSnapshot.data()?['status'] == 'pending' &&
          docSnapshot.data()?['destinatario'] == currentUserId) {
        await _firestore.collection('friendships').doc(docId).update({
          'status': 'accepted',
        });
        print('Richiesta di amicizia accettata.');
      } else {
        print('Richiesta di amicizia non trovata o già accettata.');
      }
    } catch (e) {
      print('Errore nell\'accettare la richiesta di amicizia: $e');
    }
  }

  Future<void> deleteFriendRequest(
      String currentUserId, String friendUserId) async {
    final docId = '${friendUserId}_$currentUserId';

    try {
      await _firestore.collection('friendships').doc(docId).delete();
      print('Richiesta di amicizia eliminata.');
    } catch (e) {
      print('Errore nell\'eliminare la richiesta di amicizia: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getReceivedFriendRequests(
      String userId) async {
    try {
      final snapshot = await _firestore
          .collection('friendships')
          .where('destinatario', isEqualTo: userId)
          .where('status', isEqualTo: 'pending')
          .get();

      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('Errore nel recupero delle richieste di amicizia: $e');
      return [];
    }
  }

  void fetchReceivedRequests(String userId) async {
    final requests = await getReceivedFriendRequests(userId);

    for (var request in requests) {
      print('Richiesta da: ${request['mittente']}');
    }
  }

  Stream<List<QueryDocumentSnapshot>> getFriendships(String userId) {
    final mittenteQuery = FirebaseFirestore.instance
        .collection('friendships')
        .where('status', isEqualTo: 'accepted')
        .where('mittente', isEqualTo: userId)
        .snapshots();

    final destinatarioQuery = FirebaseFirestore.instance
        .collection('friendships')
        .where('status', isEqualTo: 'accepted')
        .where('destinatario', isEqualTo: userId)
        .snapshots();

    return Rx.combineLatest2<QuerySnapshot, QuerySnapshot,
        List<QueryDocumentSnapshot>>(
      mittenteQuery,
      destinatarioQuery,
      (mittenteSnap, destinatarioSnap) {
        return [
          ...mittenteSnap.docs,
          ...destinatarioSnap.docs,
        ];
      },
    );
  }

  Future<void> deleteUserAccount() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        await user.delete();
        print('Account eliminato con successo.');
      } else {
        print('Nessun utente autenticato trovato.');
      }
    } catch (e) {
      print('Errore durante l\'eliminazione dell\'utente: $e');
    }
  }

  Future<void> deleteUserData(String userId) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).delete();
      print('Dati utente rimossi con successo.');
    } catch (e) {
      print('Errore durante la rimozione dei dati utente: $e');
    }
  }

  Future<void> deleteFriendship(
      String currentUserId, String friendUserId) async {
    try {
      final docId1 = '${currentUserId}_$friendUserId';
      final docId2 = '${friendUserId}_$currentUserId';

      final doc1Snapshot =
          await _firestore.collection('friendships').doc(docId1).get();
      final doc2Snapshot =
          await _firestore.collection('friendships').doc(docId2).get();

      if (doc1Snapshot.exists) {
        await _firestore.collection('friendships').doc(docId1).delete();
        print('Amicizia eliminata: $docId1');
      } else if (doc2Snapshot.exists) {
        await _firestore.collection('friendships').doc(docId2).delete();
        print('Amicizia eliminata: $docId2');
      } else {
        print(
            'Nessuna relazione di amicizia trovata tra $currentUserId e $friendUserId.');
      }
    } catch (e) {
      print('Errore durante l\'eliminazione dell\'amicizia: $e');
    }
  }
}

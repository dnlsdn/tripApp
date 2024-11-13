import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rxdart/rxdart.dart';

class UserMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
    final docId = '${currentUserId}_$friendUserId';

    await FirebaseFirestore.instance.collection('friendships').doc(docId).set({
      'mittente': currentUserId,
      'destinatario': friendUserId,
      'status': 'pending',
    });
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
        // Combina i documenti di entrambe le query
        return [
          ...mittenteSnap.docs,
          ...destinatarioSnap.docs,
        ];
      },
    );
  }

  Future<void> deleteUserAccount() async {
    try {
      // Ottieni l'utente attualmente loggato
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        await user.delete(); // Elimina l'utente
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
}

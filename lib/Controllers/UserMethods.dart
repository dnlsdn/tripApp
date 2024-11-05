import 'package:cloud_firestore/cloud_firestore.dart';

class UserMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<String>> getSuggestions(String query) async {
    if (query.isEmpty) return [];

    final snapshot = await _firestore
        .collection('users') // Sostituisci con il nome della tua collezione
        .where('username', isGreaterThanOrEqualTo: query)
        .where('username',
            isLessThan:
                query + '\uf8ff') // Usa '\uf8ff' per ottenere risultati simili
        .get();

    print('Documenti trovati: ${snapshot.docs.length}');

    return snapshot.docs
        .map((doc) => doc['username']
            as String) // Sostituisci con il nome del campo da usare come suggerimento
        .toList();
  }

  Future<String?> getIdByUsername(String username) async {
    try {
      // Riferimento alla collezione degli utenti

      // Recupera il documento per l'ID fornito
      final snapshot = await _firestore
          .collection('users') // Sostituisci con il nome della tua collezione
          .where('username', isEqualTo: username)
          .get();

      // Controlla se il documento esiste
      if (snapshot.size != 0) {
        // Restituisci lo username
        return snapshot
            .docs.first['uid']; // Assicurati che il campo si chiami 'username'
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
      'userId1': currentUserId,
      'userId2': friendUserId,
      'status': 'pending',
    });
  }

  /// Funzione per ottenere lo stato della richiesta di amicizia tra due utenti.
  /// Restituisce "pending", "accepted", "rejected", oppure "none" se non c'è nessuna richiesta.
  Future<String> getFriendshipStatus(String userId1, String userId2) async {
    try {
      // Genera l'ID del documento in base all'ordine degli ID degli utenti
      final docId = '${userId1}_$userId2';

      print(docId);
      // Controlla l'esistenza del documento nella collezione "friendships"
      final docSnapshot = await FirebaseFirestore.instance
          .collection('friendships')
          .doc(docId)
          .get();

      // Se il documento esiste, restituisci lo stato
      if (docSnapshot.exists) {
        print(docSnapshot.data()?['status']);
        return docSnapshot.data()?['status'] ?? 'none';
      } else {
        // Nessuna richiesta di amicizia trovata tra gli utenti
        print('quiii');
        return 'none';
      }
    } catch (e) {
      print("Errore nel recupero dello stato di amicizia: $e");
      return 'error';
    }
  }
}

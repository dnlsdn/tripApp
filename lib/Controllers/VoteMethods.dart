import 'package:cloud_firestore/cloud_firestore.dart';

class VoteMethods {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> addVote(String userId, String markerId, int side) async {
    try {
      // Crea un riferimento alla collezione "voti"
      CollectionReference votiCollection = firestore.collection('votes');

      // Aggiungi un nuovo voto
      await votiCollection.add({
        'userId': userId, // ID dell'utente
        'markerId': markerId, // ID del voto
        'side': side,
      });

      print('Voto aggiunto con successo');
    } catch (e) {
      print('Errore nell\'aggiunta del voto: $e');
    }
  }

  Future<bool> existsVote(String userId, String markerId) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('votes')
        .where('userId', isEqualTo: userId)
        .where('markerId', isEqualTo: markerId)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      return true;
    } else {
      return false;
    }
  }

  Future<int> whatVote(String userId, String markerId) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('votes')
        .where('userId', isEqualTo: userId)
        .where('markerId', isEqualTo: markerId)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      // Accedi al primo documento trovato e recupera il campo 'side'
      return querySnapshot.docs.first['side'] as int;
    } else {
      // Se non ci sono documenti, puoi gestire il caso come preferisci
      return -1; // ad esempio, ritorna 0 o un altro valore di default
    }
  }

  Future<int> getVotes(String markerId, int side) async {
    try {
      // Ottieni il documento specifico dalla collezione
      DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
          .collection('markers')
          .doc(markerId)
          .get();

      // Verifica se il documento esiste
      if (docSnapshot.exists) {
        if (side == 0) {
          // Ottieni il campo specifico dal documento, con un valore di default se è null
          var fieldValue = docSnapshot.get('positiveFeedback') ?? 0;
          return fieldValue as int;
        } else {
          var fieldValue = docSnapshot.get('negativeFeedback') ?? 0;
          return fieldValue as int;
        }
      } else {
        print('Documento non trovato');
        return 0; // Valore di default in caso di documento non trovato
      }
    } catch (e) {
      print('Errore durante il recupero del documento: $e');
      return 0; // Valore di default in caso di errore
    }
  }

  Future<void> deleteVote(String userId, String markerId) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('votes') // La collezione da cui eliminare
          .where('userId', isEqualTo: userId)
          .where('markerId', isEqualTo: markerId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Accedi al primo documento trovato e recupera il campo 'side'
        print("Documento eliminato con successo!");
        return querySnapshot.docs.first.reference.delete();
      } else {
        // Se non ci sono documenti, puoi gestire il caso come preferisci
        return; // ad esempio, ritorna 0 o un altro valore di default
      }
    } catch (e) {
      print("Errore nell'eliminazione del documento: $e");
    }
  }
}

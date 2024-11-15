import 'package:cloud_firestore/cloud_firestore.dart';

class VoteMethods {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> addVote(String userId, String markerId, int side) async {
    try {
      CollectionReference votiCollection = firestore.collection('votes');

      await votiCollection.add({
        'userId': userId,
        'markerId': markerId,
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
      return querySnapshot.docs.first['side'] as int;
    } else {
      return -1;
    }
  }

  Future<int> getVotes(String markerId, int side) async {
    try {
      DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
          .collection('markers')
          .doc(markerId)
          .get();

      if (docSnapshot.exists) {
        if (side == 0) {
          var fieldValue = docSnapshot.get('positiveFeedback') ?? 0;
          return fieldValue as int;
        } else {
          var fieldValue = docSnapshot.get('negativeFeedback') ?? 0;
          return fieldValue as int;
        }
      } else {
        print('Documento non trovato');
        return 0;
      }
    } catch (e) {
      print('Errore durante il recupero del documento: $e');
      return 0;
    }
  }

  Future<void> deleteVote(String userId, String markerId) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('votes')
          .where('userId', isEqualTo: userId)
          .where('markerId', isEqualTo: markerId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        print("Documento eliminato con successo!");
        return querySnapshot.docs.first.reference.delete();
      } else {
        return;
      }
    } catch (e) {
      print("Errore nell'eliminazione del documento: $e");
    }
  }
}

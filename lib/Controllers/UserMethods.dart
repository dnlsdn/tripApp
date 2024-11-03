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
}

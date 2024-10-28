import 'package:cloud_firestore/cloud_firestore.dart';

class Utente {
  final String email;
  final String uid;
  final String photoUrl;
  String username;

  Utente({
    required this.email,
    required this.uid,
    required this.photoUrl,
    required this.username,
  });

  Map<String, dynamic> toJson() => {
        "username": username,
        "uid": uid,
        "email": email,
        "photoUrl": photoUrl,
      };

  static Utente fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data();

    if (snapshot != null && snapshot is Map<String, dynamic>) {
      return Utente(
        email: snapshot['email'] ?? 'errore',
        uid: snapshot['uid'] ?? 'errore',
        photoUrl: snapshot['photoUrl'] ??
            'https://images.unsplash.com/photo-1683009427479-c7e36bbb7bca?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDF8MHxlZGl0b3JpYWwtZmVlZHwxfHx8ZW58MHx8fHx8',
        username: snapshot['username'] ?? 'errore',
      );
    } else {
      return Utente(
        email: 'error',
        uid: 'error',
        photoUrl:
            'https://images.unsplash.com/photo-1683009427479-c7e36bbb7bca?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDF8MHxlZGl0b3JpYWwtZmVlZHwxfHx8ZW58MHx8fHx8',
        username: 'error',
      );
    }
  }

  //Utente? copyWith({required String photoUrl}) {}

  Utente copyWith({
    String? uid,
    String? username,
    String? email,
    String? photoUrl,
  }) {
    return Utente(
      uid: uid ?? this.uid,
      username: username ?? this.username,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }
}

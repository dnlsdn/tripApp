import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:travel_app/models/Utente.dart' as model;

class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<model.Utente> getUserDetails() async {
    User currentUser = _auth.currentUser!;

    DocumentSnapshot snap =
        await _firestore.collection('users').doc(currentUser.uid).get();

    return model.Utente.fromSnap(snap);
  }

  // Future<String> signupUser({
  //   required String email,
  //   required String password,
  //   required String username,
  //   required Uint8List file,
  // }) async {
  //   String res = "Some error occurred";
  //   // try {
  //   //   if (email.isNotEmpty ||
  //   //       password.isNotEmpty ||
  //   //       username.isNotEmpty ||
  //   //       file != null) {
  //   //     // UserCredential cred = await _auth.createUserWithEmailAndPassword(
  //   //     //     email: email, password: password);

  //   //     // String photoUrl = await StorageMethods()
  //   //     //     .uploadimageToStorage('profilePics', file, false);

  //   //     model.User user = model.User(
  //   //       email: email,
  //   //       uid: "00", //cred.user!.uid,
  //   //       photoUrl: "CAMBIA",
  //   //       username: username,
  //   //     );

  //   //     // await _firestore.collection('users').doc(cred.user!.uid).set(
  //   //     //       user.toJson(),
  //   //     //     );
  //   //     res = "Success";
  //   //   }
  //   // }
  //   // on FirebaseAuthException catch (err) {
  //   //   if (err.code == 'invalid-email') {
  //   //     res = 'The email is badly formatted.';
  //   //   } else if (err.code == 'weak-password') {
  //   //     res = 'Password should be at least 6 characters';
  //   //   }
  //   // } catch (err) {
  //   //   res = err.toString();
  //   // }
  //   return res;
  // }

  Future<String> loginUser({
    required String email,
    required String password,
  }) async {
    String res = "Some error occurred";
    try {
      if (email.isNotEmpty || password.isNotEmpty) {
        await _auth.signInWithEmailAndPassword(
            email: email, password: password);
        res = "success";
      } else {
        res = "Please enter all the fields";
      }
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<void> updateUserToken(String userId) async {
    try {
      // Ottieni il token FCM solo se non sei su un simulatore iOS
      if (!(Platform.isIOS &&
          await FirebaseMessaging.instance.getAPNSToken() == null)) {
        final token = await FirebaseMessaging.instance.getToken();
        print('FCM Token: $token');

        if (token != null) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .update({
            'fcmToken': token,
          });
        }
      } else {
        print('Simulatore iOS rilevato: Ignoro il token APNs');
      }
    } catch (e) {
      print('Errore durante l\'ottenimento del token: $e');
    }
  }
}

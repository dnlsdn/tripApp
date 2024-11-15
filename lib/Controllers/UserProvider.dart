import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:travel_app/controllers/AuthMethods.dart';
import 'package:travel_app/models/Utente.dart';

class UserProvider with ChangeNotifier {
  Utente? _user;
  final AuthMethods _authMethods = AuthMethods();

  Utente? get getUser => _user;

  void setUser(Utente user) {
    _user = user;
    notifyListeners();
  }

  Future<void> refreshUser() async {
    Utente user = await _authMethods.getUserDetails();
    _user = user;
    notifyListeners();
  }

  Future<void> updateUsername(String uid, String newUsername) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'username': newUsername,
    });

    _user!.username = newUsername;

    notifyListeners();
  }

  Future<void> uploadProfilePicture(File image) async {
    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profilePictures')
          .child(_user!.uid);

      UploadTask uploadTask = storageRef.putFile(image);
      TaskSnapshot snapshot = await uploadTask;

      String downloadUrl = await snapshot.ref.getDownloadURL();

      await FirebaseFirestore.instance
          .collection('users')
          .doc(_user!.uid)
          .update({'photoUrl': downloadUrl});

      _user = _user!.copyWith(photoUrl: downloadUrl);

      notifyListeners();
    } catch (e) {
      print('Errore durante l\'upload della foto profilo: $e');
    }
  }

  Future<void> resetPassword(String email) async {
    await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
  }

  void logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      _user = null;
    } catch (e) {
      print(e);
    }
  }

  Future<String?> getUsernameById(String userId) async {
    try {
      CollectionReference usersCollection =
          FirebaseFirestore.instance.collection('users');
      DocumentSnapshot userDoc = await usersCollection.doc(userId).get();

      if (userDoc.exists) {
        return userDoc[
            'username'];
      } else {
        print('Utente non trovato');
        return null;
      }
    } catch (e) {
      print('Errore: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getProfileDetails(String profileId) async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(profileId)
          .get();

      if (doc.exists) {
        return doc.data() as Map<String, dynamic>?;
      } else {
        print('Profilo not found');
        return null;
      }
    } catch (e) {
      print('Errore nel recupero dei dettagli del profile: $e');
      return null;
    }
  }
}

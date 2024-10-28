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
    notifyListeners(); // Avvisa i listener che l'utente è stato aggiornato
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

  // Funzione per caricare la nuova foto profilo
  Future<void> uploadProfilePicture(File image) async {
    try {
      // Crea un riferimento al percorso su Firebase Storage
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profilePictures')
          .child(_user!.uid);

      // Carica il file su Firebase Storage
      UploadTask uploadTask = storageRef.putFile(image);
      TaskSnapshot snapshot = await uploadTask;

      // Ottieni l'URL della foto caricata
      String downloadUrl = await snapshot.ref.getDownloadURL();

      // Aggiorna l'utente con la nuova foto profilo
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_user!.uid)
          .update({'photoUrl': downloadUrl});

      // Aggiorna il provider locale
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
      // Riferimento alla collezione degli utenti
      CollectionReference usersCollection =
          FirebaseFirestore.instance.collection('users');

      // Recupera il documento per l'ID fornito
      DocumentSnapshot userDoc = await usersCollection.doc(userId).get();

      // Controlla se il documento esiste
      if (userDoc.exists) {
        // Restituisci lo username
        return userDoc[
            'username']; // Assicurati che il campo si chiami 'username'
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
      // Recupera i dettagli del marker dalla collezione 'markers'
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

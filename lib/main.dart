import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travel_app/Controllers/UserProvider.dart';
import 'package:travel_app/Views/BottomBar.dart';
import 'package:travel_app/Views/SignUpLogIn.dart';
import 'package:travel_app/Views/splashScreen.dart';
import 'package:travel_app/firebase_options.dart';
import 'package:travel_app/models/Utente.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    print('Errore durante l\'inizializzazione di Firebase: $e');
  }
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasData && snapshot.data != null) {
            // Carico i dati dell'utente direttamente nel builder
            _loadUserData(snapshot.data!, context);
            return SplashScreen();
          }

          // L'utente non è autenticato
          return const SignUpLogIn();
        },
      ),
      routes: {
        '/home': (context) => const BottomBar(),
        '/signUp': (context) => const SignUpLogIn(),
      },
    );
  }

  Future<void> _loadUserData(User firebaseUser, BuildContext context) async {
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(firebaseUser.uid)
        .get();

    final username = userDoc.data()?['username'] as String? ?? '';
    final photoUrl = userDoc.data()?['photoUrl'] as String? ?? '';
    final utente = Utente(
      uid: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      username: username,
      photoUrl: photoUrl,
    );

    // Non serve mounted qui, poiché il contesto è ancora sicuro in questo punto
    Provider.of<UserProvider>(context, listen: false).setUser(utente);
    print('UTENTE: ${utente.username}');
  }
}

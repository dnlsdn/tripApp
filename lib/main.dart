import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travel_app/Controllers/UserProvider.dart';
import 'package:travel_app/Views/BottomBar.dart';
import 'package:travel_app/Views/SignUpLogIn.dart';
import 'package:travel_app/Views/splashScreen.dart';
import 'package:travel_app/firebase_options.dart';
import 'package:travel_app/models/Utente.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Messaggio ricevuto in background: ${message.messageId}');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    await _configureFirebaseMessaging();
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

Future<void> _configureFirebaseMessaging() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    print('Permessi di notifica concessi');
  } else {
    print('Permessi di notifica negati o provvisori concessi');
  }

  if (!Platform.isIOS) {
    messaging.getToken().then((token) {
      if (token != null) {
        print('FCM Token: $token');
      }
    });
  }

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    if (message.notification != null) {
      print('Messaggio ricevuto in foreground: ${message.notification!.title}');
    }
  });

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print('Notifica aperta: ${message.notification?.title}');
    navigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const BottomBar()),
      (route) => false,
    );
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      navigatorKey: navigatorKey,
      home: AuthHandler(),
      routes: {
        '/home': (context) => const BottomBar(),
        '/signUp': (context) => const SignUpLogIn(),
      },
    );
  }
}

class AuthHandler extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasData && snapshot.data != null) {
          _loadUserData(snapshot.data!, context);
          return SplashScreen();
        }

        return const SignUpLogIn();
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

    Provider.of<UserProvider>(context, listen: false).setUser(utente);
    print('UTENTE: ${utente.username}');
  }
}

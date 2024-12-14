import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:travel_app/Views/ChatPt2.dart';
import 'package:travel_app/models/Utente.dart';
import 'package:travel_app/Controllers/UserProvider.dart';
import 'package:travel_app/Views/Chat.dart';

class SearchUserScreen extends StatefulWidget {
  const SearchUserScreen({Key? key}) : super(key: key);

  @override
  State<SearchUserScreen> createState() => _SearchUserScreenState();
}

class _SearchUserScreenState extends State<SearchUserScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final Utente? currentUser = userProvider.getUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cerca un utente'),
      ),
      body: Column(
        children: [
          // TextField ricerca username
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Inserisci username...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (val) {
                setState(() {
                  _searchQuery = val.trim().toLowerCase();
                });
              },
            ),
          ),

          // Lista utenti filtrata
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: (_searchQuery.isEmpty)
                  ? FirebaseFirestore.instance
                      .collection('users')
                      .orderBy('username', descending: false) // o come preferisci
                      .snapshots()
                  : FirebaseFirestore.instance
                      .collection('users')
                      // Ricerca semplice su username in minuscolo
                      .where('usernameLowerCase', isGreaterThanOrEqualTo: _searchQuery)
                      .where('usernameLowerCase', isLessThan: _searchQuery + 'z')
                      .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('Nessun utente trovato'));
                }

                final userDocs = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: userDocs.length,
                  itemBuilder: (context, index) {
                    final data = userDocs[index].data() as Map<String, dynamic>;
                    final uid = userDocs[index].id;

                    // Evita di mostrare se stesso
                    if (uid == currentUser!.uid) {
                      return Container();
                    }

                    final username = data['username'] ?? 'User';
                    final photoUrl = data['photoUrl'] ?? '';

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: photoUrl.isNotEmpty
                            ? NetworkImage(photoUrl)
                            : null,
                        child: photoUrl.isEmpty ? const Icon(Icons.person) : null,
                      ),
                      title: Text(username),
                      onTap: () async {
                        // Crea (o recupera) la chat con l'utente selezionato
                        final chatId = await _createOrGetChat(
                          currentUser.uid,
                          uid,
                        );

                        // Vai alla ChatScreen
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Chat(
                              chatId: chatId,
                              profile: {
                                'uid': uid,
                                'username': username,
                                'photoUrl': photoUrl,
                              },
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Funzione per creare o recuperare una chat tra due utenti
  Future<String> _createOrGetChat(String myUid, String otherUid) async {
    // 1. Cerca se esiste già una chat con questi due partecipanti
    final query = await FirebaseFirestore.instance
        .collection('chats')
        .where('participants', arrayContains: myUid)
        .get();

    for (var doc in query.docs) {
      final data = doc.data();
      final participants = data['participants'] as List;
      if (participants.contains(otherUid) && participants.contains(myUid)) {
        // Chat già esistente
        return doc.id;
      }
    }

    // 2. Altrimenti crea una nuova chat
    final newChatRef = FirebaseFirestore.instance.collection('chats').doc();
    final chatData = {
      'participants': [myUid, otherUid],
      'lastMessage': '',
      'lastMessageTimestamp': FieldValue.serverTimestamp(),
      'unreadMap': {
        myUid: 0,
        otherUid: 0,
      },
    };
    await newChatRef.set(chatData);
    return newChatRef.id;
  }
}

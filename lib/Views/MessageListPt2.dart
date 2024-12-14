import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:travel_app/Controllers/UserMethods.dart';

import 'package:travel_app/Controllers/UserProvider.dart';
import 'package:travel_app/Views/ChatPt2.dart';
import 'package:travel_app/models/Utente.dart';
import 'package:travel_app/Views/Chat.dart';
import 'package:travel_app/Views/Contact.dart';
import 'package:travel_app/Views/SearchSuggestion.dart'; // Se necessario

class MessageListScreen extends StatefulWidget {
  const MessageListScreen({Key? key}) : super(key: key);

  @override
  State<MessageListScreen> createState() => _MessageListScreenState();
}

class _MessageListScreenState extends State<MessageListScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final currentUser = Provider.of<UserProvider>(context).getUser;

    return Scaffold(
      // appBar: AppBar(
      //   leading: const Text(
      //     'Messages',
      //     style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      //   ),
      //   actions: [
      //     IconButton(
      //       icon: const Icon(Icons.person_add_alt_1),
      //       onPressed: () {
      //         // Apri la schermata di ricerca utenti
      //         Navigator.push(
      //           context,
      //           MaterialPageRoute(
      //             builder: (context) => const SearchUserWithSuggestionsScreen(),
      //           ),
      //         );
      //       },
      //     ),
      //   ],
      // ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Messages',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
              ),
              const SizedBox(height: 18),
              // Barra di ricerca (locale)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Cerca nella lista chat...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onChanged: (val) {
                          setState(() {
                            _searchQuery = val.toLowerCase();
                          });
                        },
                      ),
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.8),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white),
                      ),
                      child: IconButton(
                        highlightColor: Colors.transparent,
                        icon: Icon(Icons.person_add, color: Colors.white),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const SearchUserWithSuggestionsScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // Lista chat con StreamBuilder
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('chats')
                      .where('participants', arrayContains: currentUser!.uid)
                      .orderBy('lastMessageTimestamp', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      print('MessageListScreen ERROR: ${snapshot.error}');
                      return Text('Error: ${snapshot.error}');
                    }
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final chatDocs = snapshot.data!.docs;
                    if (chatDocs.isEmpty) {
                      return const Center(child: Text('Nessuna chat trovata'));
                    }

                    // Filtro locale in base a _searchQuery
                    final filteredChats = chatDocs.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      List lastMessage = (data['participants'] ?? '');
                      print(lastMessage);
                      List users = [];
                      for (String uid in lastMessage) {
                        users.add( UserProvider().getUsernameById(uid));
                      }
                      print(users);
                      if (_searchQuery.isEmpty) return true;
                      return users.contains(_searchQuery);
                    }).toList();

                    if (filteredChats.isEmpty) {
                      return const Center(child: Text('Nessuna chat trovata'));
                    }

                    return ListView.builder(
                      itemCount: filteredChats.length,
                      itemBuilder: (context, index) {
                        final doc = filteredChats[index];
                        final data = doc.data() as Map<String, dynamic>;
                        final chatId = doc.id;

                        final List participants = data['participants'] ?? [];
                        // Trova l'altro partecipante
                        String otherUserId = participants.firstWhere(
                          (p) => p != currentUser.uid,
                          orElse: () => '',
                        );

                        final String lastMessage = data['lastMessage'] ?? '';
                        final Timestamp? lastTimestamp =
                            data['lastMessageTimestamp'];
                        final Map<String, dynamic>? unreadMap =
                            data['unreadMap'];

                        int unreadCount = 0;
                        if (unreadMap != null &&
                            unreadMap[currentUser.uid] != null) {
                          unreadCount = unreadMap[currentUser.uid];
                        }

                        // Formattazione dell'ora
                        String lastMsgTime = '';
                        if (lastTimestamp != null) {
                          final date = lastTimestamp.toDate();
                          lastMsgTime =
                              '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
                        }

                        return FutureBuilder<DocumentSnapshot>(
                          future: FirebaseFirestore.instance
                              .collection('users')
                              .doc(otherUserId)
                              .get(),
                          builder: (context, snapshotUser) {
                            if (snapshotUser.connectionState ==
                                ConnectionState.waiting) {
                              return const SizedBox.shrink();
                            }
                            if (!snapshotUser.hasData ||
                                !snapshotUser.data!.exists) {
                              return Container();
                            }

                            final otherUserData = snapshotUser.data!.data()
                                as Map<String, dynamic>?;
                            if (otherUserData == null) return Container();

                            final username =
                                otherUserData['username'] ?? 'User';
                            final photoUrl = otherUserData['photoUrl'] ?? '';

                            return ListTile(
                              leading: CircleAvatar(
                                backgroundImage: photoUrl.isNotEmpty
                                    ? NetworkImage(photoUrl)
                                    : null,
                                child: photoUrl.isEmpty
                                    ? const Icon(Icons.person)
                                    : null,
                              ),
                              title: Text(
                                username,
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.w600),
                              ),
                              subtitle: Text(
                                lastMessage.isEmpty
                                    ? 'No messages yet'
                                    : lastMessage,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    lastMsgTime,
                                    style: const TextStyle(
                                        fontSize: 12, color: Colors.grey),
                                  ),
                                  const SizedBox(height: 4),
                                  // Pallino rosso se unreadCount > 0
                                  if (unreadCount > 0)
                                    Container(
                                      width: 12,
                                      height: 12,
                                      decoration: const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                ],
                              ),
                              onTap: () {
                                // Azzera unread
                                FirebaseFirestore.instance
                                    .collection('chats')
                                    .doc(chatId)
                                    .update({
                                  'unreadMap.${currentUser.uid}': 0,
                                });

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Chat(
                                      chatId: chatId,
                                      profile: {
                                        'uid': otherUserId,
                                        'username': username,
                                        'photoUrl': photoUrl,
                                      },
                                    ),
                                  ),
                                );
                              },
                              onLongPress: () {
                                // Apri la schermata Contact se vuoi
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Contact(
                                      profile: {
                                        'uid': otherUserId,
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
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

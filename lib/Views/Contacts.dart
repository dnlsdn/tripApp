import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:travel_app/Controllers/UserMethods.dart';
import 'package:travel_app/Controllers/UserProvider.dart';
import 'package:travel_app/Views/AddMarker.dart';
import 'package:travel_app/Views/Chat.dart';
import 'package:travel_app/Views/Contact.dart';
import 'package:travel_app/Views/NewFriend.dart';

import '../models/Utente.dart';

class Contacts extends StatefulWidget {
  const Contacts({super.key});

  @override
  State<Contacts> createState() => _ContactsState();
}

class _ContactsState extends State<Contacts> {
  final TextEditingController controller = TextEditingController();
  List<String> suggestions = [];
  late UserMethods userMethods;
  late UserProvider userProvider;
  List<String> filterList = [
    'See Recent Messages',
    'See Friends\' List',
  ];
  bool seeMessages = true;
  late var mittenteQuery;
  late var destinatarioQuery;

  @override
  void initState() {
    super.initState();
    userMethods = UserMethods();
    controller.addListener(_onSearchChanged);
    userProvider = UserProvider();
  }

  @override
  void dispose() {
    controller.removeListener(_onSearchChanged);
    controller.dispose();
    super.dispose();
  }

  void _onSearchChanged() async {
    final _suggestions = await userMethods.getSuggestions(controller.text);
    setState(() {
      suggestions = _suggestions;
    });
  }

  @override
  Widget build(BuildContext context) {
    Utente? user = Provider.of<UserProvider>(context).getUser;

    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Contacts',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      decoration: InputDecoration(
                        hintText: 'Search...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        suffixIcon: controller.text.isNotEmpty
                            ? IconButton(
                                icon: Icon(Icons.clear),
                                onPressed: () => controller.clear(),
                              )
                            : null,
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  _buildActionButton(Icons.filter_list, Colors.blue, () {
                    showPopupWithFilters(context);
                  }),
                  SizedBox(width: 8),
                  _buildActionButton(Icons.person_add, Colors.green, () async {
                    List<Map<String, dynamic>> requests =
                        await userMethods.getReceivedFriendRequests(user.uid);
                    print(requests);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NewFriend(requests: requests),
                      ),
                    );
                  }),
                ],
              ),
              SizedBox(height: 10),
              if (controller.text.isEmpty)
                if (seeMessages == true)
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('chats')
                          .where('participants', arrayContains: user.uid)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return const Center(
                              child: Text("Zero Active Chat Found"));
                        }

                        // Filtra ed ordina i documenti nel client
                        final chats = snapshot.data!.docs;
                        chats.sort((a, b) {
                          final aTimestamp = (a.data() as Map<String, dynamic>)[
                              'lastMessageTimestamp'] as Timestamp?;
                          final bTimestamp = (b.data() as Map<String, dynamic>)[
                              'lastMessageTimestamp'] as Timestamp?;
                          return (bTimestamp?.millisecondsSinceEpoch ?? 0)
                              .compareTo(
                                  aTimestamp?.millisecondsSinceEpoch ?? 0);
                        });

                        return ListView.builder(
                          itemCount: chats.length,
                          itemBuilder: (context, index) {
                            final chat = chats[index];
                            final chatData =
                                chat.data() as Map<String, dynamic>;
                            final otherUserId =
                                (chatData['participants'] as List)
                                    .firstWhere((id) => id != user.uid);

                            return _buildChatTile(
                                chat.id, otherUserId, chatData);
                          },
                        );
                      },
                    ),
                  )
                else
                  Expanded(
                    child: StreamBuilder<List<QueryDocumentSnapshot>>(
                      stream: userMethods.getFriendships(user.uid),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Center(
                            child: Text("No Friends Found"),
                          );
                        }

                        final friendsList = snapshot.data!;

                        return ListView.builder(
                          itemCount: friendsList.length,
                          itemBuilder: (context, index) {
                            final friendData = friendsList[index].data()
                                as Map<String, dynamic>;
                            final friendId =
                                friendData['destinatario'] == user.uid
                                    ? friendData['mittente']
                                    : friendData['destinatario'];

                            return FutureBuilder<DocumentSnapshot>(
                              future: FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(friendId)
                                  .get(),
                              builder: (context, friendSnapshot) {
                                if (!friendSnapshot.hasData) {
                                  return const SizedBox.shrink();
                                }

                                final friendDetails = friendSnapshot.data!
                                    .data() as Map<String, dynamic>;
                                final username = friendDetails['username'];
                                final photoUrl = friendDetails['photoUrl'];

                                return ListTile(
                                  leading: CircleAvatar(
                                    backgroundImage: photoUrl != null
                                        ? NetworkImage(photoUrl)
                                        : null,
                                    child: photoUrl == null
                                        ? Icon(Icons.person)
                                        : null,
                                  ),
                                  title: Row(
                                    children: [
                                      Text(username ?? 'Unknown User'),
                                      Spacer(),
                                      InkWell(
                                        highlightColor: Colors.transparent,
                                        splashColor: Colors.transparent,
                                        onTap: () {
                                          
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(5),
                                          decoration: BoxDecoration(
                                            border:
                                                Border.all(color: Colors.red),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: const Text('Unfollow'),
                                        ),
                                      ),
                                    ],
                                  ),
                                  onTap: () async {
                                    final profileId = await userMethods
                                        .getIdByUsername(username);
                                    if (profileId != null) {
                                      final profileDetails = await userProvider
                                          .getProfileDetails(profileId);
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              Contact(profile: profileDetails!),
                                        ),
                                      );
                                    }
                                  },
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                  )
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: suggestions.length,
                    itemBuilder: (context, index) {
                      return Container(
                        margin:
                            EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.blue, width: 2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ListTile(
                          onTap: () async {
                            final profileId = await userMethods
                                .getIdByUsername(suggestions[index]);
                            if (profileId != null) {
                              final profileDetails = await userProvider
                                  .getProfileDetails(profileId);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      Contact(profile: profileDetails!),
                                ),
                              );
                            }
                          },
                          title: Text(suggestions[index]),
                        ),
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

  Widget _buildActionButton(
      IconData icon, Color color, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.8),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white),
      ),
      child: IconButton(
        highlightColor: Colors.transparent,
        icon: Icon(icon, color: Colors.white),
        onPressed: onPressed,
      ),
    );
  }

  void showPopupWithFilters(BuildContext context) {
    Utente? user = Provider.of<UserProvider>(context, listen: false).getUser;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Filter Contacts"),
          content: Container(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true, // Ridimensiona in base agli elementi
              itemCount: filterList.length,
              itemBuilder: (context, index) {
                return ListTile(
                  // leading:
                  //     widget.excludeMarker.contains(filterIconList[index])
                  //         ? Icon(Icons.visibility_off)
                  //         : Icon(Icons.visibility),
                  title: Text(filterList[index]),
                  onTap: () {
                    if (index == 0) {
                      setState(() {
                        seeMessages = true;
                      });
                    } else {
                      setState(() {
                        seeMessages = false;
                        mittenteQuery = FirebaseFirestore.instance
                            .collection('friendships')
                            .where('status', isEqualTo: 'accepted')
                            .where('mittente', isEqualTo: user!.uid)
                            .where('destinatario', isEqualTo: user.uid)
                            .snapshots();
                        destinatarioQuery = FirebaseFirestore.instance
                            .collection('friendships')
                            .where('status', isEqualTo: 'accepted')
                            .where('destinatario', isEqualTo: user.uid)
                            .snapshots();
                      });
                    }

                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                "Close",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildChatTile(
      String chatId, String otherUserId, Map<String, dynamic> chatData) {
    return FutureBuilder<DocumentSnapshot>(
      future:
          FirebaseFirestore.instance.collection('users').doc(otherUserId).get(),
      builder: (context, userSnapshot) {
        if (!userSnapshot.hasData) {
          return const SizedBox.shrink();
        }

        final otherUserData = userSnapshot.data!.data() as Map<String, dynamic>;
        final username = otherUserData['username'];
        final photoUrl = otherUserData['photoUrl'];

        final lastMessageSenderId = chatData['lastMessageSenderId'];
        final isRead = chatData['lastMessageRead'] ?? true; // Default true
        final currentUserId = FirebaseAuth.instance.currentUser!.uid;

        return ListTile(
          leading: Stack(
            children: [
              CircleAvatar(
                backgroundColor: photoUrl == '' ? Colors.grey : null,
                backgroundImage: photoUrl != '' ? NetworkImage(photoUrl) : null,
                child: photoUrl == ''
                    ? Icon(Icons.person, color: Colors.white)
                    : null,
              ),
              // Mostra il pallino rosso solo se:
              // 1. L'ultimo messaggio non è stato inviato dall'utente corrente.
              // 2. L'ultimo messaggio non è stato letto.
              if (lastMessageSenderId != currentUserId && !isRead)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
          title: Text(username ?? 'Error'),
          subtitle: Text(chatData['lastMessage'] ?? ''),
          onTap: () async {
            final profileId = await userMethods.getIdByUsername(username);
            final profileDetails =
                await userProvider.getProfileDetails(profileId!);
            // Aggiorna "lastMessageRead" solo se l'utente è il destinatario
            if (lastMessageSenderId != currentUserId && !isRead) {
              FirebaseFirestore.instance
                  .collection('chats')
                  .doc(chatId)
                  .update({
                'lastMessageRead': true, // Segna il messaggio come letto
              });
            }

            // Naviga alla chat
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Chat(
                  chatId: chatId,
                  profile: profileDetails,
                ),
              ),
            );
          },
        );
      },
    );
  }
}

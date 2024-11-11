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
              Text(
                'Contacts',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
              ),
              SizedBox(height: 18),
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
                  _buildActionButton(Icons.filter_list, Colors.blue, () {}),
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
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('chats')
                        .where('participants', arrayContains: user.uid)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(
                            child: Text("Zero Active Chat Found"));
                      }

                      // Filtra ed ordina i documenti nel client
                      final chats = snapshot.data!.docs;
                      chats.sort((a, b) {
                        final aTimestamp = (a.data()
                                as Map<String, dynamic>)['lastMessageTimestamp']
                            as Timestamp?;
                        final bTimestamp = (b.data()
                                as Map<String, dynamic>)['lastMessageTimestamp']
                            as Timestamp?;
                        return (bTimestamp?.millisecondsSinceEpoch ?? 0)
                            .compareTo(aTimestamp?.millisecondsSinceEpoch ?? 0);
                      });

                      return ListView.builder(
                        itemCount: chats.length,
                        itemBuilder: (context, index) {
                          final chat = chats[index];
                          final chatData = chat.data() as Map<String, dynamic>;
                          final otherUserId = (chatData['participants'] as List)
                              .firstWhere((id) => id != user.uid);

                          return _buildChatTile(chat.id, otherUserId, chatData);
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

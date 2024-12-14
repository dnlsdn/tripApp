import 'package:flutter/material.dart';
import 'package:travel_app/Controllers/UserMethods.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:travel_app/Controllers/UserProvider.dart';
import 'package:travel_app/Views/ChatPt2.dart';
import 'package:travel_app/models/Utente.dart';
import 'package:travel_app/Views/Chat.dart';

class SearchUserWithSuggestionsScreen extends StatefulWidget {
  const SearchUserWithSuggestionsScreen({Key? key}) : super(key: key);

  @override
  State<SearchUserWithSuggestionsScreen> createState() =>
      _SearchUserWithSuggestionsScreenState();
}

class _SearchUserWithSuggestionsScreenState
    extends State<SearchUserWithSuggestionsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final UserMethods userMethods = UserMethods();

  List<String> suggestions = [];

  @override
  void initState() {
    super.initState();
  }

  void _onSearchChanged(String query) async {
    if (query.isEmpty) {
      setState(() => suggestions = []);
      return;
    }

    final results = await userMethods.getSuggestions(query);
    setState(() {
      suggestions = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = Provider.of<UserProvider>(context).getUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Username'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search Username',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),

          Expanded(
            child: ListView.builder(
              itemCount: suggestions.length,
              itemBuilder: (context, index) {
                final username = suggestions[index];
                return ListTile(
                  title: Text(username),
                  onTap: () async {
                    final userId = await userMethods.getIdByUsername(username);
                    if (userId == null) {
                      print('Utente non trovato');
                      return;
                    }
                    if (currentUser == null) return;

                    final chatId = await _createOrGetChat(
                      currentUser.uid,
                      userId,
                    );

                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Chat(
                          chatId: chatId,
                          profile: {
                            'uid': userId,
                            'username': username,
                            'photoUrl':
                                '',
                          },
                        ),
                      ),
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

  Future<String> _createOrGetChat(String myUid, String otherUid) async {
    final query = await FirebaseFirestore.instance
        .collection('chats')
        .where('participants', arrayContains: myUid)
        .get();

    for (var doc in query.docs) {
      final data = doc.data();
      final participants = data['participants'] as List<dynamic>;
      if (participants.contains(otherUid) && participants.contains(myUid)) {
        return doc.id;
      }
    }
    
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

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:travel_app/Controllers/UserMethods.dart';
import 'package:travel_app/Controllers/UserProvider.dart';
import 'package:travel_app/Views/AddMarker.dart';
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
              SizedBox(
                height: 18,
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      decoration: InputDecoration(
                        hintText: 'Cerca...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.8),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white)),
                    child: IconButton(
                      highlightColor: Colors.transparent,
                      icon: Icon(
                        Icons.filter_list,
                        color: Colors.white,
                      ),
                      onPressed: () {},
                    ),
                  ),
                  SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.8),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white)),
                    child: IconButton(
                      highlightColor: Colors.transparent,
                      icon: Icon(
                        Icons.person_add,
                        color: Colors.white,
                      ),
                      onPressed: () async {
                        print(user!.uid);
                        List<Map<String, dynamic>> requests = await userMethods
                            .getReceivedFriendRequests(user!.uid);
                        print(requests);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => NewFriend(
                              requests: requests,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Stack(
                children: [
                  Column(
                    children: [
                      Text('ciao'),
                    ],
                  ),
                  if (controller.text.isNotEmpty)
                    Container(
                      color: Colors.black,
                      height: 380,
                      child: ListView.builder(
                        itemCount: suggestions.length,
                        itemBuilder: (context, index) {
                          return Container(
                            margin: EdgeInsets.symmetric(
                                vertical: 4, horizontal: 8),
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
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travel_app/Controllers/UserMethods.dart';
import 'package:travel_app/Controllers/UserProvider.dart';
import 'package:travel_app/Views/Contact.dart';

import '../models/Utente.dart';

class NewFriend extends StatefulWidget {
  final List<Map<String, dynamic>> requests;
  const NewFriend({super.key, required this.requests});

  @override
  State<NewFriend> createState() => _NewFriendState();
}

class _NewFriendState extends State<NewFriend> {
  UserMethods userMethods = UserMethods();
  UserProvider userProvider = UserProvider();
  @override
  Widget build(BuildContext context) {
    Utente? user = Provider.of<UserProvider>(context).getUser;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.blue, width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      highlightColor: Colors.transparent,
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_ios_new,
                          color: Colors.white, size: 22),
                    ),
                  ),
                  const SizedBox(width: 18),
                  Text(
                    'New Friend Requests',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                  ),
                ],
              ),
              SizedBox(
                height: 18,
              ),
              Expanded(
                child: widget.requests.length == 0
                    ? Center(
                        child: Text('Zero Requests'),
                      )
                    : ListView.builder(
                        itemCount: widget.requests.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Column(
                            children: [
                              InkWell(
                                highlightColor: Colors.transparent,
                                splashColor: Colors.transparent,
                                onTap: () async {
                                  if (widget.requests[index]['mittente'] !=
                                      null) {
                                    final profileDetails =
                                        await userProvider.getProfileDetails(
                                            widget.requests[index]['mittente']);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            Contact(profile: profileDetails!),
                                      ),
                                    );
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.blue),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 8,
                                      ),
                                      FutureBuilder<String?>(
                                        future: UserProvider().getUsernameById(
                                            widget.requests[index]['mittente']),
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return Text('Caricamento...');
                                          } else if (snapshot.hasError) {
                                            return Text('Errore');
                                          } else {
                                            return Text(
                                              snapshot.data ?? 'Anonimo',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18),
                                            );
                                          }
                                        },
                                      ),
                                      Spacer(),
                                      IconButton(
                                        onPressed: () {
                                          userMethods.acceptFriendRequest(
                                              user!.uid,
                                              widget.requests[index]
                                                  ['mittente']);

                                          Navigator.pop(context);
                                        },
                                        icon: Icon(
                                          Icons.check_circle_outline,
                                          color: Colors.green,
                                          size: 27,
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          userMethods.deleteFriendRequest(
                                              user!.uid,
                                              widget.requests[index]
                                                  ['mittente']);

                                          Navigator.pop(context);
                                        },
                                        icon: Icon(
                                          Icons.cancel_outlined,
                                          color: Colors.red,
                                          size: 27,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 8,
                              ),
                            ],
                          );
                        }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

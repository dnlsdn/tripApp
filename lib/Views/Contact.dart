import 'dart:async';

import 'package:cupertino_modal_sheet/cupertino_modal_sheet.dart';
import 'package:custom_info_window/custom_info_window.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travel_app/Controllers/ChatMethods.dart';
import 'package:travel_app/Controllers/GeneralMethods.dart';
import 'package:travel_app/Controllers/GoogleMapsMethods.dart';
import 'package:travel_app/Controllers/UserMethods.dart';
import 'package:travel_app/Controllers/UserProvider.dart';
import 'package:travel_app/Utils/FullScreenImage.dart';
import 'package:travel_app/Views/Chat.dart';
import 'package:travel_app/Views/MessageList.dart';
import 'package:travel_app/Views/ReportUser.dart';
import 'package:travel_app/models/Utente.dart';

class Contact extends StatefulWidget {
  final Map<String, dynamic> profile;
  const Contact({super.key, required this.profile});

  @override
  State<Contact> createState() => _ContactState();
}

class _ContactState extends State<Contact> {
  String image = '';
  GeneralMethods generalMethods = GeneralMethods();
  UserMethods userMethods = UserMethods();
  String nTravels = 'err';
  late GoogleMapsMethods googleMapsMethods;
  bool requestSent = false;
  String status = '';
  ChatMethods chatMethods = ChatMethods();
  String destinatario = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    image = widget.profile['photoUrl'];
    googleMapsMethods =
        GoogleMapsMethods(setState, CustomInfoWindowController());
    loadNTravels();
    loadStatus();
  }

  Future<void> loadNTravels() async {
    final result =
        await googleMapsMethods.loadNumbersPolylines(widget.profile['uid']);
    setState(() {
      nTravels = result;
    });
  }

  Future<void> loadStatus() async {
    Utente? user = Provider.of<UserProvider>(context, listen: false).getUser;
    if (user != null) {
      final resultStatus = await userMethods.getFriendshipStatus(
          user.uid, widget.profile['uid']);
      final resultDestinatario = await userMethods.getFriendshipDestinatario(
          user.uid, widget.profile['uid']);
      setState(() {
        status = resultStatus;
        destinatario = resultDestinatario;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Utente? user = Provider.of<UserProvider>(context).getUser;
    print('qui: ' + status);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
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
                    widget.profile['username'],
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 27,
                        color: Colors.white),
                  ),
                ],
              ),
              SizedBox(
                height: 18,
              ),
              if (widget.profile['photoUrl'] != "")
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.blue, width: 2),
                    ),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                FullScreenImage(imageUrl: image),
                          ),
                        );
                      },
                      child: CircleAvatar(
                        radius: 68,
                        backgroundImage: NetworkImage(
                          image,
                        ),
                      ),
                    ),
                  ),
                ),
              SizedBox(
                height: 18,
              ),
              Text(
                "Username: ${widget.profile['username']}",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              Divider(
                height: 18,
              ),
              // Text(
              //   "Nation: ${widget.profile['paese']}",
              //   style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              // ),
              // Divider(
              //   height: 18,
              // ),
              Text(
                "N° Travels: $nTravels",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              Spacer(),
              if (user!.uid != widget.profile['uid'])
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    InkWell(
                      onTap: () async {
                        Utente? user =
                            Provider.of<UserProvider>(context, listen: false)
                                .getUser;
                        if (user != null) {
                          final chatId = await chatMethods.startChat(
                              user.uid, widget.profile['uid']);

                          // Naviga alla schermata di chat con l'ID della chat
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Chat(
                                chatId: chatId,
                                profile: widget.profile,
                              ),
                            ),
                          );
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            //shape: BoxShape.circle,
                            border: Border.all(color: Colors.blue, width: 2),
                            borderRadius: BorderRadius.circular(8)),
                        child: const Text('Contact User'),
                      ),
                    ),
                    InkWell(
                      onTap: () async {
                        showCupertinoModalSheet(
                          context: context,
                          builder: (context) => const ReportUser(),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            //shape: BoxShape.circle,
                            border: Border.all(color: Colors.red, width: 2),
                            borderRadius: BorderRadius.circular(8)),
                        child: const Text('Report User'),
                      ),
                    ),
                  ],
                ),
              SizedBox(
                height: 18,
              ),
              if (user.uid != widget.profile['uid'])
                InkWell(
                  onTap: () async {
                    userMethods.sendFriendRequest(
                        user.uid, widget.profile['uid']);
                    setState(() {
                      requestSent = true;
                    });
                    Timer(Duration(seconds: 1), () {
                      setState(() {
                        requestSent = false;
                      });
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 38.0),
                    child: Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          //shape: BoxShape.circle,
                          border: Border.all(color: Colors.green, width: 2),
                          borderRadius: BorderRadius.circular(8)),
                      child: status == 'accepted'
                          ? const Text('You are already Friend!')
                          : status == 'pending' && destinatario == user.uid
                              ? Row(
                                  children: [
                                    const Text('Request Pending'),
                                    Spacer(),
                                    IconButton(
                                      onPressed: () {
                                        userMethods.acceptFriendRequest(
                                            user.uid, widget.profile['uid']);
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
                                            user.uid, widget.profile['uid']);
                                        Navigator.pop(context);
                                      },
                                      icon: Icon(
                                        Icons.cancel_outlined,
                                        color: Colors.red,
                                        size: 27,
                                      ),
                                    ),
                                  ],
                                )
                              : status == 'pending' && destinatario != user.uid
                                  ? const Text('Friendship Sent')
                                  : InkWell(
                                      onTap: () {
                                        userMethods.sendFriendRequest(
                                            user.uid, widget.profile['uid']);
                                        Navigator.pop(context);
                                      },
                                      child: Text('Send Friend Request'),
                                    ),
                    ),
                  ),
                ),
              if (requestSent)
                const Center(
                  child: Text(
                    'Request Sent',
                    style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 22),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

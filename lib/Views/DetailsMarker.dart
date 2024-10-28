import 'dart:async';

import 'package:custom_info_window/custom_info_window.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travel_app/Controllers/GoogleMapsMethods.dart';
import 'package:travel_app/Controllers/UserProvider.dart';
import 'package:travel_app/Controllers/VoteMethods.dart';
import 'package:travel_app/Utils/FullScreenImage.dart';
import 'package:travel_app/Views/Contact.dart';
import 'package:travel_app/models/Utente.dart';

class DetailsMarker extends StatefulWidget {
  final Map<String, dynamic> details;
  const DetailsMarker({super.key, required this.details});

  @override
  State<DetailsMarker> createState() => _DetailsMarkerState();
}

class _DetailsMarkerState extends State<DetailsMarker> {
  String image = '';
  String address = '';
  String description = '';
  late GoogleMapsMethods googleMapsMethods;
  late UserProvider userProvider;
  String sender = '';
  late VoteMethods voteMethods;
  bool alertFeedback = false;
  String stringFeedback = '';
  bool existsVote = false;
  int whatVote = -1;
  int positiveFeedback = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    image = widget.details['photoURL'];
    description = widget.details['description'];
    googleMapsMethods =
        GoogleMapsMethods(setState, CustomInfoWindowController());
    loadAddress();
    userProvider = UserProvider();
    loadSender();
    voteMethods = VoteMethods();
    positiveFeedback = widget.details['positiveFeedback'];
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    loadWhatVote();
  }

  Future<void> loadAddress() async {
    String fetchedAddress = await googleMapsMethods.getAddressFromLatLng(
        widget.details['latitude'], widget.details['longitude']);
    setState(() {
      address = fetchedAddress;
    });
  }

  Future<void> loadSender() async {
    String fetchedSender =
        (await userProvider.getUsernameById(widget.details['mittente']))!;
    setState(() {
      sender = fetchedSender;
    });
  }

  Future<void> loadWhatVote() async {
    Utente? user = Provider.of<UserProvider>(context).getUser;
    if (user != null) {
      int vote = await voteMethods.whatVote(user.uid, widget.details['id']);
      setState(() {
        whatVote = vote;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Utente? user = Provider.of<UserProvider>(context).getUser;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
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
                      widget.details['title'],
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
                if (widget.details['photoURL'] != "")
                  Center(
                    child: Container(
                      height: 188,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.blue, width: 2),
                        borderRadius: BorderRadius.circular(8),
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
                        child: Image.network(
                          image,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.error,
                                color: Colors.red, size: 50);
                          },
                        ),
                      ),
                    ),
                  ),
                SizedBox(
                  height: 18,
                ),
                Text('Address',
                    style:
                        TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                SizedBox(height: 5),
                Text(address,
                    style: TextStyle(color: Colors.white, fontSize: 15)),
                SizedBox(
                  height: 18,
                ),
                Text('Description',
                    style:
                        TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                SizedBox(height: 5),
                Text(description.isNotEmpty ? description : "//",
                    style: TextStyle(color: Colors.white, fontSize: 15)),
                SizedBox(
                  height: 18,
                ),
                Text('Sender',
                    style:
                        TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                SizedBox(height: 5),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () async {
                        final profileId = widget.details['mittente'];
                        final profileDetails =
                            await userProvider.getProfileDetails(profileId);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                Contact(profile: profileDetails!),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Icon(
                          Icons.info_outline,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                    Text(sender,
                        style: TextStyle(color: Colors.white, fontSize: 15)),
                  ],
                ),
                SizedBox(
                  height: 18,
                ),
                Center(
                  child: Text('Feedback',
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                ),
                SizedBox(height: 5),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Text(
                      textAlign: TextAlign.center,
                      'Tap one icon to increment or decrement feedback\'s marker',
                      style: TextStyle(color: Colors.white, fontSize: 15)),
                ),
                SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        if (!await voteMethods.existsVote(
                            user!.uid, widget.details['id'])) {
                          VoteMethods()
                              .addVote(user.uid, widget.details['id'], 0);
                          int positiveFeedback =
                              widget.details['positiveFeedback'] + 1;
                          googleMapsMethods.updateMarkerFeedback(
                              widget.details['id'], positiveFeedback, 0);
                          setState(() {
                            alertFeedback = true;
                            stringFeedback = 'Positive Feedback Added!';
                          });
                          Navigator.pop(context);
                        } else {
                          setState(() {
                            alertFeedback = true;
                            stringFeedback = 'You already Voted!';
                          });
                          Timer(Duration(seconds: 2), () {
                            setState(() {
                              alertFeedback = false;
                            });
                          });
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Column(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: Colors.green, width: 2),
                              ),
                              padding: const EdgeInsets.all(8),
                              child: whatVote == 0 && whatVote != -1
                                  ? Icon(
                                      Icons.thumb_up,
                                      color: Colors.green,
                                      size: 25,
                                    )
                                  : Icon(
                                      Icons.thumb_up_outlined,
                                      color: Colors.green,
                                      size: 25,
                                    ),
                            ),
                            SizedBox(
                              height: 8,
                            ),
                            Text('$positiveFeedback votes')
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        if (!await voteMethods.existsVote(
                            user!.uid, widget.details['id'])) {
                          VoteMethods()
                              .addVote(user.uid, widget.details['id'], 1);
                          int negativeFeedback =
                              widget.details['negativeFeedback'] + 1;
                          googleMapsMethods.updateMarkerFeedback(
                              widget.details['id'], negativeFeedback, 1);
                          setState(() {
                            alertFeedback = true;
                            stringFeedback = 'Negative Feedback Added!';
                          });
                          Navigator.pop(context);
                        } else {
                          setState(() {
                            alertFeedback = true;
                            stringFeedback = 'You already Voted!';
                          });
                          Timer(Duration(seconds: 2), () {
                            setState(() {
                              alertFeedback = false;
                            });
                          });
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Column(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.red, width: 2),
                              ),
                              padding: const EdgeInsets.all(8),
                              child: whatVote == 1 && whatVote != -1
                                  ? Icon(
                                      Icons.thumb_down,
                                      color: Colors.red,
                                      size: 25,
                                    )
                                  : Icon(
                                      Icons.thumb_down_outlined,
                                      color: Colors.red,
                                      size: 25,
                                    ),
                            ),
                            SizedBox(
                              height: 8,
                            ),
                            Text('${widget.details['negativeFeedback']} votes')
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 18,
                ),
                if (alertFeedback)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                        child: Text(
                      stringFeedback,
                      style: TextStyle(fontSize: 22, color: Colors.white),
                    )),
                  ),
                if (whatVote != -1)
                  Center(
                    child: InkWell(
                      onTap: () {
                        voteMethods.deleteVote(user!.uid, widget.details['id']);
                        if (whatVote == 0) {
                          int positiveFeedback =
                              widget.details['positiveFeedback'] - 1;
                          googleMapsMethods.updateMarkerFeedback(
                              widget.details['id'], positiveFeedback, 0);
                        } else if (whatVote == 1) {
                          int negativeFeedback =
                              widget.details['negativeFeedback'] - 1;
                          googleMapsMethods.updateMarkerFeedback(
                              widget.details['id'], negativeFeedback, 1);
                        }
                        Navigator.pop(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.blue, width: 2),
                            borderRadius: BorderRadius.circular(8)),
                        child: const Text('Delete Vote'),
                      ),
                    ),
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

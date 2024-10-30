import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:custom_info_window/custom_info_window.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:travel_app/Controllers/GoogleMapsMethods.dart';
import 'package:travel_app/Controllers/UserProvider.dart';
import 'package:travel_app/Views/Contact.dart';
import 'package:travel_app/Views/DescriptionScreen.dart';

class DetailsPolyline extends StatefulWidget {
  final Map<String, dynamic> details;

  const DetailsPolyline({
    Key? key,
    required this.details,
  }) : super(key: key);

  @override
  State<DetailsPolyline> createState() => _DetailsPolylineState();
}

class _DetailsPolylineState extends State<DetailsPolyline> {
  late GoogleMapsMethods googleMapsMethods;
  Timestamp lastDayTimestamp = Timestamp(0, 0);
  DateTime lastDay = DateTime.now();
  Timestamp firstDayTimestamp = Timestamp(0, 0);
  DateTime firstDay = DateTime.now();
  late UserProvider userProvider;
  String sender = '';
  IconData modeIcon = Icons.mode_standby;

  @override
  void initState() {
    super.initState();
    googleMapsMethods =
        GoogleMapsMethods(setState, CustomInfoWindowController());
    lastDayTimestamp = widget.details['lastDay'];
    lastDay = lastDayTimestamp.toDate();
    firstDayTimestamp = widget.details['firstDay'];
    firstDay = firstDayTimestamp.toDate();
    userProvider = UserProvider();
    loadSender();

    switch (widget.details['mode']) {
      case 'Foot':
        modeIcon = Icons.hiking;
      case 'Cycle':
        modeIcon = Icons.directions_bike;
      case 'Car':
        modeIcon = Icons.directions_car;
      case 'Moto':
        modeIcon = Icons.motorcycle;
      case 'Hybrid':
        modeIcon = Icons.mode_standby;
    }
  }

  Future<void> loadSender() async {
    String fetchedSender =
        (await userProvider.getUsernameById(widget.details['mittente']))!;
    setState(() {
      sender = fetchedSender;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Itinerary: ${widget.details['title']}',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DescriptionScreen(
                      description: widget.details['title']!,
                    ),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.blue),
                    borderRadius: BorderRadius.circular(8)),
                child: Row(
                  children: [
                    Text(
                      'Title: ',
                      style: TextStyle(fontSize: 22),
                    ),
                    Text(
                      widget.details['title'],
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                    ),
                    Spacer(),
                    Icon(modeIcon),
                    SizedBox(
                      width: 2,
                    ),
                  ],
                ),
              ),
            ),
            Divider(
              height: 18,
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue),
                  borderRadius: BorderRadius.circular(8)),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DescriptionScreen(
                        description: widget.details['description']!,
                      ),
                    ),
                  );
                },
                child: Row(
                  children: [
                    Text(
                      'Description: ',
                      style: TextStyle(fontSize: 22),
                    ),
                    Expanded(
                      child: Text(
                        widget.details['description'],
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 22),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Divider(
              height: 18,
            ),
            SizedBox(
              height: 18,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.blue),
                      borderRadius: BorderRadius.circular(8)),
                  child: Column(
                    children: [
                      Text(
                        'First day',
                        style: TextStyle(fontSize: 18),
                      ),
                      Text(
                        DateFormat('dd/MM/yyyy').format(firstDay),
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      )
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.blue),
                      borderRadius: BorderRadius.circular(8)),
                  child: Column(
                    children: [
                      Text(
                        'Last day',
                        style: TextStyle(fontSize: 18),
                      ),
                      Text(DateFormat('dd/MM/yyyy').format(lastDay),
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18))
                    ],
                  ),
                )
              ],
            ),
            Divider(
              height: 38,
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue),
                  borderRadius: BorderRadius.circular(8)),
              child: Row(
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
                  Text(
                    'Sender: ',
                    style: TextStyle(fontSize: 22),
                  ),
                  Text(
                    sender,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                  ),
                  Spacer(),
                  InkWell(
                    onTap: () {},
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.green),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text('Contact'),
                    ),
                  ),
                  SizedBox(
                    width: 8,
                  ),
                ],
              ),
            ),
            Divider(
              height: 38,
            ),
            Text(
              'Travel Stops',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: widget.details['addresses'].length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: Icon(Icons.power_input),
                    title: Text(widget.details['addresses'][index]),
                  );
                },
              ),
            ),
            SizedBox(
              height: 38,
            ),
          ],
        ),
      ),
    );
  }
}

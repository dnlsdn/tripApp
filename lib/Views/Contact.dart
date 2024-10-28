import 'package:cupertino_modal_sheet/cupertino_modal_sheet.dart';
import 'package:flutter/material.dart';
import 'package:travel_app/Controllers/GeneralMethods.dart';
import 'package:travel_app/Utils/FullScreenImage.dart';
import 'package:travel_app/Views/ReportUser.dart';

class Contact extends StatefulWidget {
  final Map<String, dynamic> profile;
  const Contact({super.key, required this.profile});

  @override
  State<Contact> createState() => _ContactState();
}

class _ContactState extends State<Contact> {
  String image = '';
  GeneralMethods generalMethods = GeneralMethods();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    image = widget.profile['photoUrl'];
  }

  @override
  Widget build(BuildContext context) {
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
                "Name: Daniel",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              Divider(
                height: 18,
              ),
              Text(
                "Nation: Italy",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              Divider(
                height: 18,
              ),
              Text(
                "N° Travels: 18",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  InkWell(
                    onTap: () {},
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
            ],
          ),
        ),
      ),
    );
  }
}

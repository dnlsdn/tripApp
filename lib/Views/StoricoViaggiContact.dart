import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:custom_info_window/custom_info_window.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:travel_app/Controllers/GoogleMapsMethods.dart';
import 'package:travel_app/Views/DetailsPolyline.dart';

class StoricoViaggiContact extends StatefulWidget {
  final Map<String, dynamic> profile;
  const StoricoViaggiContact({super.key, required this.profile});

  @override
  State<StoricoViaggiContact> createState() => _StoricoViaggiContactState();
}

class _StoricoViaggiContactState extends State<StoricoViaggiContact> {
  late GoogleMapsMethods googleMapsMethods;
  List<Map<String, dynamic>> allPolylines = [];

  @override
  void initState() {
    super.initState();

    googleMapsMethods =
        GoogleMapsMethods(setState, CustomInfoWindowController());
    _fetchPolylines();
  }

  Future<void> _fetchPolylines() async {
    try {
      List<Map<String, dynamic>> polylines =
          await googleMapsMethods.getPolylinesAsList(widget.profile['uid']);
      setState(() {
        allPolylines = polylines;
      });
    } catch (e) {
      print('Errore durante il recupero delle polylines: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
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
                    widget.profile['username'] + '\'s Travels',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 27,
                        color: Colors.white),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              SizedBox(
                height: 18,
              ),
              Expanded(
                child: allPolylines.isEmpty
                    ? Center(child: Text('No Itineraries Found'))
                    : ListView.builder(
                        itemCount: allPolylines.length,
                        itemBuilder: (context, index) {
                          final polyline = allPolylines[index];
                          final title = polyline['title'] ?? 'err';

                          Timestamp timestampFirstDay = polyline['firstDay'];
                          DateTime firstDay = timestampFirstDay.toDate();
                          Timestamp timestampLastDay = polyline['lastDay'];
                          DateTime lastDay = timestampLastDay.toDate();

                          return ListTile(
                            title: Text(
                              title,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  polyline['description'] ?? 'err',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(
                                  height: 8,
                                ),
                                Row(
                                  children: [
                                    Text(
                                        'Start Day\n${DateFormat('dd/MM/yyyy').format(firstDay)}'),
                                    Spacer(),
                                    Text(
                                        'Last Day\n${DateFormat('dd/MM/yyyy').format(lastDay)}'),
                                  ],
                                ),
                                Divider(),
                              ],
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      DetailsPolyline(details: polyline),
                                ),
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

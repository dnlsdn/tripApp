import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:custom_info_window/custom_info_window.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:travel_app/Controllers/GoogleMapsMethods.dart';
import 'package:travel_app/Views/DetailsPolyline.dart';

class StoricoViaggi extends StatefulWidget {
  const StoricoViaggi({super.key});

  @override
  State<StoricoViaggi> createState() => _StoricoViaggiState();
}

class _StoricoViaggiState extends State<StoricoViaggi> {
  late GoogleMapsMethods googleMapsMethods;
  final TextEditingController controller = TextEditingController();
  List<Map<String, dynamic>> allPolylines = [];
  List<Map<String, dynamic>> filteredPolylines = [];

  @override
  void initState() {
    super.initState();
    googleMapsMethods =
        GoogleMapsMethods(setState, CustomInfoWindowController());
    _fetchPolylines();
    controller.addListener(_filterPolylines);
  }

  @override
  void dispose() {
    controller.removeListener(_filterPolylines);
    controller.dispose();
    super.dispose();
  }

  Future<void> _fetchPolylines() async {
    try {
      List<Map<String, dynamic>> polylines =
          await googleMapsMethods.getPolylinesAsList();
      setState(() {
        allPolylines = polylines;
        filteredPolylines = polylines;
      });
    } catch (e) {
      print('Errore durante il recupero delle polylines: $e');
    }
  }

  void _filterPolylines() {
    String query = controller.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        filteredPolylines = allPolylines;
      } else {
        filteredPolylines = allPolylines
            .where((polyline) => (polyline['title'] ?? 'Percorso senza titolo')
                .toLowerCase()
                .contains(query))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Travels',
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
                                onPressed: () {
                                  controller.clear();
                                  setState(() {
                                    filteredPolylines = allPolylines;
                                  });
                                },
                              )
                            : null,
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                ],
              ),
              SizedBox(height: 10),
              Expanded(
                child: filteredPolylines.isEmpty
                    ? Center(child: Text('No Itineraries Found'))
                    : ListView.builder(
                        itemCount: filteredPolylines.length,
                        itemBuilder: (context, index) {
                          final polyline = filteredPolylines[index];
                          final title =
                              polyline['title'] ?? 'err';

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
                                  polyline['description'] ??
                                      'err',
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

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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchPolylines();
  }

  Future<void> _fetchPolylines() async {
    try {
      List<Map<String, dynamic>> polylines =
          await googleMapsMethods.getPolylinesAsList(null);
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
                    'Travels',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 27,
                        color: Colors.white),
                  ),
                ],
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
                          final title = polyline['title'] ?? 'err';

                          Timestamp timestampFirstDay = polyline['firstDay'];
                          DateTime firstDay = timestampFirstDay.toDate();
                          Timestamp timestampLastDay = polyline['lastDay'];
                          DateTime lastDay = timestampLastDay.toDate();

                          return ListTile(
                            contentPadding: EdgeInsets
                                .zero, // Rimuove il padding esterno del ListTile
                            title: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    Icons.delete_forever_outlined,
                                    color: Colors.red,
                                  ),
                                  onPressed: () async {
                                    final String idToDelete = polyline[
                                        'id']; // Questo è il valore del campo 'id'

                                    try {
                                      // Cerca il documento in Firestore con il campo 'id' corrispondente
                                      QuerySnapshot querySnapshot =
                                          await FirebaseFirestore.instance
                                              .collection('polylines')
                                              .where('id',
                                                  isEqualTo: idToDelete)
                                              .get();

                                      if (querySnapshot.docs.isNotEmpty) {
                                        // Ottieni l'ID del documento Firestore
                                        String documentId =
                                            querySnapshot.docs.first.id;

                                        // Elimina il documento
                                        await FirebaseFirestore.instance
                                            .collection('polylines')
                                            .doc(documentId)
                                            .delete();

                                        // Aggiorna la lista locale
                                        setState(() {
                                          filteredPolylines.removeWhere(
                                              (p) => p['id'] == idToDelete);
                                          allPolylines.removeWhere(
                                              (p) => p['id'] == idToDelete);
                                        });

                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                              content: Text(
                                                  'Itinerary deleted successfully')),
                                        );
                                      } else {
                                        // Documento non trovato
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                              content: Text(
                                                  'No matching document found')),
                                        );
                                      }
                                    } catch (e) {
                                      // Gestione degli errori
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content: Text(
                                                'Failed to delete itinerary: $e')),
                                      );
                                    }
                                  },
                                  constraints: BoxConstraints(
                                    minWidth: 18,
                                    minHeight: 18,
                                  ),
                                  padding: EdgeInsets
                                      .zero, // Rimuove padding interno del pulsante
                                ),
                                SizedBox(width: 8), // Spazio tra icona e testo
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        title,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        polyline['description'] ?? 'err',
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(height: 8),
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
                                ),
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

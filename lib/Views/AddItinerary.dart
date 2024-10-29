import 'dart:async';

import 'package:custom_info_window/custom_info_window.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:travel_app/Controllers/GoogleMapsMethods.dart';

class AddItinerary extends StatefulWidget {
  const AddItinerary({super.key});

  @override
  State<AddItinerary> createState() => _AddItineraryState();
}

class _AddItineraryState extends State<AddItinerary> {
  DateTime? startDate;
  DateTime? endDate;
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  bool alertEmpty = false;
  TextEditingController locationController = TextEditingController();
  int currentDay = 0;
  late GoogleMapsMethods googleMapsMethods;
  bool showPlacesList = false;
  String address = "";
  List<LatLng> stops = [];

  @override
  void initState() {
    super.initState();
    googleMapsMethods =
        GoogleMapsMethods(setState, CustomInfoWindowController());
    locationController.addListener(() {
      googleMapsMethods.onChange(locationController);
      setState(() {
        showPlacesList = locationController.text.isNotEmpty;
      });
    });
  }

  Future<void> selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: startDate ??
          DateTime.now(), // Usa la data corrente se startDate è null
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: Colors.white, // Colore dell'intestazione
              onPrimary: Colors.black, // Colore del testo dell'intestazione
              onSurface: Colors.white, // Colore del testo dei giorni
            ),
            //dialogBackgroundColor: Colors.green, // Colore dello sfondo
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != startDate) {
      setState(() {
        startDate = picked;
      });
    }
  }

  Future<void> selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          endDate ?? DateTime.now(), // Usa la data corrente se startDate è null
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: Colors.white, // Colore dell'intestazione
              onPrimary: Colors.black, // Colore del testo dell'intestazione
              onSurface: Colors.white, // Colore del testo dei giorni
            ),
            //dialogBackgroundColor: Colors.green, // Colore dello sfondo
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != endDate) {
      setState(() {
        endDate = picked;
      });
    }
  }

// Aggiungi un metodo per calcolare il numero di giorni
  int getDaysBetween() {
    if (startDate != null && endDate != null) {
      return endDate!.difference(startDate!).inDays +
          1; // +1 per includere il giorno finale
    }
    return 0;
  }

  void navigateToDay(int dayIndex) {
    if (startDate != null && endDate != null) {
      DateTime selectedDate = startDate!.add(Duration(days: dayIndex));
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DayScreen(
            date: selectedDate,
            onNext: () {
              setState(() {
                if (currentDay < getDaysBetween() - 1) {
                  currentDay++;
                }
                // Naviga alla schermata del giorno successivo
                navigateToDay(currentDay);
              });
            },
            isLastDay: dayIndex ==
                getDaysBetween() - 1, // Verifica se è l'ultimo giorno
            stops: stops,
            title: titleController.text,
            description: descriptionController.text,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Row(
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
                          const Text(
                            'Add Itinerary',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 27,
                                color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 18,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            Text(
                              'Start Date',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            SizedBox(
                              height: 8,
                            ),
                            InkWell(
                              onTap: () {
                                selectStartDate(context);
                              },
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.blue),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: startDate == null
                                    ? Text('Select Date')
                                    : Text(DateFormat('dd/MM/yyyy')
                                        .format(startDate!)),
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Text(
                              'End Date',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            SizedBox(
                              height: 8,
                            ),
                            InkWell(
                              onTap: () {
                                selectEndDate(context);
                              },
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.blue),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: endDate == null
                                    ? Text('Select Date')
                                    : Text(DateFormat('dd/MM/yyyy')
                                        .format(endDate!)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 18,
                    ),
                    Text('Initial Location',
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text(
                      address == "" ? '//' : address,
                      style: TextStyle(fontSize: 18),
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: locationController,
                      cursorColor: Colors.white,
                      decoration: InputDecoration(
                        labelText: 'Search Location',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0)),
                        labelStyle: TextStyle(color: Colors.white),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.blue, width: 2.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.grey, width: 1.0),
                        ),
                      ),
                    ),
                    if (showPlacesList)
                      SizedBox(
                        height: 8,
                      ),
                    if (showPlacesList)
                      Container(
                        height:
                            380, // Imposta un'altezza fissa o usa Expanded se necessario
                        child: ListView.builder(
                          itemCount: googleMapsMethods.placesList.length,
                          itemBuilder: (context, index) {
                            return Container(
                              margin: EdgeInsets.symmetric(
                                  vertical: 4, horizontal: 8),
                              decoration: BoxDecoration(
                                border:
                                    Border.all(color: Colors.blue, width: 2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: ListTile(
                                onTap: () async {
                                  setState(() {
                                    showPlacesList = false;
                                    locationController.text = googleMapsMethods
                                        .placesList[index]['description'];
                                  });
                                  Map<String, dynamic> latLng =
                                      await googleMapsMethods
                                          .getLatLngFromAddress(
                                              googleMapsMethods
                                                      .placesList[index]
                                                  ['description']);
                                  address = googleMapsMethods.placesList[index]
                                      ['description'];
                                  setState(() {
                                    showPlacesList = false;
                                    locationController.text = "";
                                    FocusScope.of(context).unfocus();
                                  });
                                },
                                title: Text(googleMapsMethods.placesList[index]
                                        ['description'] ??
                                    'No title available'),
                              ),
                            );
                          },
                        ),
                      ),
                    SizedBox(
                      height: 18,
                    ),
                    if (!showPlacesList)
                      Text('Title',
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    if (!showPlacesList)
                      TextField(
                        controller: titleController,
                        cursorColor: Colors.white,
                        decoration: InputDecoration(
                          labelText: 'Itinerary Title',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0)),
                          labelStyle: TextStyle(color: Colors.white),
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.blue, width: 2.0),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.grey, width: 1.0),
                          ),
                        ),
                      ),
                    SizedBox(
                      height: 18,
                    ),
                    if (!showPlacesList)
                      Text('Description',
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold)),
                    SizedBox(
                      height: 8,
                    ),
                    if (!showPlacesList)
                      TextField(
                        controller: descriptionController,
                        cursorColor: Colors.white,
                        decoration: InputDecoration(
                          labelText: 'Itinerary Description',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0)),
                          labelStyle: TextStyle(color: Colors.white),
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.blue, width: 2.0),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.grey, width: 1.0),
                          ),
                        ),
                      ),
                    if (alertEmpty)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(
                            child: Text(
                          'Fill all field to continue!',
                          style: TextStyle(fontSize: 22, color: Colors.red),
                        )),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonAnimator: FloatingActionButtonAnimator.noAnimation,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: isKeyboardVisible
          ? null
          : InkWell(
              onTap: isKeyboardVisible
                  ? null
                  : () async {
                      if (titleController.text != "" &&
                          descriptionController.text != "" &&
                          startDate != null &&
                          endDate != null &&
                          address != "") {
                        Map<String, dynamic> addressLatLng =
                            await googleMapsMethods
                                .getLatLngFromAddress(address);
                        stops.add(
                            LatLng(addressLatLng['lat'], addressLatLng['lng']));
                        navigateToDay(currentDay);
                      } else {
                        print('no');
                        setState(() {
                          alertEmpty = true;
                        });
                        Timer(Duration(seconds: 5), () {
                          setState(() {
                            alertEmpty = false;
                          });
                        });
                      }
                    },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: titleController.text != "" &&
                            descriptionController.text != "" &&
                            startDate != null &&
                            endDate != null &&
                            address != ""
                        ? Colors.blue
                        : Colors.white.withOpacity(0.7),
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Continue',
                  style: TextStyle(
                      fontSize: 22,
                      color: titleController.text != "" &&
                              descriptionController.text != "" &&
                              startDate != null &&
                              endDate != null &&
                              address != ""
                          ? Colors.white
                          : Colors.white.withOpacity(0.7),
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
    );
  }
}

// Pagina per visualizzare le informazioni relative al giorno selezionato
class DayScreen extends StatefulWidget {
  final DateTime date;
  final VoidCallback onNext; // Callback per la navigazione al giorno successivo
  final bool isLastDay; // Indica se è l'ultimo giorno
  final List<LatLng> stops;
  final String title;
  final String description;

  const DayScreen({
    required this.date,
    required this.onNext,
    Key? key,
    required this.isLastDay,
    required this.stops,
    required this.title,
    required this.description,
  }) : super(key: key);

  @override
  State<DayScreen> createState() => _DayScreenState();
}

class _DayScreenState extends State<DayScreen> {
  String address = "";
  late GoogleMapsMethods googleMapsMethods;
  bool showPlacesList = false;
  TextEditingController locationController = TextEditingController();
  bool alertEmpty = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    googleMapsMethods =
        GoogleMapsMethods(setState, CustomInfoWindowController());
    locationController.addListener(() {
      googleMapsMethods.onChange(locationController);
      setState(() {
        showPlacesList = locationController.text.isNotEmpty;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text('Travel Day: ' + DateFormat('dd/MM/yyyy').format(widget.date)),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 18,
            ),
            Text('Destination Place',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text(
              address == "" ? '//' : address,
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 8),
            TextField(
              controller: locationController,
              cursorColor: Colors.white,
              decoration: InputDecoration(
                labelText: 'Search Location',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0)),
                labelStyle: TextStyle(color: Colors.white),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue, width: 2.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey, width: 1.0),
                ),
              ),
            ),
            if (showPlacesList)
              SizedBox(
                height: 8,
              ),
            if (showPlacesList)
              Container(
                height:
                    380, // Imposta un'altezza fissa o usa Expanded se necessario
                child: ListView.builder(
                  itemCount: googleMapsMethods.placesList.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.blue, width: 2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ListTile(
                        onTap: () async {
                          setState(() {
                            showPlacesList = false;
                            locationController.text = googleMapsMethods
                                .placesList[index]['description'];
                          });
                          Map<String, dynamic> latLng =
                              await googleMapsMethods.getLatLngFromAddress(
                                  googleMapsMethods.placesList[index]
                                      ['description']);
                          address = googleMapsMethods.placesList[index]
                              ['description'];
                          setState(() {
                            showPlacesList = false;
                            locationController.text = "";
                            FocusScope.of(context).unfocus();
                          });
                        },
                        title: Text(googleMapsMethods.placesList[index]
                                ['description'] ??
                            'No title available'),
                      ),
                    );
                  },
                ),
              ),
            if (alertEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                    child: Text(
                  'Fill all field to save your Itinerary!',
                  style: TextStyle(fontSize: 22, color: Colors.red),
                )),
              ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: InkWell(
        onTap: () async {
          if (address != "") {
            Map<String, dynamic> addressLatLng =
                await googleMapsMethods.getLatLngFromAddress(address);
            widget.stops
                .add(LatLng(addressLatLng['lat'], addressLatLng['lng']));
            if (widget.isLastDay) {
              // Se è l'ultimo giorno, torna alla schermata principale
              print(widget.stops);
              googleMapsMethods.addPolylineToFirestore(
                  widget.stops, widget.title, widget.description);
              Navigator.popUntil(context, (route) => route.isFirst);
            } else {
              widget.onNext(); // Altrimenti vai al giorno successivo
            }
          } else {
            setState(() {
              alertEmpty = true;
            });
            Timer(Duration(seconds: 5), () {
              setState(() {
                alertEmpty = false;
              });
            });
          }
        },
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border.all(
              color:
                  address != "" ? Colors.blue : Colors.white.withOpacity(0.7),
              width: 2,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            widget.isLastDay ? 'Save' : 'Next Day',
            style: TextStyle(
                fontSize: 22,
                color: address != ""
                    ? Colors.white
                    : Colors.white.withOpacity(0.7),
                fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}

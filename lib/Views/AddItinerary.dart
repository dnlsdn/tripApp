import 'dart:async';
import 'dart:io';

import 'package:custom_info_window/custom_info_window.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:travel_app/Controllers/GPXMethods.dart';
import 'package:travel_app/Controllers/GoogleMapsMethods.dart';
import 'package:travel_app/Views/LeftMenu.dart';

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
  List<String> addresses = [];
  String mode = "cycle";
  IconData modeIcon = Icons.mode_standby;
  bool isGPX = false;
  GPXMethods gpxMethods = GPXMethods();
  List<LatLng> gpxPoints = [];
  String gpxFileName = "";

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
      initialDate: startDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: Colors.white,
              onPrimary: Colors.black,
              onSurface: Colors.white,
            ),
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
      initialDate: endDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: Colors.white,
              onPrimary: Colors.black,
              onSurface: Colors.white,
            ),
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

  int getDaysBetween() {
    if (startDate != null && endDate != null) {
      return endDate!.difference(startDate!).inDays + 1;
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
                navigateToDay(currentDay);
              });
            },
            isLastDay: dayIndex == getDaysBetween() - 1,
            stops: stops,
            title: titleController.text,
            description: descriptionController.text,
            addresses: addresses,
            lastDay: endDate!,
            firstDay: startDate!,
            mode: mode,
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
                    InkWell(
                      highlightColor: Colors.transparent,
                      splashColor: Colors.transparent,
                      onTap: () {
                        setState(() {
                          isGPX = !isGPX;
                        });
                      },
                      child: Center(
                        child: Text(
                          !isGPX
                              ? 'Click here if you want to upload a GPX file!'
                              : 'Click here if you want to upload a Classic Itinerary!',
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 18,
                    ),
                    if (!isGPX) ...[
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
                          height: 380,
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
                                      locationController.text =
                                          googleMapsMethods.placesList[index]
                                              ['description'];
                                    });
                                    Map<String, dynamic> latLng =
                                        await googleMapsMethods
                                            .getLatLngFromAddress(
                                                googleMapsMethods
                                                        .placesList[index]
                                                    ['description']);
                                    address = googleMapsMethods
                                        .placesList[index]['description'];
                                    setState(() {
                                      showPlacesList = false;
                                      locationController.text = "";
                                      FocusScope.of(context).unfocus();
                                    });
                                  },
                                  title: Text(googleMapsMethods
                                          .placesList[index]['description'] ??
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
                    ] else if (isGPX) ...[
                      //SizedBox(height: 18),
                      Center(
                        child: InkWell(
                          onTap: () async {
                            File? gpxFile = await gpxMethods.pickGPXFile();
                            if (gpxFile != null) {
                              gpxPoints =
                                  await gpxMethods.parseGPXFile(gpxFile);
                              setState(() {
                                gpxFileName = gpxFile.path.split('/').last;
                              });
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.blue),
                                borderRadius: BorderRadius.circular(8)),
                            child: Text(gpxFileName.isEmpty
                                ? 'Upload GPX File'
                                : gpxFileName),
                          ),
                        ),
                      ),
                      //SizedBox(height: 18),
                      if (gpxPoints.isNotEmpty)
                        Center(
                          child: Text(
                            'GPX File Loaded with ${gpxPoints.length} points.',
                            style: TextStyle(color: Colors.green),
                          ),
                        ),
                      SizedBox(height: 18),
                      // Title
                      Text('Title',
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
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
                      SizedBox(height: 18),
                      // Description
                      Text('Description',
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
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
                    ],
                    if (alertEmpty)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(
                            child: Text(
                          'Fill all field to continue!',
                          style: TextStyle(fontSize: 22, color: Colors.red),
                        )),
                      ),
                    SizedBox(
                      height: 68,
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
                      if (isGPX) {
                        if (gpxPoints.isNotEmpty &&
                            titleController.text.isNotEmpty &&
                            descriptionController.text.isNotEmpty &&
                            startDate != null &&
                            endDate != null) {
                          // Save GPX data to Firestore
                          googleMapsMethods.addGPXToFirestore(
                            gpxPoints,
                            titleController.text,
                            descriptionController.text,
                            startDate!,
                            endDate!,
                          );
                          Navigator.pop(context);
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
                      } else {
                        // Existing code for non-GPX itineraries
                        if (titleController.text != "" &&
                            descriptionController.text != "" &&
                            startDate != null &&
                            endDate != null &&
                            address != "" &&
                            mode != "") {
                          Map<String, dynamic> addressLatLng =
                              await googleMapsMethods
                                  .getLatLngFromAddress(address);
                          stops.add(LatLng(
                              addressLatLng['lat'], addressLatLng['lng']));
                          addresses.add(address);
                          navigateToDay(currentDay);
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
                      }
                    },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: (isGPX
                        ? (gpxPoints.isNotEmpty &&
                                titleController.text.isNotEmpty &&
                                descriptionController.text.isNotEmpty &&
                                startDate != null &&
                                endDate != null)
                            ? Colors.blue
                            : Colors.white.withOpacity(0.7)
                        : (titleController.text != "" &&
                                descriptionController.text != "" &&
                                startDate != null &&
                                endDate != null &&
                                address != "" &&
                                mode != "")
                            ? Colors.blue
                            : Colors.white.withOpacity(0.7)),
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Continue',
                  style: TextStyle(
                      fontSize: 22,
                      color: (isGPX
                          ? (gpxPoints.isNotEmpty &&
                                  titleController.text.isNotEmpty &&
                                  descriptionController.text.isNotEmpty &&
                                  startDate != null &&
                                  endDate != null)
                              ? Colors.white
                              : Colors.white.withOpacity(0.7)
                          : (titleController.text != "" &&
                                  descriptionController.text != "" &&
                                  startDate != null &&
                                  endDate != null &&
                                  address != "" &&
                                  mode != "")
                              ? Colors.white
                              : Colors.white.withOpacity(0.7)),
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
    );
  }
}

class DayScreen extends StatefulWidget {
  final DateTime date;
  final VoidCallback onNext;
  final bool isLastDay;
  final List<LatLng> stops;
  final String title;
  final String description;
  final List<String> addresses;
  final DateTime lastDay;
  final DateTime firstDay;
  final String mode;

  const DayScreen({
    required this.date,
    required this.onNext,
    Key? key,
    required this.isLastDay,
    required this.stops,
    required this.title,
    required this.description,
    required this.addresses,
    required this.lastDay,
    required this.firstDay,
    required this.mode,
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
        leading: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.blue, width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: IconButton(
            highlightColor: Colors.transparent,
            onPressed: () =>
                Navigator.popUntil(context, (route) => route.isFirst),
            icon: const Icon(Icons.arrow_back_ios_new,
                color: Colors.white, size: 22),
          ),
        ),
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
                height: 380,
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
            widget.addresses.add(address);
            if (widget.isLastDay) {
              print(widget.stops);
              googleMapsMethods.addPolylineToFirestore(
                  widget.stops,
                  widget.title,
                  widget.description,
                  widget.addresses,
                  widget.lastDay,
                  widget.firstDay,
                  widget.mode);
              Navigator.popUntil(context, (route) => route.isFirst);
            } else {
              widget.onNext();
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

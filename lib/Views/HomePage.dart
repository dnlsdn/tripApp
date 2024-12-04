import 'dart:async';

import 'package:custom_info_window/custom_info_window.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:travel_app/Controllers/GoogleMapsMethods.dart';
import 'package:travel_app/Controllers/UserProvider.dart';
import 'package:travel_app/Views/AddItinerary.dart';
import 'package:travel_app/Views/AddMarker.dart';
import 'package:travel_app/Views/LeftMenu.dart';
import 'package:travel_app/Views/DetailsPolyline.dart';
import 'package:travel_app/Views/Profile.dart';
import 'package:travel_app/Views/RIghtMenu.dart';
import 'package:travel_app/Views/SignUpLogIn.dart';
import 'package:travel_app/models/Utente.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  Completer<GoogleMapController> controller = Completer();
  GoogleMapController? mapController;
  TextEditingController searchController = TextEditingController();
  CustomInfoWindowController customInfoWindowController =
      CustomInfoWindowController();
  LatLng currentPosition =
      LatLng(37.77483, -122.41942); // San Francisco defaults
  Set<Marker> markers = {};
  final List<Map<String, dynamic>> locations = [
    // Example locations
    {
      // 'id': '2',
      // //'position': LatLng(41.72826377255149, 12.280872577482349),
      // 'latitude': '41.72826377255149',
      // 'longitude': '12.280872577482349',
      // 'title': 'Warning',
      // 'iconImage': 'warning',
    },
  ];

  late GoogleMapsMethods googleMapsMethods;
  bool showPlacesList = false;
  bool loading = false;
  double rotationAngle = 0;
  MapType mapType = MapType.normal;
  List<String> excludeMarker = [];
  Set<Polyline> polylines = {}; // Set di polilinee per la mappa
  bool showPolylineDetails = false;
  Polyline? selectedPolylineDetails;
  Map<String, Map<String, dynamic>> polylineDetails = {};
  List<String> excludeItinerary = [];

  @override
  void initState() {
    super.initState();
    googleMapsMethods = GoogleMapsMethods(setState, customInfoWindowController);
    //_loadMarkers();
    //googleMapsMethods.getCurrentLocation(currentPosition, mapController!);
    googleMapsMethods.loadDataTapMarker(
        markers, locations, context, null, excludeMarker);
    searchController.addListener(() {
      googleMapsMethods.onChange(searchController);
      setState(() {
        showPlacesList = searchController.text.isNotEmpty;
      });
    });
    googleMapsMethods.loadPolylinesFromFirestore(
        polylines, markers, context, excludeItinerary);
  }

  // Future<void> _loadMarkers() async {
  //   await googleMapsMethods.loadCustomMarkers(markers, locations);
  // }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (userProvider.getUser == null ||
          userProvider.getUser?.username == "") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const SignUpLogIn(),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    customInfoWindowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Utente? user = Provider.of<UserProvider>(context).getUser;

    return Scaffold(
      key: scaffoldKey,
      drawer: const LeftMenu(),
      endDrawer: RightMenu(
        mapType: mapType,
        onMapTypeChanged: (newMapType) {
          setState(() {
            mapType = newMapType;
          });
        },
        excludeMarker: excludeMarker,
        onExcludeMarkerChanged: (newExcludeMarker) {
          setState(() {
            excludeMarker = newExcludeMarker;
            googleMapsMethods.loadDataTapMarker(
                markers, locations, context, null, excludeMarker);
          });
        },
        excludeItinerary: excludeItinerary,
        onExcludeItineraryChanged: (newExcludeItinerary) {
          setState(() {
            excludeMarker = newExcludeItinerary;
            googleMapsMethods.loadPolylinesFromFirestore(
                polylines, markers, context, excludeItinerary);
          });
        },
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      'Hi ${user != null ? user.username : 'Guest'}',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                          overflow: TextOverflow.ellipsis,
                          color: Colors.white),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              user != null ? Profile() : const SignUpLogIn(),
                        ),
                      ),
                      icon: user != null
                          ? Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: Colors.blue, width: 2),
                              ),
                              child: ClipOval(
                                child: Image.network(
                                  user.photoUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(Icons.person);
                                  },
                                ),
                              ),
                            )
                          : const Icon(Icons.person),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(8, 8, 16, 0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: searchController,
                      cursorColor: Colors.white,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Search location...',
                        prefixIcon: Icon(Icons.search),
                        suffixIcon: searchController.text.isNotEmpty
                            ? IconButton(
                                icon: Icon(Icons.clear),
                                onPressed: () {
                                  searchController.clear();
                                },
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue),
                            borderRadius: BorderRadius.circular(18)),
                        filled: true,
                        fillColor: Colors.white10,
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.8),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white)),
                    child: IconButton(
                      highlightColor: Colors.transparent,
                      icon: Icon(
                        Icons.share_location,
                        color: Colors.white,
                        size: 35,
                      ),
                      onPressed: () {
                        // Navigator.push(
                        //     context,
                        //     MaterialPageRoute(
                        //         builder: (context) => const AddMarker()));
                        googleMapsMethods.getCurrentLocation(
                            currentPosition, mapController!);
                      },
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Stack(
                  children: [
                    GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: currentPosition,
                        zoom: 14.475,
                      ),
                      myLocationEnabled: true,
                      myLocationButtonEnabled: false,
                      compassEnabled: false,
                      rotateGesturesEnabled: false,
                      markers: markers,
                      mapType: mapType,
                      onTap: (position) async {
                        customInfoWindowController.hideInfoWindow!();
                        Polyline? tappedPolyline;

                        for (var polyline in polylines) {
                          if (googleMapsMethods.isNearPolyline(
                              position, polyline)) {
                            tappedPolyline = polyline;
                            final regex = RegExp(r'\((.*?)\)');
                            final match = regex.firstMatch(
                                tappedPolyline.polylineId.toString());
                            String polylineId = match?.group(1) ?? '';
                            Map<String, dynamic> mapPolyline =
                                await googleMapsMethods
                                    .getPolylineDetails(polylineId);
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => DetailsPolyline(
                                          details: mapPolyline,
                                        )));
                            break;
                          }
                        }

                        if (tappedPolyline != null) {
                          setState(() {
                            selectedPolylineDetails = tappedPolyline;
                            showPolylineDetails = true;
                          });
                        } else {
                          setState(() {
                            showPolylineDetails = false;
                          });
                        }
                      },
                      onCameraMove: (position) {
                        customInfoWindowController.hideInfoWindow!();
                      },
                      onMapCreated: (GoogleMapController _controller) {
                        mapController = _controller;
                        customInfoWindowController.googleMapController =
                            _controller;
                        googleMapsMethods.getCurrentLocation(
                            currentPosition, mapController!);
                      },
                      polylines: polylines,
                    ),
                    CustomInfoWindow(
                      controller: customInfoWindowController,
                      height: 138,
                      width: 218,
                    ),
                    Positioned(
                      bottom: 38,
                      left: 8,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          border: Border.all(color: Colors.blue, width: 2),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: IconButton(
                          icon: AnimatedRotation(
                            turns: rotationAngle,
                            duration: Duration(milliseconds: 500),
                            child: Icon(Icons.refresh, color: Colors.white),
                          ),
                          onPressed: () {
                            setState(() {
                              rotationAngle += 1;
                            });
                            googleMapsMethods.loadDataTapMarker(markers,
                                locations, context, null, excludeMarker);
                            googleMapsMethods.loadPolylinesFromFirestore(
                              polylines,
                              markers,
                              context,
                              excludeItinerary,
                            );
                          },
                        ),
                      ),
                    ),
                    if (showPlacesList)
                      Container(
                        color: Colors.black87,
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
                                    searchController.text = googleMapsMethods
                                        .placesList[index]['description'];
                                  });
                                  Map<String, dynamic> latLng =
                                      await googleMapsMethods
                                          .getLatLngFromAddress(
                                              googleMapsMethods
                                                      .placesList[index]
                                                  ['description']);
                                  LatLng latLngReal =
                                      LatLng(latLng['lat'], latLng['lng']);
                                  googleMapsMethods.goToLocation(latLng['lat'],
                                      latLng['lng'], mapController!);
                                  googleMapsMethods.loadDataTapMarker(
                                      markers,
                                      locations,
                                      context,
                                      latLngReal,
                                      excludeMarker);
                                  setState(() {
                                    showPlacesList = false;
                                    searchController.text = "";
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
                    if (!showPlacesList)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black87,
                            border: Border.all(color: Colors.blue, width: 2),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: IconButton(
                            icon: Icon(Icons.menu, color: Colors.white),
                            onPressed: () {
                              scaffoldKey.currentState?.openDrawer();
                            },
                          ),
                        ),
                      ),
                    if (!showPlacesList)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black87,
                            border: Border.all(color: Colors.blue, width: 2),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: IconButton(
                            icon: Icon(Icons.menu_open, color: Colors.white),
                            onPressed: () {
                              scaffoldKey.currentState?.openEndDrawer();
                            },
                          ),
                        ),
                      ),
                    if (!showPlacesList)
                      Positioned(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 15),
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Container(
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border:
                                      Border.all(color: Colors.blue, width: 2),
                                  color: Colors.black87),
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AddItinerary(),
                                    ),
                                  );
                                },
                                child: Icon(
                                  Icons.add,
                                  color: Colors.white,
                                  size: 58,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    if (!showPlacesList)
                      Positioned(
                        bottom: 15,
                        right: 8,
                        height: 62,
                        width: 62,
                        child: Container(
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.blue, width: 2),
                              color: Colors.black87),
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const AddMarker()));
                            },
                            child: Icon(
                              Icons.add_location_alt,
                              color: Colors.white,
                              size: 38,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

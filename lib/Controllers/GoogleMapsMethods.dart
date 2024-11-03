import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:custom_info_window/custom_info_window.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:travel_app/Views/DetailsMarker.dart';
import 'package:travel_app/Views/DetailsPolyline.dart';
import 'package:uuid/uuid.dart';

class GoogleMapsMethods {
  final Function(Function()) setState;
  var uuid = Uuid();
  String sessionToken = '122344';
  List<dynamic> placesList = [];
  CustomInfoWindowController customInfoWindowController;

  GoogleMapsMethods(this.setState, this.customInfoWindowController);

  Future<void> loadCustomMarkers(
      Set<Marker> markers, List<dynamic> locations) async {
    for (var location in locations) {
      final markerIcon = await getCustomIcon(location['color']);
      setState(() {
        markers.add(
          Marker(
            markerId: MarkerId(location['id']),
            position: location['position'],
            infoWindow: InfoWindow(title: location['title']),
            icon: markerIcon,
          ),
        );
      });
    }
  }

  Future<BitmapDescriptor> getCustomIcon(String iconImage) async {
    String assetPath;
    switch (iconImage) {
      case 'camera':
        assetPath = 'assets/camera.png';
        break;
      case 'camping':
        assetPath = 'assets/camping.png';
        break;
      case 'landscape':
        assetPath = 'assets/landscape.png';
        break;
      case 'roadClosed':
        assetPath = 'assets/roadClosed.png';
        break;
      case 'workInProgress':
        assetPath = 'assets/workInProgress.png';
        break;
      case 'water':
        assetPath = 'assets/water.png';
        break;
      case 'restaurant':
        assetPath = 'assets/restaurant.png';
        break;
      case 'warning':
        assetPath = 'assets/warning.png';
        break;
      case 'defaut':
      default:
        assetPath = 'assets/warning.png';
    }

    //print("Caricamento immagine da: $assetPath");

    try {
      return await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(
            //size: Size(0.02, 0.02),
            ),
        assetPath,
      );
    } catch (e) {
      print("Errore durante il caricamento dell'immagine: $e");
      return BitmapDescriptor.defaultMarker;
    }
  }

  void onChange(TextEditingController controller) {
    if (sessionToken == null) {
      setState(() {
        sessionToken = uuid.v4();
      });
    }

    getSuggestion(controller.text);
  }

  void getSuggestion(String input) async {
    if (input.isEmpty) return;

    String kPLACES_API_KEY = "AIzaSyAlXsl7owmoVBgJpDrn3fPfXNq8zCJq8jg";
    String baseURL =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json';
    String request =
        '$baseURL?input=$input&key=$kPLACES_API_KEY&sessionToken=$sessionToken';

    try {
      var response = await http.get(Uri.parse(request));

      if (response.statusCode == 200) {
        setState(() {
          placesList = jsonDecode(response.body)['predictions'];
        });
      } else {
        print('Errore nella richiesta HTTP: ${response.reasonPhrase}');
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Errore: $e');
    }
  }

  Future<void> loadDataTapMarker(
      Set<Marker> markers,
      List<Map<String, dynamic>> locations,
      BuildContext context,
      LatLng? searchLocation,
      List<String> excludeIcons) async {
    // Aggiungi un parametro per le icone da escludere
    // Clear existing markers
    markers.clear();

    // Fetch data from Firestore
    final snapshot =
        await FirebaseFirestore.instance.collection('markers').get();

    final List<Map<String, dynamic>> newLocations = [];
    for (var doc in snapshot.docs) {
      final data = doc.data();
      newLocations.add({
        'id': doc.id,
        'latitude': _toDouble(data['latitude']),
        'longitude': _toDouble(data['longitude']),
        'title': data['title'],
        'iconImage': data['iconImage'],
      });
    }

    // Update locations list
    locations.clear();
    locations.addAll(newLocations);

    // Create markers
    for (Map<String, dynamic> location in locations) {
      final iconImage = location['iconImage'] as String? ?? 'default';

      // Controlla se l'icona è nella lista delle icone da escludere
      if (excludeIcons.contains(iconImage)) {
        continue; // Salta al prossimo ciclo se l'icona è da escludere
      }

      final markerIcon = await getCustomIcon(iconImage);
      if (searchLocation == null) {
        // Fetch the current location
        Position currentPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        searchLocation =
            LatLng(currentPosition.latitude, currentPosition.longitude);

        final markerPosition = LatLng(
          _toDouble(location['latitude']),
          _toDouble(location['longitude']),
        );

        double distanceInMeters = _calculateDistanceInMeters(
          searchLocation.latitude,
          searchLocation.longitude,
          markerPosition.latitude,
          markerPosition.longitude,
        );

        // Only add markers within 100 meters
        if (distanceInMeters <= 18000) {
          markers.add(
            Marker(
              markerId: MarkerId(location['id'].toString()),
              icon: markerIcon,
              position: markerPosition,
              onTap: () {
                if (context.findRenderObject() != null) {
                  // Verifica che il contesto sia ancora valido
                  Future.delayed(const Duration(milliseconds: 500), () {
                    _showInfoWindow(location, context);
                  });
                }
              },
            ),
          );
        }
        setState(() {});
      } else {
        // Calculate distance between searchLocation and the marker's position
        final markerPosition = LatLng(
          _toDouble(location['latitude']),
          _toDouble(location['longitude']),
        );

        double distanceInMeters = _calculateDistanceInMeters(
          searchLocation.latitude,
          searchLocation.longitude,
          markerPosition.latitude,
          markerPosition.longitude,
        );

        // Only add markers within 100 meters
        if (distanceInMeters <= 18000) {
          markers.add(
            Marker(
              markerId: MarkerId(location['id'].toString()),
              icon: markerIcon,
              position: markerPosition,
              onTap: () {
                Future.delayed(const Duration(milliseconds: 500), () {
                  _showInfoWindow(location, context);
                });
              },
            ),
          );
        }
      }
    }

    // Update state once after all markers are added
    setState(() {});
  }

  void _showInfoWindow(Map<String, dynamic> location, BuildContext context) {
    customInfoWindowController.addInfoWindow!(
      _buildInfoWindowContent(location, context),
      LatLng(_toDouble(location['latitude']), _toDouble(location['longitude'])),
    );
  }

  Widget _buildInfoWindowContent(
      Map<String, dynamic> location, BuildContext context) {
    return Builder(builder: (BuildContext builderContext) {
      return Container(
        height: 38,
        width: 38,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.9),
          border: Border.all(color: Colors.blue),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 18,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Text(
                location['title'] ?? 'No Title',
                style: TextStyle(color: Colors.white, fontSize: 18),
                maxLines: 2, // Limita il testo a una sola riga
                overflow: TextOverflow.ellipsis, // Tronca il testo con "..."
              ),
            ),
            //Spacer(),
            SizedBox(
              height: 18,
            ),
            Container(
              decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  border: Border.all(color: Colors.blue, width: 2),
                  borderRadius: BorderRadius.circular(8)),
              child: ElevatedButton(
                onPressed: () async {
                  final markerId = location['id'];
                  final markerDetails = await getMarkerDetails(markerId);
                  Navigator.of(builderContext).push(MaterialPageRoute(
                      builder: (context) => DetailsMarker(
                            details: markerDetails!,
                          )));
                },
                child: Text(
                  "More Details",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                    //padding: EdgeInsets.symmetric(horizontal: 24, vertical: 2),
                    textStyle: TextStyle(fontSize: 15),
                    overlayColor: Colors.transparent),
              ),
            ),
            SizedBox(
              height: 8,
            ),
          ],
        ),
      );
    });
  }

  double _toDouble(dynamic value) {
    if (value is double) {
      return value;
    } else if (value is int) {
      return value.toDouble();
    } else if (value is String) {
      try {
        return double.parse(value);
      } catch (e) {
        print('Errore durante la conversione in double: $e');
        return 0.0; // O un valore predefinito che ha senso per te
      }
    } else {
      print('Tipo di valore non riconosciuto: $value');
      return 0.0; // O un valore predefinito
    }
  }

  Future<void> getCurrentLocation(
      LatLng currentPosition, GoogleMapController? mapController) async {
    try {
      // Controlla se il servizio di localizzazione è abilitato
      if (await Geolocator.isLocationServiceEnabled()) {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );

        // Aggiorna la posizione corrente
        setState(() {
          currentPosition = LatLng(position.latitude, position.longitude);
        });

        // Controlla che mapController non sia nullo prima di aggiornare la posizione sulla mappa
        mapController
            ?.animateCamera(CameraUpdate.newLatLngZoom(currentPosition, 14));
      } else {
        // Se la localizzazione è disabilitata, usa una posizione di default
        setState(() {
          currentPosition = const LatLng(41.730778, 12.28445);
        });
      }
    } catch (e) {
      // Gestione di eventuali eccezioni
      print("Errore durante l'ottenimento della posizione: $e");
      setState(() {
        currentPosition =
            const LatLng(41.730778, 12.28445); // Posizione di default
      });
    }
  }

  Future<void> goToLocation(
      double lat, double lng, GoogleMapController mapController) async {
    final GoogleMapController? controller = mapController;
    if (controller != null) {
      final CameraPosition cameraPosition = CameraPosition(
        target: LatLng(lat, lng),
        zoom: 18.0,
      );
      await controller
          .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
    }
  }

  Future<Map<String, dynamic>> getLatLngFromAddress(String address) async {
    String kPLACES_API_KEY = "AIzaSyAlXsl7owmoVBgJpDrn3fPfXNq8zCJq8jg";
    final String url =
        'https://maps.googleapis.com/maps/api/geocode/json?address=${Uri.encodeComponent(address)}&key=$kPLACES_API_KEY';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data['status'] == 'OK') {
        final location = data['results'][0]['geometry']['location'];
        return {'lat': location['lat'], 'lng': location['lng']};
      } else {
        throw Exception('Failed to retrieve location data');
      }
    } else {
      throw Exception('Failed to connect to API');
    }
  }

  Future<String> getAddressFromLatLng(String? lat, String? lng) async {
    String currentAddress = "";
    late Position position;
    if (lat == null || lng == null) {
      position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } else {
      position = Position(
        latitude: _toDouble(lat),
        longitude: _toDouble(lng),
        timestamp: DateTime.now(),
        accuracy: 0.0, // imposta un valore predefinito o logico per accuracy
        altitude: 0.0, // imposta un valore predefinito o logico per altitude
        heading: 0.0, // imposta un valore predefinito o logico per heading
        speed: 0.0, // imposta un valore predefinito o logico per speed
        speedAccuracy: 0.0,
        altitudeAccuracy: 0,
        headingAccuracy:
            0, // imposta un valore predefinito o logico per speedAccuracy
      );
    }
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);

      Placemark place = placemarks[0];

      setState(() {
        currentAddress =
            '${place.street}, ${place.locality}, ${place.postalCode}, ${place.country}';
      });
      return currentAddress;
    } catch (e) {
      print(e);
    }
    return "";
  }

  Future<void> addMarkerToFirestore(String address, String title,
      String iconImage, String description, Uint8List? image) async {
    Map<String, dynamic> latLng = await getLatLngFromAddress(address);
    double lat = latLng['lat'];
    double lng = latLng['lng'];
    User? user = FirebaseAuth.instance.currentUser;

    String uid = user!.uid;
    CollectionReference markers =
        FirebaseFirestore.instance.collection('markers');

    String photoUrl = '';
    if (image != null) {
      Reference storageRef = FirebaseStorage.instance
          .ref()
          .child('markerPics')
          .child('${user.uid}.jpg');

      UploadTask uploadTask = storageRef.putData(image);
      TaskSnapshot snapshot = await uploadTask;

      photoUrl = await snapshot.ref.getDownloadURL();
    }

    return markers
        .add({
          'latitude': lat.toString(),
          'longitude': lng.toString(),
          'title': title,
          'iconImage': iconImage,
          'mittente': uid,
          'description': description,
          'photoURL': photoUrl,
          'id': generateFirestoreId(20),
          'positiveFeedback': 0,
          'negativeFeedback': 0,
        })
        .then((value) => print("Marker Added"))
        .catchError((error) => print("Failed to add marker: $error"));
  }

  Future<bool> checkIfLatLngExists(double lat, double lng) async {
    String latString = lat.toString();
    String lngString = lng.toString();
    // Ottieni il riferimento alla collezione
    CollectionReference collectionRef =
        FirebaseFirestore.instance.collection('markers');

    // Esegui una query per cercare documenti con lo stesso titolo
    QuerySnapshot querySnapshot = await collectionRef
        .where('latitude', isEqualTo: latString)
        .where('longitude', isEqualTo: lngString)
        .get();

    // Controlla se ci sono risultati
    if (querySnapshot.docs.isNotEmpty) {
      // Documento con lo stesso titolo trovato
      return true;
    } else {
      // Nessun documento con lo stesso titolo trovato
      return false;
    }
  }

  Future<Map<String, dynamic>?> getMarkerDetails(String markerId) async {
    try {
      // Recupera i dettagli del marker dalla collezione 'markers'
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('markers')
          .doc(markerId)
          .get();

      if (doc.exists) {
        return doc.data() as Map<String, dynamic>?;
      } else {
        print('Marker not found');
        return null;
      }
    } catch (e) {
      print('Errore nel recupero dei dettagli del marker: $e');
      return null;
    }
  }

  String generateFirestoreId(int length) {
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return List.generate(length, (index) => chars[random.nextInt(chars.length)])
        .join();
  }

  Future<void> updateMarkerFeedback(
      String markerId, int newNumber, int side) async {
    if (side == 0) {
      try {
        // Recupera il documento che corrisponde al markerId
        var querySnapshot = await FirebaseFirestore.instance
            .collection('markers')
            .where('id', isEqualTo: markerId)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          // Aggiorna il documento trovato
          await querySnapshot.docs.first.reference
              .update({'positiveFeedback': newNumber});
          print('Documento aggiornato con successo');
        } else {
          print('Nessun documento trovato con l\'id specificato');
        }
      } catch (e) {
        print('Errore durante l\'aggiornamento del documento: $e');
      }
    } else if (side == 1) {
      try {
        // Recupera il documento che corrisponde al markerId
        var querySnapshot = await FirebaseFirestore.instance
            .collection('markers')
            .where('id', isEqualTo: markerId)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          // Aggiorna il documento trovato
          await querySnapshot.docs.first.reference
              .update({'negativeFeedback': newNumber});
          print('Documento aggiornato con successo');
        } else {
          print('Nessun documento trovato con l\'id specificato');
        }
        print('Documento aggiornato con successo');
      } catch (e) {
        print('Errore durante l\'aggiornamento del documento: $e');
      }
    }
  }

  double _calculateDistanceInMeters(
      double lat1, double lon1, double lat2, double lon2) {
    const earthRadius = 6371000; // Radius of the Earth in meters
    final dLat = _degToRad(lat2 - lat1);
    final dLon = _degToRad(lon2 - lon1);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degToRad(lat1)) *
            cos(_degToRad(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    final distance = earthRadius * c;

    return distance;
  }

  double _degToRad(double degree) {
    return degree * pi / 180;
  }

  Future<void> addPolylineToFirestore(
      List<LatLng> stops,
      String title,
      String description,
      List<String> addresses,
      DateTime lastDay,
      DateTime firstDay,
      String mode) async {
    User? user = FirebaseAuth.instance.currentUser;

    String uid = user!.uid;
    CollectionReference polylines =
        FirebaseFirestore.instance.collection('polylines');

    List<Map<String, double>> stopsMap = stops
        .map((stop) => {'latitude': stop.latitude, 'longitude': stop.longitude})
        .toList();

    return polylines
        .add({
          'stops': stopsMap,
          'title': title,
          'mittente': uid,
          'description': description,
          'id': generateFirestoreId(20),
          'addresses': addresses,
          'lastDay': lastDay,
          'firstDay': firstDay,
          'mode': mode,
        })
        .then((value) => print("Polyline Added"))
        .catchError((error) => print("Failed to add polyline: $error"));
  }

  // Future<void> loadPolylinesFromFirestore(Set<Polyline> polylines) async {
  //   CollectionReference polylinesCollection =
  //       FirebaseFirestore.instance.collection('polylines');

  //   QuerySnapshot querySnapshot = await polylinesCollection.get();
  //   Set<Polyline> tempPolylines = {};

  //   for (QueryDocumentSnapshot doc in querySnapshot.docs) {
  //     List<dynamic> stopsJson = doc['stops'];

  //     List<LatLng> polylinePoints = stopsJson.map((stop) {
  //       double lat = stop['latitude'];
  //       double lng = stop['longitude'];
  //       return LatLng(lat, lng);
  //     }).toList();

  //     Polyline polyline = Polyline(
  //       polylineId: PolylineId(doc.id),
  //       points: polylinePoints,
  //       color: getRandomColor(),
  //       width: 5,
  //     );

  //     tempPolylines.add(polyline);
  //   }

  //   setState(() {
  //     polylines.addAll(tempPolylines);
  //   });
  // }

  Color getRandomColor() {
    Random random = Random();
    return Color.fromARGB(
      255,
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
    );
  }

  // In GoogleMapsMethods class, add these methods:

  Future<Map<String, dynamic>> getPolylineDetails(String polylineId) async {
    try {
      var querySnapshot = await FirebaseFirestore.instance
          .collection('polylines')
          .where('id', isEqualTo: polylineId)
          .get();

      print(querySnapshot.docs);

      if (querySnapshot.docs.isNotEmpty) {
        print('qui');
        return querySnapshot.docs.first.data() as Map<String, dynamic>;
      }

      return <String, dynamic>{};
    } catch (e) {
      print('Error fetching polyline details: $e');
      return <String, dynamic>{};
    }
  }

  Future<void> loadPolylinesFromFirestore(
      Set<Polyline> polylines,
      Set<Marker> markers,
      BuildContext context,
      List<String> excludeItinerary) async {
    try {
      CollectionReference polylinesCollection =
          FirebaseFirestore.instance.collection('polylines');

      // Filtro per caricare solo le polylines con lastDay maggiore della data attuale
      DateTime today = DateTime.now().subtract(Duration(days: 1));
      QuerySnapshot? querySnapshot;
      User? user = FirebaseAuth.instance.currentUser;

      String uid = user!.uid;
      if (excludeItinerary.isEmpty) {
        querySnapshot = await polylinesCollection
            .where('lastDay', isGreaterThan: today)
            .get();
      } else if (excludeItinerary.contains('mineOnly')) {
        querySnapshot = await polylinesCollection
            .where('lastDay', isGreaterThan: today)
            .where('mittente', isEqualTo: uid)
            .get();
      } else if (excludeItinerary.contains('all')) {
        querySnapshot = await polylinesCollection.get();
      }

      Set<Polyline> tempPolylines = {};
      Set<Marker> tempMarkers = {}; // Set temporaneo per i marker

      for (QueryDocumentSnapshot doc in querySnapshot!.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        List<dynamic> stopsJson = data['stops'];
        String polylineId = data['id'];

        List<LatLng> polylinePoints = stopsJson.map((stop) {
          return LatLng(
            stop['latitude'].toDouble(),
            stop['longitude'].toDouble(),
          );
        }).toList();

        // Crea una polyline con i punti caricati
        Polyline polyline = Polyline(
          polylineId: PolylineId(polylineId),
          points: polylinePoints,
          color: getRandomColor(),
          width: 5,
          onTap: () async {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetailsPolyline(details: data),
              ),
            );
          },
        );

        // Aggiungi la polyline al set temporaneo
        tempPolylines.add(polyline);

        LatLng point0 = polylinePoints[0];
        Marker marker0 = Marker(
            markerId: MarkerId('$polylineId-0'),
            position: point0,
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => DetailsPolyline(
                            details: data,
                          )));
            });

        tempMarkers.add(marker0);

        LatLng pointLast = polylinePoints[polylinePoints.length - 1];
        Marker markerLast = Marker(
            markerId: MarkerId('$polylineId-last'),
            position: pointLast,
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => DetailsPolyline(
                            details: data,
                          )));
            });

        tempMarkers.add(markerLast);

        // Crea un marker per ogni punto nella polyline
        // for (var i = 0; i < polylinePoints.length; i++) {
        //   LatLng point = polylinePoints[i];
        //   Marker marker = Marker(
        //     markerId: MarkerId('$polylineId-$i'),
        //     position: point,
        //     onTap: () {
        //       Navigator.push(
        //           context,
        //           MaterialPageRoute(
        //               builder: (context) => DetailsPolyline(
        //                     details: data,
        //                   )));
        //     },
        //   );
        //   tempMarkers.add(marker);
        // }
      }

      setState(() {
        polylines.clear();
        polylines.addAll(tempPolylines);

        markers.clear();
        markers.addAll(tempMarkers); // Aggiorna i marker sulla mappa
      });
    } catch (e) {
      print('Error loading polylines: $e');
    }
  }

  // Funzione per verificare se il tocco è vicino a una polyline
  bool isNearPolyline(LatLng tapPosition, Polyline polyline) {
    for (var point in polyline.points) {
      double distance = calculateDistance(tapPosition, point);
      if (distance < 0.001) {
        // Soglia di distanza in gradi, circa 100 metri
        return true;
      }
    }
    return false;
  }

  double calculateDistance(LatLng start, LatLng end) {
    var dx = start.latitude - end.latitude;
    var dy = start.longitude - end.longitude;
    return sqrt(dx * dx + dy * dy);
  }

  Future<String> getStopsAddresses(List<dynamic> stops) async {
    List<String> addresses = [];

    for (var stop in stops) {
      String address = await getAddressFromLatLng(
        stop['latitude']?.toString(),
        stop['longitude']?.toString(),
      );
      addresses.add(address);

      await Future.delayed(Duration(minutes: 1));
    }

    return addresses.join('\n\n→\n\n');
  }

  bool isCloseToMarker(LatLng touchPosition, LatLng markerPosition) {
    const double proximityThreshold =
        0.001; // Soglia per la distanza (es. 0.001 gradi)
    return (touchPosition.latitude - markerPosition.latitude).abs() <
            proximityThreshold &&
        (touchPosition.longitude - markerPosition.longitude).abs() <
            proximityThreshold;
  }

  Future<String> loadNumbersPolylines() async {
    CollectionReference polylinesCollection =
        FirebaseFirestore.instance.collection('polylines');

    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      QuerySnapshot querySnapshot = await polylinesCollection
          .where('mittente', isEqualTo: user.uid)
          .get();
      return querySnapshot.size.toString();
    }
    return '0';
  }
}

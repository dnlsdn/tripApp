import 'dart:async';
import 'dart:typed_data';

import 'package:custom_info_window/custom_info_window.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:travel_app/Controllers/GoogleMapsMethods.dart';
import 'package:travel_app/Utils/ImagePicker.dart';

class AddMarker extends StatefulWidget {
  const AddMarker({super.key});

  @override
  State<AddMarker> createState() => _AddMarkerState();
}

class _AddMarkerState extends State<AddMarker> {
  TextEditingController searchController = TextEditingController();
  late GoogleMapsMethods googleMapsMethods;
  LatLng currentPosition = LatLng(37.77483, -122.41942);
  GoogleMapController? mapController;
  String address = "";
  bool showPlacesList = false;
  String imageString = "";
  String markerType = "Click to select a Marker";
  final TextEditingController titleController = TextEditingController();
  bool alertEmpty = false;
  final TextEditingController descriptionController = TextEditingController();
  Uint8List? image;
  bool alertDuplicate = false;

  @override
  void initState() {
    super.initState();
    googleMapsMethods =
        GoogleMapsMethods(setState, CustomInfoWindowController());
    searchController.addListener(() {
      googleMapsMethods.onChange(searchController);
      setState(() {
        showPlacesList = searchController.text.isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    titleController.dispose();
    searchController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  void showPicker(BuildContext context) {
    showModalBottomSheet(
      backgroundColor: Colors.black,
      barrierColor: Colors.black.withOpacity(0.8),
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 580,
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.camera_alt, color: Colors.white),
                title: Text('Place to take a photo!',
                    style: TextStyle(color: Colors.white)),
                onTap: () {
                  setState(() {
                    imageString = 'camera';
                    markerType = 'camera';
                    titleController.text = 'Place to take a pic';
                  });
                  Navigator.of(context).pop();
                },
              ),
              Divider(
                height: 0,
              ),
              ListTile(
                leading: Icon(Icons.cabin, color: Colors.white),
                title: Text('Place to camp!',
                    style: TextStyle(color: Colors.white)),
                onTap: () {
                  setState(() {
                    imageString = 'camping';
                    markerType = 'camping';
                    titleController.text = 'Place to camp';
                  });
                  Navigator.of(context).pop();
                },
              ),
              Divider(
                height: 0,
              ),
              ListTile(
                leading: Icon(Icons.landscape, color: Colors.white),
                title: Text('Place to see a landscape!',
                    style: TextStyle(color: Colors.white)),
                onTap: () {
                  setState(() {
                    imageString = 'landscape';
                    markerType = 'landscape';
                    titleController.text = 'Landscape to see';
                  });
                  Navigator.of(context).pop();
                },
              ),
              Divider(
                height: 0,
              ),
              ListTile(
                leading: Icon(Icons.remove_road, color: Colors.white),
                title:
                    Text('Closed Way!', style: TextStyle(color: Colors.white)),
                onTap: () {
                  setState(() {
                    imageString = 'roadClosed';
                    markerType = 'roadClosed';
                    titleController.text = 'Closed Way';
                  });
                  Navigator.of(context).pop();
                },
              ),
              Divider(
                height: 0,
              ),
              ListTile(
                leading: Icon(Icons.engineering, color: Colors.white),
                title: Text('Construction Work!',
                    style: TextStyle(color: Colors.white)),
                onTap: () {
                  setState(() {
                    imageString = 'workInProgress';
                    markerType = 'workInProgress';
                    titleController.text = 'Construction Work';
                  });
                  Navigator.of(context).pop();
                },
              ),
              Divider(
                height: 0,
              ),
              ListTile(
                leading: Icon(Icons.coffee_maker, color: Colors.white),
                title: Text('Place with potable water!',
                    style: TextStyle(color: Colors.white)),
                onTap: () {
                  setState(() {
                    imageString = 'water';
                    markerType = 'water';
                    titleController.text = 'Potable Water';
                  });
                  Navigator.of(context).pop();
                },
              ),
              Divider(
                height: 0,
              ),
              ListTile(
                leading: Icon(Icons.restaurant, color: Colors.white),
                title: Text('Restaurant Place!',
                    style: TextStyle(color: Colors.white)),
                onTap: () {
                  setState(() {
                    imageString = 'restaurant';
                    markerType = 'restaurant';
                    titleController.text = 'Restaurant';
                  });
                  Navigator.of(context).pop();
                },
              ),
              Divider(
                height: 0,
              ),
              ListTile(
                leading: Icon(Icons.warning, color: Colors.white),
                title: Text('Place to pay attention!',
                    style: TextStyle(color: Colors.white)),
                onTap: () {
                  setState(() {
                    imageString = 'warning';
                    markerType = 'warning';
                    titleController.text = 'Warning';
                  });
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void selectImage() async {
    Uint8List? im = await pickImage(ImageSource.gallery);
    setState(() {
      image = im;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;
    return Scaffold(
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: buildHeader(),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildSearchBar(),
                        SizedBox(height: 18),
                        if (showPlacesList)
                          buildPlacesList()
                        else ...[
                          buildAddressSection(),
                          SizedBox(height: 18),
                          buildMarkerTypeSection(),
                          SizedBox(height: 18),
                          buildDescriptionSection(),
                          SizedBox(height: 25),
                          picSection(),
                          SizedBox(height: 18),
                          if (alertEmpty) alertEmptySection(),
                          if (alertDuplicate) alertDuplicateSection(),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              if (!showPlacesList ||
                  MediaQuery.of(context).viewInsets.bottom > 0)
                buildSaveButton(isKeyboardVisible),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildHeader() {
    return Row(
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
          'Add Marker',
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 27, color: Colors.white),
        ),
      ],
    );
  }

  Widget buildSearchBar() {
    return Row(
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
                      onPressed: () => searchController.clear(),
                    )
                  : null,
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.blue),
                borderRadius: BorderRadius.circular(18),
              ),
              filled: true,
              fillColor: Colors.white10,
            ),
          ),
        ),
        SizedBox(width: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.7),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white),
          ),
          child: IconButton(
            highlightColor: Colors.transparent,
            icon: Icon(Icons.near_me, color: Colors.white),
            onPressed: () async {
              address =
                  await googleMapsMethods.getAddressFromLatLng(null, null);
              setState(() {});
              print(address);
            },
          ),
        ),
      ],
    );
  }

  Widget buildPlacesList() {
    return Container(
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
                  searchController.text =
                      googleMapsMethods.placesList[index]['description'];
                });
                Map<String, dynamic> latLng =
                    await googleMapsMethods.getLatLngFromAddress(
                        googleMapsMethods.placesList[index]['description']);
                address = googleMapsMethods.placesList[index]['description'];
                setState(() {
                  showPlacesList = false;
                  searchController.text = "";
                  FocusScope.of(context).unfocus();
                });
              },
              title: Text(googleMapsMethods.placesList[index]['description'] ??
                  'No title available'),
            ),
          );
        },
      ),
    );
  }

  Widget buildAddressSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Address',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        SizedBox(height: 5),
        Text(address == "" ? "//" : address,
            style: TextStyle(color: Colors.white, fontSize: 15)),
      ],
    );
  }

  Widget buildDescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Description',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        TextField(
          controller: descriptionController,
          cursorColor: Colors.white,
          decoration: InputDecoration(
            labelText: 'Marker Description',
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
            labelStyle: TextStyle(color: Colors.white),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.blue, width: 2.0),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey, width: 1.0),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildMarkerTypeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Marker Type',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Row(
          children: [
            imageString == ""
                ? Icon(Icons.circle_outlined)
                : Image.asset('assets/$imageString.png', height: 38, width: 38),
            SizedBox(width: 18),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue, width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: InkWell(
                  onTap: () => showPicker(context),
                  child: Text(markerType, style: TextStyle(fontSize: 18)),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget picSection() {
    return Center(
      child: Stack(
        children: [
          InkWell(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: selectImage,
            child: image != null
                ? Container(
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.blue, width: 2),
                        borderRadius: BorderRadius.circular(2)),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image.memory(
                        image!,
                        height: 138,
                      ),
                    ),
                  )
                : Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.blue, width: 2),
                        borderRadius: BorderRadius.circular(8)),
                    child: const CircleAvatar(
                      backgroundColor: Colors.transparent,
                      radius: 64,
                      child: Icon(
                        Icons.photo_outlined,
                        size: 88,
                        color: Colors.white,
                      ),
                    ),
                  ),
          ),
          if (image == null)
            Positioned(
              bottom: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.all(4.0),
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.blue)),
                child: const Icon(
                  Icons.add,
                  color: Colors.white,
                ),
              ),
            )
        ],
      ),
    );
  }

  Widget alertEmptySection() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
          child: Text(
        'Fill all field to post your Marker!',
        style: TextStyle(fontSize: 22, color: Colors.red),
      )),
    );
  }

  Widget alertDuplicateSection() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
          child: Text(
        textAlign: TextAlign.center,
        'There is already a marker in this point!\nYou can give a feedback on that',
        style: TextStyle(fontSize: 15, color: Colors.red),
      )),
    );
  }

  Widget buildSaveButton(bool isKeyboardVisible) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      height: isKeyboardVisible ? 0 : 68,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Opacity(
          opacity: isKeyboardVisible ? 0.0 : 1.0,
          child: InkWell(
            onTap: isKeyboardVisible
                ? null
                : () async {
                    if (address != "" &&
                        titleController.text != "" &&
                        markerType != "Click to select a Marker") {
                      Map<String, dynamic> latLng =
                          await googleMapsMethods.getLatLngFromAddress(address);
                      double lat = latLng['lat'];
                      double lng = latLng['lng'];
                      bool exists =
                          await googleMapsMethods.checkIfLatLngExists(lat, lng);
                      if (!exists) {
                        googleMapsMethods.addMarkerToFirestore(
                            address,
                            titleController.text,
                            markerType,
                            descriptionController.text,
                            image);
                      } else {
                        setState(() {
                          alertDuplicate = true;
                        });
                        Timer(Duration(seconds: 5), () {
                          setState(() {
                            alertDuplicate = false;
                          });
                        });
                      }
                      if (alertDuplicate != true) {
                        Navigator.pop(context);
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
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(
                  color: address != "" &&
                          titleController.text != "" &&
                          markerType != "Click to select a Marker"
                      ? Colors.blue
                      : Colors.white.withOpacity(0.7),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  'Save',
                  style: TextStyle(
                      fontSize: 22,
                      color: address != "" &&
                              titleController.text != "" &&
                              markerType != "Click to select a Marker"
                          ? Colors.white
                          : Colors.white.withOpacity(0.7),
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

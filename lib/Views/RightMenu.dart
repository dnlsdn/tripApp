import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:travel_app/Controllers/UserProvider.dart';
import 'package:travel_app/models/Utente.dart';

class RightMenu extends StatefulWidget {
  MapType mapType;
  final Function(MapType) onMapTypeChanged;
  List<String> excludeMarker = [];
  final Function(List<String>) onExcludeMarkerChanged;
  List<String> excludeItinerary = [];
  final Function(List<String>) onExcludeItineraryChanged;

  RightMenu({
    super.key,
    required this.mapType,
    required this.onMapTypeChanged,
    required this.excludeMarker,
    required this.onExcludeMarkerChanged,
    required this.excludeItinerary,
    required this.onExcludeItineraryChanged,
  });

  @override
  State<RightMenu> createState() => _RightMenuState();
}

class _RightMenuState extends State<RightMenu> {
  String stringMap = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    switch (widget.mapType) {
      case MapType.normal:
        stringMap = 'Normal';
        break;
      case MapType.none:
        break;
      case MapType.satellite:
        stringMap = 'Satellite';
        break;
      case MapType.terrain:
        stringMap = 'Terrain';
        break;
      case MapType.hybrid:
        stringMap = 'Hybrid';
        break;
    }
  }

  bool showFilterList = false;

  @override
  Widget build(BuildContext context) {
    Utente? user = Provider.of<UserProvider>(context).getUser;
    List<String> filterIconList = [
      'camera',
      'camping',
      'landscape',
      'roadClosed',
      'workInProgress',
      'water',
      'restaurant',
      'warning'
    ];

    List<String> filterItineraryList = [
      'See Present and Future Itineraries',
      'See Only Your Itineraries',
      'See All',
    ];

    void toggleList() {
      setState(() {
        showFilterList = !showFilterList;
      });
    }

    void showPopupWithListMarkers(BuildContext context) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Filter Markers"),
            content: Container(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: filterIconList.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading:
                        widget.excludeMarker.contains(filterIconList[index])
                            ? Icon(Icons.visibility_off)
                            : Icon(Icons.visibility),
                    title: Text(filterIconList[index]),
                    onTap: () {
                      if (!widget.excludeMarker
                          .contains(filterIconList[index])) {
                        widget.excludeMarker.add(filterIconList[index]);
                      } else {
                        widget.excludeMarker.remove(filterIconList[index]);
                      }
                      widget.onExcludeMarkerChanged(
                          List.from(widget.excludeMarker));
                      Navigator.of(context).pop();
                    },
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  "Close",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          );
        },
      );
    }

    void showPopupWithListItineraries(BuildContext context) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Filter Itineraries"),
            content: Container(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: filterItineraryList.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: Icon(
                      Icons.mode_standby,
                      color: widget.excludeItinerary
                              .contains(filterItineraryList[index])
                          ? Colors.green
                          : Colors.white,
                    ),
                    title: Text(filterItineraryList[index]),
                    onTap: () {
                      widget.excludeItinerary.clear();
                      if (filterItineraryList[index] ==
                          'See Present and Future Itineraries') {
                      } else if (filterItineraryList[index] ==
                          'See Only Your Itineraries') {
                        widget.excludeItinerary.add('mineOnly');
                      } else if (filterItineraryList[index] == 'See All') {
                        widget.excludeItinerary.add('all');
                      }

                      widget.onExcludeItineraryChanged(
                          List.from(widget.excludeItinerary));
                      Navigator.of(context).pop();
                    },
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  "Close",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          );
        },
      );
    }

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Map Settings',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          buildMenuItem(
            icon: Icons.map_outlined,
            text: 'Layers | $stringMap',
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Select Layer'),
                    content: DropdownButton<MapType>(
                      focusColor: Colors.transparent,
                      value: widget.mapType,
                      onChanged: (MapType? newValue) {
                        setState(() {
                          widget.mapType = newValue!;
                        });
                        Navigator.of(context).pop();
                      },
                      items: <DropdownMenuItem<MapType>>[
                        DropdownMenuItem(
                          value: MapType.normal,
                          child: Text('Normal'),
                          onTap: () {
                            widget.onMapTypeChanged(MapType.normal);
                            stringMap = 'Normal';
                          },
                        ),
                        DropdownMenuItem(
                          value: MapType.satellite,
                          child: Text('Satellite'),
                          onTap: () {
                            widget.onMapTypeChanged(MapType.satellite);
                            stringMap = 'Satellite';
                          },
                        ),
                        DropdownMenuItem(
                          value: MapType.terrain,
                          child: Text('Terrain'),
                          onTap: () {
                            widget.onMapTypeChanged(MapType.terrain);
                            stringMap = 'Terrain';
                          },
                        ),
                        DropdownMenuItem(
                          value: MapType.hybrid,
                          child: Text('Hybrid'),
                          onTap: () {
                            widget.onMapTypeChanged(MapType.hybrid);
                            stringMap = 'Hybrid';
                          },
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
          buildMenuItem(
            icon: Icons.filter_alt_off,
            text: 'Filter Markers',
            onTap: () {
              showPopupWithListMarkers(context);
            },
          ),
          buildMenuItem(
            icon: Icons.filter_alt_off,
            text: 'Filter Itineraries',
            onTap: () {
              showPopupWithListItineraries(context);
            },
          ),
        ],
      ),
    );
  }
}

ListTile buildMenuItem({
  required IconData icon,
  required String text,
  required VoidCallback onTap,
}) {
  return ListTile(
    splashColor: Colors.black12,
    leading: Icon(
      icon,
      size: 24,
    ),
    title: Text(
      text,
      style: TextStyle(
        fontSize: 16,
      ),
    ),
    onTap: onTap,
  );
}

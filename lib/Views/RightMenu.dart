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

  RightMenu({
    super.key,
    required this.mapType,
    required this.onMapTypeChanged,
    required this.excludeMarker,
    required this.onExcludeMarkerChanged,
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

    void toggleList() {
      setState(() {
        showFilterList =
            !showFilterList; // Alterna la visualizzazione della lista
      });
    }

    void showPopupWithList(BuildContext context) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Filter"),
            content: Container(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true, // Ridimensiona in base agli elementi
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
                  "Chiudi",
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
            text: 'Map Type | $stringMap',
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Select Map Type'),
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
            text: 'Filter',
            onTap: () {
              showPopupWithList(context);
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
      //color: Colors.blue.shade800,
      size: 24,
    ),
    title: Text(
      text,
      style: TextStyle(
        //color: Colors.blue.shade800,
        fontSize: 16,
      ),
    ),
    onTap: onTap,
  );
}

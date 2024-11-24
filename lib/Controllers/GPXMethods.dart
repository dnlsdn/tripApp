import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:gpx/gpx.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GPXMethods {
  Future<File?> pickGPXFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any
      );

      if (result != null && result.files.single.path != null) {
        return File(result.files.single.path!);
      } else {
        // User canceled the picker
        return null;
      }
    } catch (e) {
      print('Error picking GPX file: $e');
      return null;
    }
  }

  Future<List<LatLng>> parseGPXFile(File gpxFile) async {
    try {
      final xmlString = await gpxFile.readAsString();
      final gpx = GpxReader().fromString(xmlString);
      List<LatLng> points = [];

      if (gpx.trks != null && gpx.trks!.isNotEmpty) {
        for (var track in gpx.trks!) {
          for (var segment in track.trksegs!) {
            for (var point in segment.trkpts!) {
              if (point.lat != null && point.lon != null) {
                points.add(LatLng(point.lat!, point.lon!));
              }
            }
          }
        }
      } else if (gpx.rtes != null && gpx.rtes!.isNotEmpty) {
        // If there are routes instead of tracks
        for (var route in gpx.rtes!) {
          for (var point in route.rtepts!) {
            if (point.lat != null && point.lon != null) {
              points.add(LatLng(point.lat!, point.lon!));
            }
          }
        }
      } else {
        print('No track or route points found in GPX file.');
      }

      return points;
    } catch (e) {
      print('Error parsing GPX file: $e');
      return [];
    }
  }
}

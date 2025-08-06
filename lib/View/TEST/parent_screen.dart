import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class ParentScreen extends StatefulWidget {
  @override
  _ParentScreenState createState() => _ParentScreenState();
}

class _ParentScreenState extends State<ParentScreen> {
  LatLng? driverPosition;
  late GoogleMapController mapController;
  Set<Marker> markers = {};
  Set<Polyline> polylines = {};

  final String apiKey = 'AIzaSyD4H13KH_xF8I2f7RXK2WjXCYrQSROqZek';

  final LatLng startPoint = LatLng(17.391, 78.478);
  final LatLng endPoint = LatLng(17.455, 78.425);
  final List<LatLng> stops = [
    LatLng(17.40, 78.47),
    LatLng(17.42, 78.45),
  ];

  DateTime _lastMarkerUpdateTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    drawRoutePolyline();
    fetchDriverLocation();
  }

 void fetchDriverLocation() {
  FirebaseDatabase.instance.ref('bus_locations/bus_1').onValue.listen((event) {
    final data = Map<String, dynamic>.from(event.snapshot.value as Map);

    LatLng newDriverPosition = LatLng(data['lat'], data['lng']);

    setState(() {
      driverPosition = newDriverPosition;
      markers.removeWhere((m) => m.markerId.value == 'driver');
      markers.add(Marker(
        markerId: MarkerId('driver'),
        position: newDriverPosition,
        infoWindow: InfoWindow(title: 'Driver'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      ));
    });

    // Optional: Animate camera to follow the driver
    mapController.animateCamera(
      CameraUpdate.newLatLng(newDriverPosition),
    );
  });
}


  Future<void> drawRoutePolyline() async {
    String waypoints = stops
        .map((stop) => '${stop.latitude},${stop.longitude}')
        .join('|');

    final url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${startPoint.latitude},${startPoint.longitude}&destination=${endPoint.latitude},${endPoint.longitude}&waypoints=$waypoints&key=$apiKey';

    final response = await http.get(Uri.parse(url));
    final data = json.decode(response.body);

    if (data['status'] == 'OK') {
      final points = data['routes'][0]['overview_polyline']['points'];
      final List<LatLng> polylinePoints = decodePolyline(points);

      setState(() {
        polylines.add(Polyline(
          polylineId: PolylineId('route'),
          points: polylinePoints,
          color: Colors.deepPurple,
          width: 5,
        ));

        // Route static markers
        markers.add(Marker(markerId: MarkerId('start'), position: startPoint, infoWindow: InfoWindow(title: 'Start')));
        markers.add(Marker(markerId: MarkerId('end'), position: endPoint, infoWindow: InfoWindow(title: 'End')));

        for (int i = 0; i < stops.length; i++) {
          markers.add(Marker(
            markerId: MarkerId('stop$i'),
            position: stops[i],
            infoWindow: InfoWindow(title: 'Stop ${i + 1}'),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          ));
        }
      });
    } else {
      log('Error fetching route: ${data['status']}');
    }
  }

  List<LatLng> decodePolyline(String encoded) {
    List<LatLng> points = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0) ? ~(result >> 1) : (result >> 1);
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0) ? ~(result >> 1) : (result >> 1);
      lng += dlng;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return points;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Parent Page')),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(target: startPoint, zoom: 13),
        onMapCreated: (controller) => mapController = controller,
        markers: markers,
        polylines: polylines,
        myLocationEnabled: true,
      ),
    );
  }
}

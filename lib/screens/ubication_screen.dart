import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class UbicationScreen extends StatefulWidget {
  const UbicationScreen({super.key});

  @override
  State<UbicationScreen> createState() => _UbicationScreenState();
}

class _UbicationScreenState extends State<UbicationScreen> {
  final Completer<GoogleMapController> _controller = Completer<GoogleMapController>();

  static const CameraPosition _kGooglePlex = CameraPosition(target: LatLng(20.52353, -100.8157), zoom: 14);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        initialCameraPosition: _kGooglePlex,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
      ),
    );
  }
}
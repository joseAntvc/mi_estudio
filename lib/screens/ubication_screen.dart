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

  static const CameraPosition _kGooglePlex = CameraPosition(target: LatLng(20.5415, -100.8119), zoom: 14);

  final Set<Marker> _markers = {
    Marker(
      markerId: MarkerId('itcelaya2'),
      position: LatLng(20.541580600393097, -100.8119109608545),
      infoWindow: InfoWindow(
        title: 'Instituto Tecnológico de Celaya Campus II',
      ),
    ),
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Ubicación", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: _kGooglePlex,
            markers: _markers,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
          ),
          Positioned(
            top: 10,
            right: 10,
            child: FloatingActionButton(
              mini: true,
              child: Icon(Icons.my_location_outlined),
              onPressed: () => _moverCamara(LatLng(20.541580600393097, -100.8119109608545), 'itcelaya2'),
            ),
          ),
        ],
      ),
    );
  }
  Future<void> _moverCamara(LatLng position, String markerId) async {
    final controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newLatLngZoom(position, 16)); 
    controller.showMarkerInfoWindow(MarkerId(markerId));
  }
}
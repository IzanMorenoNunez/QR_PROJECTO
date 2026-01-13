import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:qr_scan/models/scan_model.dart';

class MapaScreen extends StatefulWidget {
  const MapaScreen({Key? key}) : super(key: key);

  @override
  State<MapaScreen> createState() => _MapaScreenState();
}

class _MapaScreenState extends State<MapaScreen> {
  final Completer<GoogleMapController> _controller = Completer();

  late LatLng _originalPosition;
  late CameraPosition _initialPosition;

  // Variables de estado
  MapType _currentMapType = MapType.normal;
  double _currentTilt = 50.0; 

  final List<double> _tilts = [0.0, 45.0, 75.0];
  int _tiltIndex = 1;

  @override
  void initState() {
    super.initState();

    final ScanModel scan = ModalRoute.of(context)!.settings.arguments as ScanModel;
    _originalPosition = scan.getLatng();

    _initialPosition = CameraPosition(
      target: _originalPosition,
      zoom: 17,
      tilt: _currentTilt,
    );
  }

  Future<void> _goToOriginalPosition() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: _originalPosition,
          zoom: 17,
          tilt: _currentTilt,
        ),
      ),
    );
  }

  Future<void> _changeTilt() async {
    setState(() {
      _tiltIndex = (_tiltIndex + 1) % _tilts.length;
      _currentTilt = _tilts[_tiltIndex];
    });

    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: _originalPosition, 
          zoom: 17,
          tilt: _currentTilt,
        ),
      ),
    );
  }

  Future<void> _toggleMapType() async {
    setState(() {
      _currentMapType = _currentMapType == MapType.normal 
          ? MapType.hybrid 
          : MapType.normal;
    });
  }

  @override
  Widget build(BuildContext context) {
    final ScanModel scan = ModalRoute.of(context)!.settings.arguments as ScanModel;

    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            myLocationButtonEnabled: false,
            myLocationEnabled: true,
            mapType: _currentMapType,
            markers: {
              Marker(
                markerId: const MarkerId('idq'),
                position: scan.getLatng(),
              )
            },
            initialCameraPosition: _initialPosition,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
          ),

          Positioned(
            top: 40,
            right: 16,
            child: Column(
              children: [
                FloatingActionButton.small(
                  heroTag: 'center',
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black87,
                  onPressed: _goToOriginalPosition,
                  child: const Icon(Icons.my_location),
                ),
                const SizedBox(height: 12),

                FloatingActionButton.small(
                  heroTag: 'tilt',
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black87,
                  onPressed: _changeTilt,
                  child: const Icon(Icons.layers),
                ),
              ],
            ),
          ),

          Positioned(
            bottom: 40,
            right: 16,
            child: FloatingActionButton(
              heroTag: 'maptype',
              backgroundColor: Colors.white,
              foregroundColor: Colors.black87,
              onPressed: _toggleMapType,
              child: Icon(
                _currentMapType == MapType.normal 
                    ? Icons.satellite_alt 
                    : Icons.map,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
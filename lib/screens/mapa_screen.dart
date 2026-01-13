import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:qr_scan/models/scan_model.dart';

class MapaScreen extends StatefulWidget {
  const MapaScreen({super.key});

  @override
  State<MapaScreen> createState() => _MapaScreenState();
}

class _MapaScreenState extends State<MapaScreen> {
  final Completer<GoogleMapController> _controller = Completer();

  late LatLng _originalPosition;
  late CameraPosition _initialPosition;

  MapType _currentMapType = MapType.normal;
  double _currentTilt = 50.0;
  final List<double> _tilts = [0.0, 45.0, 75.0];
  int _tiltIndex = 1;

  @override
  Widget build(BuildContext context) {
    final scan = ModalRoute.of(context)!.settings.arguments as ScanModel;

    _originalPosition = scan.getLatng();
    _initialPosition = CameraPosition(
      target: _originalPosition,
      zoom: 17.5,
      tilt: _currentTilt,
    );

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
                position: _originalPosition,
                icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRose), // color bonito
              ),
            },
            initialCameraPosition: _initialPosition,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
            zoomControlsEnabled: false,
            compassEnabled: true,
          ),

          Positioned(
            top: 50,
            right: 16,
            child: Column(
              children: [
                _buildMapButton(
                  icon: Icons.my_location,
                  onPressed: _goToOriginalPosition,
                  tooltip: 'Centrar marcador',
                ),
                const SizedBox(height: 12),

                _buildMapButton(
                  icon: Icons.layers,
                  onPressed: _changeTilt,
                  tooltip: 'Cambiar inclinación',
                ),
              ],
            ),
          ),

          Positioned(
            bottom: 40,
            right: 16,
            child: _buildMapButton(
              icon: _currentMapType == MapType.normal ? Icons.satellite_alt : Icons.map,
              onPressed: _toggleMapType,
              tooltip: _currentMapType == MapType.normal ? 'Ver satélite' : 'Ver mapa',
              size: 56,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapButton({
    required IconData icon,
    required VoidCallback onPressed,
    required String tooltip,
    double size = 48,
  }) {
    return Material(
      elevation: 6,
      shape: const CircleBorder(),
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: onPressed,
        child: Tooltip(
          message: tooltip,
          child: Container(
            width: size,
            height: size,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Colors.deepPurple,
              size: size * 0.55,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _goToOriginalPosition() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: _originalPosition,
          zoom: 17.5,
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
          zoom: 17.5,
          tilt: _currentTilt,
        ),
      ),
    );
  }

  void _toggleMapType() {
    setState(() {
      _currentMapType = _currentMapType == MapType.normal
          ? MapType.hybrid
          : MapType.normal;
    });
  }
}
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapPickerPage extends StatefulWidget {
  const MapPickerPage({super.key});

  @override
  State<MapPickerPage> createState() => _MapPickerPageState();
}

class _MapPickerPageState extends State<MapPickerPage> {
  GoogleMapController? _mapController;
  LatLng _pickedLocation = const LatLng(10.7769, 106.7009); // HCM mặc định

  void _onMapTap(LatLng pos) {
    setState(() {
      _pickedLocation = pos;
    });
  }

  void _confirmSelection() {
    Navigator.pop(context, _pickedLocation);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chọn địa chỉ"),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _confirmSelection,
          )
        ],
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: _pickedLocation,
          zoom: 14,
        ),
        onMapCreated: (controller) => _mapController = controller,
        onTap: _onMapTap,
        markers: {
          Marker(
            markerId: const MarkerId("picked"),
            position: _pickedLocation,
          )
        },
      ),
    );
  }
}

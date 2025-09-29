import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../viewmodels/location_viewmodel.dart';

class MapView extends StatelessWidget {
  const MapView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LocationViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final location = viewModel.location;

        if (location == null) {
          return const Center(
            child: Text('Não foi possível obter a localização.'),
          );
        }

        return FlutterMap(
          options: MapOptions(
            initialCenter: LatLng(location.latitude, location.longitude),
            initialZoom: 16,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
              subdomains: const ['a', 'b', 'c'],
              userAgentPackageName: 'br.edu.ifsul.flutter_mapas_osm',
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: LatLng(location.latitude, location.longitude),
                  width: 40,
                  height: 40,
                  child: const Icon(
                    Icons.location_pin,
                    color: Colors.red,
                    size: 40,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

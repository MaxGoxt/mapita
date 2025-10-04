import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../viewmodels/location_viewmodel.dart';
import 'package:geocoding/geocoding.dart';

class MapView extends StatefulWidget {
  const MapView({super.key});

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  final TextEditingController _searchController = TextEditingController();
  final MapController _mapController = MapController();

  Future<void> _searchLocation(LocationViewModel viewModel) async {
    final query = _searchController.text;
    if (query.isEmpty) return;

    try {
      List<Location> locations = await locationFromAddress(query);
      if (locations.isNotEmpty) {
        final loc = locations.first;
        viewModel.updateLocation(loc.latitude, loc.longitude);
        _mapController.move(LatLng(loc.latitude, loc.longitude), 16);
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Endereço não encontrado')));
    }
  }

  @override
  void initState() {
    super.initState();
    final viewModel = Provider.of<LocationViewModel>(context, listen: false);
    viewModel.startLocationUpdates(_mapController);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LocationViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final location = viewModel.location;

        if (location.isEmpty) {
          return const Center(
            child: Text('Não foi possível obter a localização.'),
          );
        }

        return Column(
          children: [
            // Barra de busca
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Digite um endereço',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(50)),
                        ),
                        suffix: IconButton(
                          icon: Icon(Icons.search),
                          onPressed: () => _searchLocation(viewModel),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Mapa
            Expanded(
              child: FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: LatLng(
                    location[0].latitude,
                    location[0].longitude,
                  ),
                  initialZoom: 16,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                    subdomains: const ['a', 'b', 'c'],
                    userAgentPackageName: 'uy.com.mapa.mapita',
                  ),
                  MarkerLayer(markers: viewModel.markers),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

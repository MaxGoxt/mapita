import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../models/location_model.dart';
import '../services/location_service.dart';

class LocationViewModel extends ChangeNotifier {
  final LocationService _locationService = LocationService();

  List<LocationModel> _location = [];
  bool _isLoading = true;
  List<Marker> _markers = [];

  List<LocationModel> get location => _location;
  bool get isLoading => _isLoading;
  List<Marker> get markers => _markers;

  Future<void> fetchLocation() async {
    _isLoading = true;
    notifyListeners();

    Position? position = await _locationService.getCurrentPosition().timeout(const Duration(seconds: 30));

    if (position != null) {
      _location = [
        LocationModel(
          latitude: position.latitude,
          longitude: position.longitude,
        ),
      ];
      _markers = [
        Marker(
          point: LatLng(position.latitude, position.longitude),
          width: 40,
          height: 40,
          child: const Icon(Icons.person_pin_circle_rounded, color: Color.fromARGB(255, 7, 28, 161), size: 40),
        ),
      ];
    }

    _isLoading = false;
    notifyListeners();
  }

  void updateLocation(double latitude, double longitude) {
    if (_location.isNotEmpty && _location.length > 1) {
      _location[1] = LocationModel(latitude: latitude, longitude: longitude);
      _markers[1] = Marker(
        point: LatLng(latitude, longitude),
        width: 40,
        height: 40,
        child: const Icon(Icons.location_pin, color: Colors.red, size: 40),
      );
      notifyListeners();
    } else {
      addLocation(latitude, longitude);
    }
  }

  void addLocation(double latitude, double longitude) {
    _location.add(LocationModel(latitude: latitude, longitude: longitude));
    _markers.add(
      Marker(
        point: LatLng(latitude, longitude),
        width: 40,
        height: 40,
        child: const Icon(Icons.location_pin, color: Colors.red, size: 40),
      ),
    );
    notifyListeners();
  }

  void startLocationUpdates() {
    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 10,
      ),
    ).listen((Position position) {
      _location[0] = LocationModel(
        latitude: position.latitude,
        longitude: position.longitude,
      );
      notifyListeners();
    });
  }
}

import 'package:catch_dating_app/locations/domain/location_coordinate.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'device_location.g.dart';

@Riverpod(keepAlive: true)
class DeviceLocation extends _$DeviceLocation {
  @override
  Future<LocationCoordinate?> build() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
          timeLimit: Duration(seconds: 10),
        ),
      );
      return LocationCoordinate(position.latitude, position.longitude);
    } catch (error, stack) {
      debugPrint('[ERROR] DeviceLocation.build: $error\n$stack');
      return null;
    }
  }
}

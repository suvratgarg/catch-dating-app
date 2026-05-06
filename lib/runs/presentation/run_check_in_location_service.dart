import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

final runCheckInLocationServiceProvider = Provider<RunCheckInLocationService>(
  (ref) => const GeolocatorRunCheckInLocationService(),
);

class RunCheckInLocation {
  const RunCheckInLocation({required this.latitude, required this.longitude});

  final double latitude;
  final double longitude;
}

abstract interface class RunCheckInLocationService {
  Future<RunCheckInLocation> getCurrentLocation();
}

class GeolocatorRunCheckInLocationService implements RunCheckInLocationService {
  const GeolocatorRunCheckInLocationService();

  @override
  Future<RunCheckInLocation> getCurrentLocation() async {
    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 15),
      ),
    );

    return RunCheckInLocation(
      latitude: position.latitude,
      longitude: position.longitude,
    );
  }
}

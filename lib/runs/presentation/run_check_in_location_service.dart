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
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw StateError(
        'Turn on location services to check in at the run. '
        'You can still ask the host to mark attendance.',
      );
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied) {
      throw StateError(
        'Allow location access to check in. '
        'You can still ask the host to mark attendance.',
      );
    }
    if (permission == LocationPermission.deniedForever) {
      throw StateError(
        'Location access is blocked. Enable it in Settings or ask the host '
        'to mark attendance.',
      );
    }

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

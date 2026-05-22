import 'package:geolocator/geolocator.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'event_check_in_location_service.g.dart';

@Riverpod(keepAlive: true)
EventCheckInLocationService eventCheckInLocationService(Ref ref) =>
    const GeolocatorEventCheckInLocationService();

class EventCheckInLocation {
  const EventCheckInLocation({required this.latitude, required this.longitude});

  final double latitude;
  final double longitude;
}

abstract interface class EventCheckInLocationService {
  Future<EventCheckInLocation> getCurrentLocation();
}

class GeolocatorEventCheckInLocationService
    implements EventCheckInLocationService {
  const GeolocatorEventCheckInLocationService();

  @override
  Future<EventCheckInLocation> getCurrentLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw StateError(
        'Turn on location services to check in at the event. '
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

    return EventCheckInLocation(
      latitude: position.latitude,
      longitude: position.longitude,
    );
  }
}

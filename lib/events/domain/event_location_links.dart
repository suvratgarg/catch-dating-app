import 'package:catch_dating_app/events/domain/event.dart';

Uri directionsUriForEvent(Event event) {
  final lat = event.effectiveStartingPointLat;
  final lng = event.effectiveStartingPointLng;
  return _directionsUri(latitude: lat, longitude: lng);
}

Uri _directionsUri({required double latitude, required double longitude}) {
  final destination = '$latitude,$longitude';
  return Uri.https('www.google.com', '/maps/dir/', {
    'api': '1',
    'destination': destination,
    'travelmode': 'walking',
  });
}

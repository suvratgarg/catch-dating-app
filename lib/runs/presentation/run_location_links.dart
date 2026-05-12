import 'package:catch_dating_app/runs/domain/run.dart';

Uri directionsUriForRun(Run run) {
  final lat = run.startingPointLat;
  final lng = run.startingPointLng;

  if (lat != null && lng != null) {
    return _directionsUri(latitude: lat, longitude: lng);
  }

  return _searchUri(query: run.meetingPoint);
}

Uri _directionsUri({required double latitude, required double longitude}) {
  final destination = '$latitude,$longitude';
  return Uri.https('www.google.com', '/maps/dir/', {
    'api': '1',
    'destination': destination,
    'travelmode': 'walking',
  });
}

Uri _searchUri({required String query}) {
  return Uri.https('www.google.com', '/maps/search/', {
    'api': '1',
    'query': query,
  });
}

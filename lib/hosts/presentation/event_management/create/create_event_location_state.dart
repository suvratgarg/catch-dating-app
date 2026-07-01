import 'package:catch_dating_app/events/domain/event_meeting_location.dart';
import 'package:catch_dating_app/locations/domain/location_coordinate.dart';

class CreateEventLocationState {
  const CreateEventLocationState({
    this.startingPoint,
    this.meetingLocationAddress,
    this.meetingLocationPlaceId,
  });

  final LocationCoordinate? startingPoint;
  final String? meetingLocationAddress;
  final String? meetingLocationPlaceId;

  bool get hasStartingPoint => startingPoint != null;

  LocationCoordinate? initialCenter(LocationCoordinate? deviceLocation) {
    return startingPoint ?? deviceLocation;
  }

  String? initialLabel({required String? meetingPoint}) {
    if (!hasStartingPoint) return null;
    return _trimmedTextOrNull(meetingPoint);
  }

  CreateEventLocationSelectionResult selectLocation({
    required LocationCoordinate coordinate,
    required String? displayName,
    required String? address,
    required String? placeId,
  }) {
    return CreateEventLocationSelectionResult(
      state: CreateEventLocationState(
        startingPoint: coordinate,
        meetingLocationAddress: _trimmedTextOrNull(address),
        meetingLocationPlaceId: _trimmedTextOrNull(placeId),
      ),
      meetingPointText: _trimmedTextOrNull(displayName),
    );
  }

  EventMeetingLocation? meetingLocation({
    required String? meetingPoint,
    required String? notes,
  }) {
    final coordinate = startingPoint;
    final name = _trimmedTextOrNull(meetingPoint);
    if (coordinate == null || name == null) return null;
    return EventMeetingLocation(
      name: name,
      address: meetingLocationAddress,
      placeId: meetingLocationPlaceId,
      latitude: coordinate.latitude,
      longitude: coordinate.longitude,
      notes: _trimmedTextOrNull(notes),
    ).normalized();
  }
}

class CreateEventLocationSelectionResult {
  const CreateEventLocationSelectionResult({
    required this.state,
    required this.meetingPointText,
  });

  final CreateEventLocationState state;
  final String? meetingPointText;
}

String? _trimmedTextOrNull(String? text) {
  final trimmed = text?.trim();
  if (trimmed == null || trimmed.isEmpty) return null;
  return trimmed;
}

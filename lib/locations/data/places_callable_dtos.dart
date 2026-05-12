import 'package:catch_dating_app/locations/domain/location_coordinate.dart';

final class PlacesAutocompleteCallableRequest {
  const PlacesAutocompleteCallableRequest({
    required this.input,
    required this.sessionToken,
    required this.bias,
  });

  final String input;
  final String sessionToken;
  final LocationCoordinate? bias;

  Map<String, Object?> toJson() => {
    'input': input,
    'sessionToken': sessionToken,
    if (bias != null) ...{
      'latitude': bias!.latitude,
      'longitude': bias!.longitude,
    },
  };
}

final class PlacesAutocompleteCallableResponse {
  const PlacesAutocompleteCallableResponse({required this.predictions});

  factory PlacesAutocompleteCallableResponse.fromCallableData(Object? data) {
    if (data case final Map<Object?, Object?> map) {
      final predictions = map['predictions'];
      if (predictions is List<Object?>) {
        return PlacesAutocompleteCallableResponse(
          predictions: predictions
              .whereType<Map<Object?, Object?>>()
              .map(PlaceAutocompleteSuggestion.fromJson)
              .toList(growable: false),
        );
      }
    }

    return const PlacesAutocompleteCallableResponse(predictions: []);
  }

  final List<PlaceAutocompleteSuggestion> predictions;
}

final class PlaceDetailsCallableRequest {
  const PlaceDetailsCallableRequest({
    required this.placeId,
    required this.sessionToken,
  });

  final String placeId;
  final String sessionToken;

  Map<String, Object?> toJson() => {
    'placeId': placeId,
    'sessionToken': sessionToken,
  };
}

final class PlaceDetailsCallableResponse {
  const PlaceDetailsCallableResponse({required this.place});

  factory PlaceDetailsCallableResponse.fromCallableData(Object? data) {
    if (data case final Map<Object?, Object?> map) {
      final place = map['place'];
      if (place is Map<Object?, Object?>) {
        return PlaceDetailsCallableResponse(
          place: PlaceDetails.fromJson(place),
        );
      }
    }

    throw StateError('Place details response was missing place data.');
  }

  final PlaceDetails place;
}

class PlaceAutocompleteSuggestion {
  const PlaceAutocompleteSuggestion({
    required this.placeId,
    required this.description,
    required this.mainText,
    required this.secondaryText,
  });

  factory PlaceAutocompleteSuggestion.fromJson(Map<Object?, Object?> json) {
    return PlaceAutocompleteSuggestion(
      placeId: json['placeId'] as String? ?? '',
      description: json['description'] as String? ?? '',
      mainText: json['mainText'] as String? ?? '',
      secondaryText: json['secondaryText'] as String? ?? '',
    );
  }

  final String placeId;
  final String description;
  final String mainText;
  final String secondaryText;
}

class PlaceDetails {
  const PlaceDetails({
    required this.placeId,
    required this.displayName,
    required this.formattedAddress,
    required this.location,
  });

  factory PlaceDetails.fromJson(Map<Object?, Object?> json) {
    final location = LocationCoordinate.fromNullable(
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );
    if (location == null) {
      throw StateError('Place details response was missing coordinates.');
    }

    return PlaceDetails(
      placeId: json['placeId'] as String? ?? '',
      displayName: json['displayName'] as String? ?? '',
      formattedAddress: json['formattedAddress'] as String? ?? '',
      location: location,
    );
  }

  final String placeId;
  final String displayName;
  final String formattedAddress;
  final LocationCoordinate location;
}

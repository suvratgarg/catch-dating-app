import 'package:catch_dating_app/locations/domain/location_coordinate.dart';
import 'package:catch_dating_app/locations/domain/place.dart';

final class PlacesAutocompleteCallableRequest {
  const PlacesAutocompleteCallableRequest({
    required this.input,
    required this.sessionToken,
    required this.bias,
    this.countryIsoCode,
  });

  final String input;
  final String sessionToken;
  final LocationCoordinate? bias;
  final String? countryIsoCode;

  Map<String, Object?> toJson() => {
    'input': input,
    'sessionToken': sessionToken,
    if (countryIsoCode != null) 'countryIsoCode': countryIsoCode,
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

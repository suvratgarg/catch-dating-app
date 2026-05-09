import 'package:catch_dating_app/core/firebase_providers.dart';
import 'package:catch_dating_app/locations/domain/location_coordinate.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final placesRepositoryProvider = Provider<PlacesRepository>((ref) {
  return FirebasePlacesRepository(ref.watch(firebaseFunctionsProvider));
});

class PlaceAutocompleteSuggestion {
  const PlaceAutocompleteSuggestion({
    required this.placeId,
    required this.description,
    required this.mainText,
    required this.secondaryText,
  });

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

  final String placeId;
  final String displayName;
  final String formattedAddress;
  final LocationCoordinate location;
}

abstract interface class PlacesRepository {
  Future<List<PlaceAutocompleteSuggestion>> autocomplete({
    required String input,
    required String sessionToken,
    LocationCoordinate? bias,
  });

  Future<PlaceDetails> details({
    required String placeId,
    required String sessionToken,
  });
}

class FirebasePlacesRepository implements PlacesRepository {
  const FirebasePlacesRepository(this._functions);

  final FirebaseFunctions _functions;

  @override
  Future<List<PlaceAutocompleteSuggestion>> autocomplete({
    required String input,
    required String sessionToken,
    LocationCoordinate? bias,
  }) async {
    final payload = <String, Object?>{
      'input': input,
      'sessionToken': sessionToken,
      if (bias != null) ...{
        'latitude': bias.latitude,
        'longitude': bias.longitude,
      },
    };
    final result = await _functions
        .httpsCallable('placesAutocomplete')
        .call<Map<Object?, Object?>>(payload);
    final data = result.data;
    final predictions = data['predictions'];
    if (predictions is! List<Object?>) {
      return const [];
    }
    return predictions
        .whereType<Map<Object?, Object?>>()
        .map(_suggestionFromMap)
        .toList(growable: false);
  }

  @override
  Future<PlaceDetails> details({
    required String placeId,
    required String sessionToken,
  }) async {
    final result = await _functions
        .httpsCallable('placeDetails')
        .call<Map<Object?, Object?>>({
          'placeId': placeId,
          'sessionToken': sessionToken,
        });
    final place = result.data['place'];
    if (place is! Map<Object?, Object?>) {
      throw StateError('Place details response was missing place data.');
    }
    return _detailsFromMap(place);
  }
}

PlaceAutocompleteSuggestion _suggestionFromMap(Map<Object?, Object?> json) {
  return PlaceAutocompleteSuggestion(
    placeId: json['placeId'] as String? ?? '',
    description: json['description'] as String? ?? '',
    mainText: json['mainText'] as String? ?? '',
    secondaryText: json['secondaryText'] as String? ?? '',
  );
}

PlaceDetails _detailsFromMap(Map<Object?, Object?> json) {
  final latitude = (json['latitude'] as num?)?.toDouble();
  final longitude = (json['longitude'] as num?)?.toDouble();
  if (latitude == null || longitude == null) {
    throw StateError('Place details response was missing coordinates.');
  }

  return PlaceDetails(
    placeId: json['placeId'] as String? ?? '',
    displayName: json['displayName'] as String? ?? '',
    formattedAddress: json['formattedAddress'] as String? ?? '',
    location: LocationCoordinate(latitude, longitude),
  );
}

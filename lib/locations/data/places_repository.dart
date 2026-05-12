import 'package:catch_dating_app/core/firebase_providers.dart';
import 'package:catch_dating_app/locations/data/places_callable_dtos.dart';
import 'package:catch_dating_app/locations/domain/location_coordinate.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

export 'places_callable_dtos.dart'
    show PlaceAutocompleteSuggestion, PlaceDetails;

final placesRepositoryProvider = Provider<PlacesRepository>((ref) {
  return FirebasePlacesRepository(ref.watch(firebaseFunctionsProvider));
});

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
    final payload = PlacesAutocompleteCallableRequest(
      input: input,
      sessionToken: sessionToken,
      bias: bias,
    );
    final result = await _functions
        .httpsCallable('placesAutocomplete')
        .call<Object?>(payload.toJson());
    return PlacesAutocompleteCallableResponse.fromCallableData(
      result.data,
    ).predictions;
  }

  @override
  Future<PlaceDetails> details({
    required String placeId,
    required String sessionToken,
  }) async {
    final payload = PlaceDetailsCallableRequest(
      placeId: placeId,
      sessionToken: sessionToken,
    );
    final result = await _functions
        .httpsCallable('placeDetails')
        .call<Object?>(payload.toJson());
    return PlaceDetailsCallableResponse.fromCallableData(result.data).place;
  }
}

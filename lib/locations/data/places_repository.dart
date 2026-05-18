import 'package:catch_dating_app/core/backend_error_util.dart';
import 'package:catch_dating_app/core/firebase_providers.dart';
import 'package:catch_dating_app/exceptions/app_exception.dart';
import 'package:catch_dating_app/locations/data/places_callable_dtos.dart';
import 'package:catch_dating_app/locations/domain/location_coordinate.dart';
import 'package:catch_dating_app/locations/domain/place.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

export 'package:catch_dating_app/locations/domain/place.dart'
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
    return withBackendErrorContext(
      () async {
        final result = await _functions
            .httpsCallable('placesAutocomplete')
            .call<Object?>(payload.toJson());
        return PlacesAutocompleteCallableResponse.fromCallableData(
          result.data,
        ).predictions;
      },
      context: const BackendErrorContext(
        service: BackendService.functions,
        action: 'load place suggestions',
        resource: 'places',
      ),
    );
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
    return withBackendErrorContext(
      () async {
        final result = await _functions
            .httpsCallable('placeDetails')
            .call<Object?>(payload.toJson());
        return PlaceDetailsCallableResponse.fromCallableData(result.data).place;
      },
      context: const BackendErrorContext(
        service: BackendService.functions,
        action: 'load place details',
        resource: 'places',
      ),
    );
  }
}

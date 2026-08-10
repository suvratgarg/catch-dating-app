import 'package:catch_dating_app/locations/data/places_repository.dart';
import 'package:catch_dating_app/locations/domain/location_coordinate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final locationPickerControllerProvider = Provider<LocationPickerController>(
  (ref) => LocationPickerController(ref.watch(placesRepositoryProvider)),
);

/// Owns remote place lookup operations for the location picker presentation.
class LocationPickerController {
  const LocationPickerController(this._placesRepository);

  final PlacesRepository _placesRepository;

  Future<List<PlaceAutocompleteSuggestion>> autocomplete({
    required String input,
    required String sessionToken,
    required LocationCoordinate bias,
    String? countryIsoCode,
  }) => _placesRepository.autocomplete(
    input: input,
    sessionToken: sessionToken,
    bias: bias,
    countryIsoCode: countryIsoCode,
  );

  Future<PlaceDetails> details({
    required String placeId,
    required String sessionToken,
  }) => _placesRepository.details(placeId: placeId, sessionToken: sessionToken);
}

import 'package:flutter/foundation.dart';

abstract final class CreateEventFormKeys {
  static const distance = ValueKey('create-event-distance-field');
  static const capacity = ValueKey('create-event-capacity-field');
  static const price = ValueKey('create-event-price-field');
  static const description = ValueKey('create-event-description-field');
  static const meetingPoint = ValueKey('create-event-meeting-point-field');
  static const locationDetails = ValueKey(
    'create-event-location-details-field',
  );
  static const datePicker = ValueKey('create-event-date-picker');
  static const timePicker = ValueKey('create-event-time-picker');
  static const mapPicker = ValueKey('create-event-map-picker');
  static const minAge = ValueKey('create-event-min-age-field');
  static const maxAge = ValueKey('create-event-max-age-field');
  static const maxMen = ValueKey('create-event-max-men-field');
  static const maxWomen = ValueKey('create-event-max-women-field');

  static ValueKey<String> admissionPreset(String presetName) =>
      ValueKey('create-event-admission-preset-$presetName');

  static ValueKey<String> deleteDraft(String draftId) =>
      ValueKey('create-event-delete-draft-$draftId');
}

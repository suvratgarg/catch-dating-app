import 'package:flutter/foundation.dart';

abstract final class CreateRunFormKeys {
  static const distance = ValueKey('create-run-distance-field');
  static const capacity = ValueKey('create-run-capacity-field');
  static const price = ValueKey('create-run-price-field');
  static const description = ValueKey('create-run-description-field');
  static const meetingPoint = ValueKey('create-run-meeting-point-field');
  static const locationDetails = ValueKey('create-run-location-details-field');
  static const datePicker = ValueKey('create-run-date-picker');
  static const timePicker = ValueKey('create-run-time-picker');
  static const mapPicker = ValueKey('create-run-map-picker');
  static const minAge = ValueKey('create-run-min-age-field');
  static const maxAge = ValueKey('create-run-max-age-field');
  static const maxMen = ValueKey('create-run-max-men-field');
  static const maxWomen = ValueKey('create-run-max-women-field');

  static ValueKey<String> admissionPreset(String presetName) =>
      ValueKey('create-run-admission-preset-$presetName');

  static ValueKey<String> deleteDraft(String draftId) =>
      ValueKey('create-run-delete-draft-$draftId');
}

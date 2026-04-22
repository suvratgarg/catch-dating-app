import 'dart:math' as math;

const minimumProfileAge = 18;
const maximumPreferredMatchAge = 99;

int calculateAge(DateTime dateOfBirth, {DateTime? today}) {
  final currentDate = today ?? DateTime.now();
  int age = currentDate.year - dateOfBirth.year;
  if (currentDate.month < dateOfBirth.month ||
      (currentDate.month == dateOfBirth.month &&
          currentDate.day < dateOfBirth.day)) {
    age--;
  }
  return age;
}

DateTime latestAllowedDateOfBirth({
  int minimumAge = minimumProfileAge,
  DateTime? today,
}) {
  final now = today ?? DateTime.now();
  return DateTime(now.year - minimumAge, now.month, now.day);
}

bool isAtLeastAge(
  DateTime dateOfBirth, {
  int minimumAge = minimumProfileAge,
  DateTime? today,
}) {
  final normalizedDob = DateTime(
    dateOfBirth.year,
    dateOfBirth.month,
    dateOfBirth.day,
  );
  return !normalizedDob.isAfter(
    latestAllowedDateOfBirth(minimumAge: minimumAge, today: today),
  );
}

bool isValidAgePreferenceRange({
  required int minAgePreference,
  required int maxAgePreference,
  int minimumAge = minimumProfileAge,
  int maximumAge = maximumPreferredMatchAge,
}) {
  return minAgePreference >= minimumAge &&
      minAgePreference <= maximumAge &&
      maxAgePreference >= minimumAge &&
      maxAgePreference <= maximumAge &&
      minAgePreference <= maxAgePreference;
}

({int minAge, int maxAge}) normalizeAgePreferenceRange({
  required int minAgePreference,
  required int maxAgePreference,
  int minimumAge = minimumProfileAge,
  int maximumAge = maximumPreferredMatchAge,
}) {
  final normalizedMin = math
      .min(minAgePreference, maxAgePreference)
      .clamp(minimumAge, maximumAge);
  final normalizedMax = math
      .max(minAgePreference, maxAgePreference)
      .clamp(normalizedMin, maximumAge);

  return (minAge: normalizedMin, maxAge: normalizedMax);
}

String? validateAgePreferenceInput(
  String? value, {
  required String otherValue,
  required bool isMinimumField,
  int minimumAge = minimumProfileAge,
  int maximumAge = maximumPreferredMatchAge,
}) {
  final parsedValue = _parseAgePreference(value);
  if (parsedValue == null) return null;

  if (parsedValue < minimumAge || parsedValue > maximumAge) {
    return 'Enter an age between $minimumAge and $maximumAge';
  }

  final parsedOtherValue = _parseAgePreference(otherValue);
  if (parsedOtherValue == null) return null;

  if (isMinimumField && parsedValue > parsedOtherValue) {
    return 'Min age must be less than or equal to max age';
  }

  if (!isMinimumField && parsedValue < parsedOtherValue) {
    return 'Max age must be greater than or equal to min age';
  }

  return null;
}

int? parseAgePreference(String value) => _parseAgePreference(value);

int? _parseAgePreference(String? value) {
  final trimmed = value?.trim() ?? '';
  if (trimmed.isEmpty) return null;
  return int.tryParse(trimmed);
}

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


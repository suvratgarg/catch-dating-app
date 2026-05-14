import 'dart:math' as math;

const minimumProfileAge = 18;
const preferredMatchAgeOpenEndedDisplayAge = 60;
const maximumPreferredMatchAge = 99;
const minimumHeightCm = 120;
const maximumHeightCm = 220;
const defaultHeightCm = 170;
const maximumProfilePromptAnswerLength = 300;
const maximumPhotoPromptCaptionLength = 140;
const maximumConsecutivePromptNewlines = 2;
@Deprecated('Use maximumProfilePromptAnswerLength.')
const maximumBioLength = maximumProfilePromptAnswerLength;
@Deprecated('Use maximumConsecutivePromptNewlines.')
const maximumConsecutiveBioNewlines = maximumConsecutivePromptNewlines;

final RegExp _stackedPromptNewlinePattern = RegExp(r'\n[ \t]*\n[ \t]*\n+');
final RegExp _stackedPromptNewlineCollapsePattern = RegExp(
  r'\n[ \t]*\n(?:[ \t]*\n)+',
);

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

String? validateRequiredProfileName(String? value, {required String label}) {
  if ((value ?? '').trim().isEmpty) return '$label is required';
  return null;
}

String? validateRequiredDisplayName(String? value) =>
    validateRequiredProfileName(value, label: 'Display name');

String? validateRequiredPhoneNumber(String? value) {
  if ((value ?? '').trim().isEmpty) return 'Phone is required';
  return null;
}

String? validateOptionalEmail(String? value) {
  final email = (value ?? '').trim();
  if (email.isEmpty) return null;
  final valid = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
  return valid ? null : 'Enter a valid email';
}

String? validateOptionalBio(String? value) {
  return validateOptionalProfilePromptAnswer(value);
}

String? validateOptionalProfilePromptAnswer(String? value) {
  final answer = collapseStackedPromptBlankLines(value ?? '').trim();
  if (answer.length > maximumProfilePromptAnswerLength) {
    return 'Prompt must be $maximumProfilePromptAnswerLength characters or fewer';
  }
  return null;
}

String? validateOptionalPhotoPromptCaption(String? value) {
  final caption = collapseStackedPromptBlankLines(value ?? '').trim();
  if (caption.length > maximumPhotoPromptCaptionLength) {
    return 'Caption must be $maximumPhotoPromptCaptionLength characters or fewer';
  }
  return null;
}

String normalizeBioLineEndings(String value) =>
    normalizePromptLineEndings(value);

String normalizePromptLineEndings(String value) =>
    value.replaceAll('\r\n', '\n').replaceAll('\r', '\n');

String collapseStackedBioBlankLines(String value) {
  return collapseStackedPromptBlankLines(value);
}

String collapseStackedPromptBlankLines(String value) {
  return normalizePromptLineEndings(
    value,
  ).replaceAll(_stackedPromptNewlineCollapsePattern, '\n\n');
}

bool hasStackedBioBlankLines(String value) => hasStackedPromptBlankLines(value);

bool hasStackedPromptBlankLines(String value) =>
    _stackedPromptNewlinePattern.hasMatch(normalizePromptLineEndings(value));

String normalizeInstagramHandle(String value) {
  final trimmed = value.trim();
  final withoutAt = trimmed.startsWith('@') ? trimmed.substring(1) : trimmed;
  return withoutAt.trim();
}

String? validateOptionalInstagramHandle(String? value) {
  final handle = normalizeInstagramHandle(value ?? '');
  if (handle.isEmpty) return null;
  final valid = RegExp(r'^[A-Za-z0-9._]{1,30}$').hasMatch(handle);
  return valid ? null : 'Enter a valid Instagram handle';
}

String? validateRequiredDateOfBirth(DateTime? dateOfBirth) {
  if (dateOfBirth == null) {
    return 'Please select your date of birth';
  }
  if (!isAtLeastAge(dateOfBirth)) {
    return 'You must be at least $minimumProfileAge years old';
  }
  return null;
}

String? validateOptionalHeightCm(int? heightCm) {
  if (heightCm == null) {
    return null;
  }
  if (heightCm < minimumHeightCm) {
    return 'Height must be at least $minimumHeightCm cm';
  }
  if (heightCm > maximumHeightCm) {
    return 'Height must be at most $maximumHeightCm cm';
  }
  return null;
}

int normalizeHeightCm(int? heightCm) =>
    (heightCm ?? defaultHeightCm).clamp(minimumHeightCm, maximumHeightCm);

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

String formatPreferredMatchAge(int age) =>
    age >= preferredMatchAgeOpenEndedDisplayAge
    ? '$preferredMatchAgeOpenEndedDisplayAge+'
    : '$age';

int preferredMatchAgeStorageValue(int displayAge) =>
    displayAge >= preferredMatchAgeOpenEndedDisplayAge
    ? maximumPreferredMatchAge
    : displayAge;

String formatPreferredMatchAgeRange({
  required int minAgePreference,
  required int maxAgePreference,
}) {
  final range = normalizeAgePreferenceRange(
    minAgePreference: minAgePreference,
    maxAgePreference: maxAgePreference,
  );
  return '${range.minAge} – ${formatPreferredMatchAge(range.maxAge)}';
}

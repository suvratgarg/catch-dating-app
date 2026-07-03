import 'package:catch_dating_app/onboarding/presentation/onboarding_step.dart';
import 'package:catch_dating_app/user_profile/domain/profile_validation.dart';
import 'package:flutter/material.dart';

class OnboardingNameDobState {
  const OnboardingNameDobState({
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.countryCode,
    required this.dateOfBirth,
    required this.step,
    required this.today,
  });

  factory OnboardingNameDobState.fromDraft({
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String countryCode,
    required DateTime? dateOfBirth,
    required OnboardingStep step,
    required DateTime today,
  }) {
    return OnboardingNameDobState(
      firstName: firstName,
      lastName: lastName,
      phoneNumber: phoneNumber,
      countryCode: countryCode,
      dateOfBirth: dateOfBirth,
      step: step,
      today: today,
    );
  }

  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String countryCode;
  final DateTime? dateOfBirth;
  final OnboardingStep step;
  final DateTime today;

  bool get shouldAutofocus => step == OnboardingStep.nameDob;

  String get phonePrefix => '$countryCode ';

  int? get age =>
      dateOfBirth == null ? null : calculateAge(dateOfBirth!, today: today);

  String? get ageSuffix => age == null ? null : 'AGE $age';

  String get dateText => dateOfBirth == null ? '' : formatDate(dateOfBirth!);

  OnboardingNameDobDatePickerRequest get datePickerRequest {
    return OnboardingNameDobDatePickerRequest(
      initialDate: dateOfBirth ?? DateTime(2000),
      firstDate: DateTime(1920),
      lastDate: latestAllowedDateOfBirth(today: today),
      title: 'Date of birth',
    );
  }

  String? validateFirstName(String? value) =>
      validateRequiredProfileName(value, label: 'First name');

  String? validateLastName(String? value) =>
      validateRequiredProfileName(value, label: 'Last name');

  String? validateDateOfBirth() =>
      validateRequiredDateOfBirth(dateOfBirth, today: today);

  String? validatePhoneNumber(String? value) =>
      validateRequiredPhoneNumber(value);

  OnboardingNameDobSubmitIntent? submitIntent({
    required String firstName,
    required String lastName,
    required String phoneNumber,
  }) {
    final dateOfBirth = this.dateOfBirth;
    if (dateOfBirth == null) return null;

    return OnboardingNameDobSubmitIntent(
      firstName: firstName.trim(),
      lastName: lastName.trim(),
      phoneNumber: phoneNumber.trim(),
      countryCode: countryCode,
      dateOfBirth: dateOfBirth,
    );
  }

  static String formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '$day ${months[date.month - 1]} ${date.year}';
  }
}

class OnboardingNameDobDatePickerRequest {
  const OnboardingNameDobDatePickerRequest({
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
    required this.title,
  });

  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final String title;
}

class OnboardingNameDobSubmitIntent {
  const OnboardingNameDobSubmitIntent({
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.countryCode,
    required this.dateOfBirth,
  });

  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String countryCode;
  final DateTime dateOfBirth;
}

class OnboardingNameDobTextControllers {
  const OnboardingNameDobTextControllers({
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.date,
  });

  final TextEditingController firstName;
  final TextEditingController lastName;
  final TextEditingController phone;
  final TextEditingController date;
}

class OnboardingNameDobCallbacks {
  const OnboardingNameDobCallbacks({
    required this.onPickDate,
    required this.onContinue,
  });

  final void Function(OnboardingNameDobDatePickerRequest request) onPickDate;
  final VoidCallback onContinue;
}

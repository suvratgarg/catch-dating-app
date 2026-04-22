import 'package:catch_dating_app/app_user/domain/app_user.dart';
import 'package:catch_dating_app/core/firestore_converters.dart';
import 'package:catch_dating_app/core/labelled.dart';
import 'package:catch_dating_app/runs/domain/run_constraints.dart';
import 'package:catch_dating_app/runs/domain/run_eligibility.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'run.freezed.dart';
part 'run.g.dart';

enum PaceLevel implements Labelled {
  easy('Easy'),
  moderate('Moderate'),
  fast('Fast'),
  competitive('Competitive');

  const PaceLevel(this.label);
  @override
  final String label;
}

/// The current booking status of a specific run from one user's perspective.
enum RunSignUpStatus {
  /// Run is upcoming, not full, and the user hasn't signed up.
  eligible,

  /// The user has already signed up.
  signedUp,

  /// The run is full and the user is not on the waitlist.
  full,

  /// The run is full and the user is on the waitlist.
  waitlisted,

  /// The user attended this run.
  attended,

  /// The run has started (or ended) and the user did not sign up.
  past,

  /// The user does not meet the run's eligibility constraints (age or gender cap).
  ineligible,
}

@freezed
abstract class Run with _$Run {
  const Run._();

  const factory Run({
    @JsonKey(includeToJson: false) required String id,
    required String runClubId,
    @TimestampConverter() required DateTime startTime,
    @TimestampConverter() required DateTime endTime,
    required String meetingPoint,
    double? startingPointLat,
    double? startingPointLng,
    String? locationDetails,
    required double distanceKm,
    required PaceLevel pace,
    required int capacityLimit,
    required String description,
    required int priceInPaise,
    @Default([]) List<String> signedUpUserIds,
    @Default([]) List<String> attendedUserIds,
    @Default([]) List<String> waitlistUserIds,
    @Default(RunConstraints()) RunConstraints constraints,
    // Denormalized gender counts maintained atomically by Cloud Functions.
    // Keys are Gender enum names: 'man', 'woman', 'nonBinary', 'other'.
    @Default({}) Map<String, int> genderCounts,
  }) = _Run;

  factory Run.fromJson(Map<String, dynamic> json) => _$RunFromJson(json);

  double get distanceMiles => distanceKm * 0.621371;
  int get signedUpCount => signedUpUserIds.length;
  bool get isFull => signedUpUserIds.length >= capacityLimit;
  bool get isFree => priceInPaise == 0;
  bool get isUpcoming => startTime.isAfter(DateTime.now());

  bool isSignedUp(String uid) => signedUpUserIds.contains(uid);
  bool hasAttended(String uid) => attendedUserIds.contains(uid);
  bool isOnWaitlist(String uid) => waitlistUserIds.contains(uid);

  /// Returns the detailed eligibility of [user] for this run.
  RunEligibility eligibilityFor(AppUser user) {
    if (hasAttended(user.uid)) return const Attended();
    if (isSignedUp(user.uid)) return const AlreadySignedUp();
    if (!isUpcoming) return const RunPast();
    if (isOnWaitlist(user.uid)) return const OnWaitlist();
    if (user.age < constraints.minAge) return AgeTooYoung(constraints.minAge);
    if (user.age > constraints.maxAge) return AgeTooOld(constraints.maxAge);
    final cap = constraints.maxForGender(user.gender);
    if (cap != null && (genderCounts[user.gender.name] ?? 0) >= cap) {
      return const GenderCapacityReached();
    }
    if (isFull) return const RunFull();
    return const Eligible();
  }

  /// Returns the coarse booking status of this run from [user]'s perspective.
  RunSignUpStatus statusFor(AppUser user) {
    return switch (eligibilityFor(user)) {
      Attended() => RunSignUpStatus.attended,
      AlreadySignedUp() => RunSignUpStatus.signedUp,
      RunPast() => RunSignUpStatus.past,
      OnWaitlist() => RunSignUpStatus.waitlisted,
      RunFull() => RunSignUpStatus.full,
      Eligible() => RunSignUpStatus.eligible,
      _ => RunSignUpStatus.ineligible,
    };
  }

  String get title {
    const weekdays = [
      'Monday', 'Tuesday', 'Wednesday',
      'Thursday', 'Friday', 'Saturday', 'Sunday',
    ];
    final weekday = weekdays[startTime.weekday - 1];
    final hour = startTime.hour;
    final period = hour < 12 ? 'Morning' : hour < 17 ? 'Afternoon' : 'Evening';
    return '$weekday $period Run';
  }
}

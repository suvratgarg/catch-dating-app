import 'package:freezed_annotation/freezed_annotation.dart';

part 'run_eligibility.freezed.dart';

@freezed
sealed class RunEligibility with _$RunEligibility {
  const factory RunEligibility.eligible() = Eligible;
  const factory RunEligibility.alreadySignedUp() = AlreadySignedUp;
  const factory RunEligibility.onWaitlist() = OnWaitlist;
  const factory RunEligibility.attended() = Attended;
  const factory RunEligibility.runPast() = RunPast;
  const factory RunEligibility.runFull() = RunFull;

  /// The user's gender cap for this run has been reached.
  const factory RunEligibility.genderCapacityReached() = GenderCapacityReached;

  const factory RunEligibility.ageTooYoung(int minAge) = AgeTooYoung;
  const factory RunEligibility.ageTooOld(int maxAge) = AgeTooOld;
}

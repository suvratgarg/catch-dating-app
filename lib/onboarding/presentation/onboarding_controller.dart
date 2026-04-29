import 'dart:async';

import 'package:catch_dating_app/auth/auth_repository.dart';
import 'package:catch_dating_app/onboarding/presentation/onboarding_profile_draft.dart';
import 'package:catch_dating_app/onboarding/presentation/onboarding_step.dart';
import 'package:catch_dating_app/user_profile/data/user_profile_repository.dart';
import 'package:catch_dating_app/user_profile/domain/profile_validation.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:flutter_riverpod/experimental/mutation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'onboarding_controller.freezed.dart';
part 'onboarding_controller.g.dart';

@freezed
abstract class OnboardingData with _$OnboardingData {
  const OnboardingData._();

  const factory OnboardingData({
    @Default(OnboardingStep.welcome) OnboardingStep step,
    @Default(false) bool phoneVerified,
    String? verificationId,
    @Default(OnboardingProfileDraft()) OnboardingProfileDraft profileDraft,
  }) = _OnboardingData;

  String get phoneNumber => profileDraft.phoneNumber;
  String get firstName => profileDraft.firstName;
  String get lastName => profileDraft.lastName;
  DateTime? get dateOfBirth => profileDraft.dateOfBirth;
  Gender? get gender => profileDraft.gender;
  SexualOrientation? get sexualOrientation => profileDraft.sexualOrientation;
  List<Gender> get interestedInGenders => profileDraft.interestedInGenders;
}

@Riverpod(keepAlive: true)
class OnboardingController extends _$OnboardingController {
  static const welcomeStep = OnboardingStep.welcome;
  static const phoneStep = OnboardingStep.phone;
  static const otpStep = OnboardingStep.otp;
  static const nameDobStep = OnboardingStep.nameDob;
  static const genderInterestStep = OnboardingStep.genderInterest;
  static const photosStep = OnboardingStep.photos;
  static const runningPrefsStep = OnboardingStep.runningPrefs;

  static final sendOtpMutation = Mutation<void>();
  static final verifyOtpMutation = Mutation<void>();
  static final saveProfileMutation = Mutation<void>();
  static final completeMutation = Mutation<void>();

  @override
  OnboardingData build() => const OnboardingData();

  void initStep() {
    syncEntryStep();
  }

  void syncEntryStep() {
    final uid = ref.read(uidProvider).asData?.value;
    final userProfile = ref.read(userProfileStreamProvider).asData?.value;

    if (uid == null) {
      _setStateIfChanged(state.copyWith(step: OnboardingStep.welcome));
      return;
    }

    if (userProfile == null) {
      if (state.step.index > OnboardingStep.nameDob.index) {
        return;
      }

      // Authenticated (email or phone) but no profile doc yet.
      _setStateIfChanged(
        state.copyWith(
          step: OnboardingStep.nameDob,
          phoneVerified: _authPhoneNumber.isNotEmpty,
          profileDraft: state.profileDraft.copyWith(
            phoneNumber: state.phoneNumber.isNotEmpty
                ? state.phoneNumber
                : _stripIndianCountryCode(_authPhoneNumber),
          ),
        ),
      );
      return;
    }

    if (!userProfile.profileComplete) {
      _setStateIfChanged(state.copyWith(step: OnboardingStep.photos));
    }
  }

  void goToStep(OnboardingStep step) => state = state.copyWith(step: step);

  // ── Phone OTP ─────────────────────────────────────────────────────────────

  Future<void> sendOtp(String phoneNumber) async {
    state = state.copyWith(
      phoneVerified: false,
      verificationId: null,
      profileDraft: state.profileDraft.copyWith(phoneNumber: phoneNumber),
    );

    // verifyPhoneNumber's Future resolves when Firebase submits the request —
    // before codeSent/verificationFailed fire. A Completer bridges those async
    // callbacks back into this Future so the mutation catches errors correctly.
    final completer = Completer<void>();

    unawaited(ref
        .read(authRepositoryProvider)
        .verifyPhoneNumber(
          phoneNumber: _formatIndianPhoneNumber(phoneNumber),
          codeSent: (verificationId, _) {
            state = state.copyWith(
              verificationId: verificationId,
              step: OnboardingStep.otp,
            );
            if (!completer.isCompleted) completer.complete();
          },
          verificationFailed: (e) {
            if (!completer.isCompleted) completer.completeError(e);
          },
          verificationCompleted: (credential) async {
            try {
              await ref
                  .read(authRepositoryProvider)
                  .signInWithCredential(credential);
              state = state.copyWith(
                step: OnboardingStep.nameDob,
                phoneVerified: true,
              );
              if (!completer.isCompleted) completer.complete();
            } catch (e, st) {
              if (!completer.isCompleted) completer.completeError(e, st);
            }
          },
        )
        .catchError((Object e, StackTrace st) {
          if (!completer.isCompleted) completer.completeError(e, st);
        }));

    return completer.future;
  }

  Future<void> verifyOtp(String code) async {
    final verificationId = state.verificationId;
    if (verificationId == null || verificationId.isEmpty) {
      throw StateError(
        'Verification session expired. Please request a new code.',
      );
    }

    await ref
        .read(authRepositoryProvider)
        .signInWithOtp(verificationId: verificationId, smsCode: code);
    state = state.copyWith(step: OnboardingStep.nameDob, phoneVerified: true);
  }

  // ── Profile creation ──────────────────────────────────────────────────────

  void setNameDob({
    required String firstName,
    required String lastName,
    required DateTime dateOfBirth,
    required String phoneNumber,
  }) {
    state = state.copyWith(
      profileDraft: state.profileDraft.copyWith(
        firstName: firstName,
        lastName: lastName,
        dateOfBirth: dateOfBirth,
        phoneNumber: phoneNumber,
      ),
    );
  }

  void setGenderInterest({
    required Gender gender,
    required SexualOrientation sexualOrientation,
    required List<Gender> interestedInGenders,
  }) {
    state = state.copyWith(
      profileDraft: state.profileDraft.copyWith(
        gender: gender,
        sexualOrientation: sexualOrientation,
        interestedInGenders: interestedInGenders,
      ),
    );
  }

  Future<void> saveProfile() async {
    final uid = _requireSignedInUid();
    final draft = _requireProfileDraft();
    final email = ref.read(authRepositoryProvider).currentUser?.email ?? '';

    await ref
        .read(userProfileRepositoryProvider)
        .setUserProfile(
          userProfile: UserProfile(
            uid: uid,
            email: email,
            name: draft.fullName,
            dateOfBirth: draft.dateOfBirth!,
            gender: draft.gender!,
            sexualOrientation: draft.sexualOrientation!,
            phoneNumber: draft.phoneNumber,
            interestedInGenders: draft.interestedInGenders,
            profileComplete: false,
          ),
        );
    state = state.copyWith(step: OnboardingStep.photos);
  }

  Future<void> complete({
    required int paceMinSecsPerKm,
    required int paceMaxSecsPerKm,
    required List<PreferredDistance> preferredDistances,
    required List<RunReason> runningReasons,
  }) async {
    final userProfile = ref.read(userProfileStreamProvider).asData?.value;
    if (userProfile == null) {
      throw StateError('User profile not loaded. Please try again.');
    }
    await ref
        .read(userProfileRepositoryProvider)
        .setUserProfile(
          userProfile: userProfile.copyWith(
            paceMinSecsPerKm: paceMinSecsPerKm,
            paceMaxSecsPerKm: paceMaxSecsPerKm,
            preferredDistances: preferredDistances,
            runningReasons: runningReasons,
            profileComplete: true,
          ),
        );
  }

  String _requireSignedInUid() {
    final uid = ref.read(uidProvider).asData?.value;
    if (uid == null || uid.isEmpty) {
      throw StateError('Please sign in again before continuing.');
    }
    return uid;
  }

  OnboardingProfileDraft _requireProfileDraft() {
    final draft = state.profileDraft.copyWith(
      firstName: state.firstName.trim(),
      lastName: state.lastName.trim(),
      phoneNumber: state.phoneNumber.trim(),
    );
    final dateOfBirth = draft.dateOfBirth;
    final gender = draft.gender;
    final sexualOrientation = draft.sexualOrientation;

    if (draft.firstName.isEmpty ||
        draft.lastName.isEmpty ||
        dateOfBirth == null) {
      throw StateError(
        'Please complete your basic profile details before continuing.',
      );
    }

    if (!isAtLeastAge(dateOfBirth)) {
      throw StateError(
        'You must be at least $minimumProfileAge years old to continue.',
      );
    }

    if (gender == null || sexualOrientation == null) {
      throw StateError(
        'Please choose your dating preferences before continuing.',
      );
    }

    if (draft.phoneNumber.isEmpty) {
      throw StateError('Please add a valid phone number before continuing.');
    }

    return draft.copyWith(
      phoneNumber: _formatIndianPhoneNumber(draft.phoneNumber),
    );
  }

  String get _authPhoneNumber =>
      ref.read(authRepositoryProvider).currentUser?.phoneNumber ?? '';

  void _setStateIfChanged(OnboardingData nextState) {
    if (nextState == state) {
      return;
    }
    state = nextState;
  }

  String _formatIndianPhoneNumber(String phoneNumber) {
    final normalized = phoneNumber.trim();
    if (normalized.startsWith('+')) {
      return normalized;
    }
    return '+91$normalized';
  }

  String _stripIndianCountryCode(String phoneNumber) {
    return phoneNumber.startsWith('+91')
        ? phoneNumber.substring(3)
        : phoneNumber;
  }
}

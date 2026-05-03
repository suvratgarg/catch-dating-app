import 'dart:async';

import 'package:catch_dating_app/auth/auth_repository.dart';
import 'package:catch_dating_app/core/app_config.dart';
import 'package:flutter/foundation.dart';
import 'package:catch_dating_app/exceptions/app_exception.dart';
import 'package:catch_dating_app/onboarding/data/onboarding_draft_repository.dart';
import 'package:catch_dating_app/onboarding/domain/onboarding_draft.dart';
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
  String get countryCode => profileDraft.countryCode;
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

  Future<void> initStep() => syncEntryStep();

  Future<void> syncEntryStep() async {
    final uid = ref.read(uidProvider).asData?.value;
    final userProfile = ref.read(userProfileStreamProvider).asData?.value;

    if (uid == null) {
      _setStateIfChanged(state.copyWith(step: OnboardingStep.welcome));
      return;
    }

    // Try to resume from a persisted draft first (exact step tracking).
    final draft =
        await ref.read(onboardingDraftRepositoryProvider).fetchDraft(uid: uid);
    final draftStep =
        draft != null ? OnboardingStep.fromIndex(draft.step) : null;
    if (draft != null && draftStep != null) {
      _setStateIfChanged(
        state.copyWith(
          step: draftStep,
          phoneVerified: draftStep.index >= OnboardingStep.nameDob.index,
          profileDraft: state.profileDraft.copyWith(
            firstName: draft.firstName,
            lastName: draft.lastName,
            dateOfBirth: draft.dateOfBirth,
            phoneNumber: draft.phoneNumber,
            countryCode: draft.countryCode,
            gender: draft.gender,
            sexualOrientation: draft.sexualOrientation,
            interestedInGenders: draft.interestedInGenders,
          ),
        ),
      );
      return;
    }

    // No draft — fall back to the existing heuristic (also handles users
    // who started onboarding before the draft system was introduced).
    if (userProfile == null) {
      final phoneNumber = _authPhoneNumber;
      if (phoneNumber.isEmpty) {
        _setStateIfChanged(
          state.copyWith(step: OnboardingStep.phone, phoneVerified: false),
        );
        return;
      }

      if (state.step.index > OnboardingStep.nameDob.index) {
        return;
      }

      // Authenticated by phone OTP but no profile doc yet.
      _setStateIfChanged(
        state.copyWith(
          step: OnboardingStep.nameDob,
          phoneVerified: true,
          profileDraft: state.profileDraft.copyWith(
            phoneNumber: _stripCountryCode(phoneNumber, '+91'),
            countryCode: '+91',
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

  void goToStepAndSaveDraft(OnboardingStep step) {
    state = state.copyWith(step: step);
    _saveDraft();
  }

  // ── Phone OTP ─────────────────────────────────────────────────────────────

  Future<void> sendOtp(String phoneNumber, String countryCode) async {
    state = state.copyWith(
      phoneVerified: false,
      verificationId: null,
      profileDraft: state.profileDraft.copyWith(
        phoneNumber: phoneNumber,
        countryCode: countryCode,
      ),
    );

    final formatted = _formatPhoneNumber(phoneNumber, countryCode);
    debugPrint('── sendOtp ──');
    debugPrint('  national number: $phoneNumber');
    debugPrint('  country code: $countryCode');
    debugPrint('  formatted: $formatted');
    debugPrint('  appCheckDebugToken configured: ${AppConfig.firebaseAppCheckDebugToken.isNotEmpty}');

    // verifyPhoneNumber's Future resolves when Firebase submits the request —
    // before codeSent/verificationFailed fire. A Completer bridges those async
    // callbacks back into this Future so the mutation catches errors correctly.
    final completer = Completer<void>();

    unawaited(
      ref
          .read(authRepositoryProvider)
          .verifyPhoneNumber(
            phoneNumber: formatted,
            codeSent: (verificationId, _) {
              debugPrint('sendOtp: codeSent — verificationId received');
              state = state.copyWith(
                verificationId: verificationId,
                step: OnboardingStep.otp,
              );
              if (!completer.isCompleted) completer.complete();
            },
            verificationFailed: (e) {
              debugPrint('sendOtp verificationFailed: code=${e.code} message=${e.message}');
              if (!completer.isCompleted) completer.completeError(e);
            },
            verificationCompleted: (credential) async {
              debugPrint('sendOtp: verificationCompleted (auto)');
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
            debugPrint('sendOtp catchError: $e');
            if (!completer.isCompleted) completer.completeError(e, st);
          }),
    );

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
    required String countryCode,
  }) {
    state = state.copyWith(
      profileDraft: state.profileDraft.copyWith(
        firstName: firstName,
        lastName: lastName,
        dateOfBirth: dateOfBirth,
        phoneNumber: phoneNumber,
        countryCode: countryCode,
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

  void advanceToGenderInterest({
    required String firstName,
    required String lastName,
    required DateTime dateOfBirth,
    required String phoneNumber,
    required String countryCode,
  }) {
    setNameDob(
      firstName: firstName,
      lastName: lastName,
      dateOfBirth: dateOfBirth,
      phoneNumber: phoneNumber,
      countryCode: countryCode,
    );
    state = state.copyWith(step: OnboardingStep.genderInterest);
    _saveDraft();
  }

  Future<void> saveProfile() async {
    final uid = _requireSignedInUid();
    final draft = _requireProfileDraft();

    state = state.copyWith(step: OnboardingStep.photos);
    _saveDraft();

    await ref
        .read(userProfileRepositoryProvider)
        .setUserProfile(
          userProfile: UserProfile(
            uid: uid,
            name: draft.fullName,
            dateOfBirth: draft.dateOfBirth!,
            gender: draft.gender!,
            sexualOrientation: draft.sexualOrientation!,
            phoneNumber: draft.phoneNumber,
            interestedInGenders: draft.interestedInGenders,
            profileComplete: false,
          ),
        );
  }

  Future<void> complete({
    required int paceMinSecsPerKm,
    required int paceMaxSecsPerKm,
    required List<PreferredDistance> preferredDistances,
    required List<RunReason> runningReasons,
  }) async {
    final userProfile = ref.read(userProfileStreamProvider).asData?.value;
    if (userProfile == null) {
      throw const DocumentNotFoundException('users/current');
    }
    await ref.read(userProfileRepositoryProvider).updateUserProfile(
      uid: userProfile.uid,
      fields: {
        'paceMinSecsPerKm': paceMinSecsPerKm,
        'paceMaxSecsPerKm': paceMaxSecsPerKm,
        'preferredDistances':
            preferredDistances.map((e) => e.name).toList(),
        'runningReasons': runningReasons.map((e) => e.name).toList(),
        'profileComplete': true,
      },
    );
    _deleteDraft();
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

    if (!state.phoneVerified) {
      throw StateError('Please verify your phone number before continuing.');
    }

    return draft.copyWith(
      phoneNumber: _formatPhoneNumber(draft.phoneNumber, draft.countryCode),
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

  String _formatPhoneNumber(String phoneNumber, String countryCode) {
    final normalized = phoneNumber.trim();
    if (normalized.startsWith('+')) {
      return normalized;
    }
    return '$countryCode$normalized';
  }

  String _stripCountryCode(String phoneNumber, String countryCode) {
    if (phoneNumber.startsWith(countryCode)) {
      return phoneNumber.substring(countryCode.length);
    }
    return phoneNumber;
  }

  void _saveDraft() {
    final uid = ref.read(uidProvider).asData?.value;
    if (uid == null) return;

    // Best-effort cache — a failed write is harmless; syncEntryStep falls
    // back to the existing heuristic on next launch.
    unawaited(
      ref.read(onboardingDraftRepositoryProvider).saveDraft(
        uid: uid,
        draft: OnboardingDraft(
          step: state.step.index,
          firstName: state.firstName,
          lastName: state.lastName,
          dateOfBirth: state.dateOfBirth,
          phoneNumber: state.phoneNumber,
          countryCode: state.countryCode,
          gender: state.gender,
          sexualOrientation: state.sexualOrientation,
          interestedInGenders: state.interestedInGenders,
        ),
      ).catchError((_, __) {/* best-effort */}),
    );
  }

  void _deleteDraft() {
    final uid = ref.read(uidProvider).asData?.value;
    if (uid == null) return;

    unawaited(
      ref
          .read(onboardingDraftRepositoryProvider)
          .deleteDraft(uid: uid)
          .catchError((_, __) {/* best-effort */}),
    );
  }
}

import 'dart:async';

import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/auth/require_signed_in_uid.dart';
import 'package:catch_dating_app/exceptions/app_exception.dart';
import 'package:catch_dating_app/onboarding/data/onboarding_draft_repository.dart';
import 'package:catch_dating_app/onboarding/domain/onboarding_draft.dart';
import 'package:catch_dating_app/onboarding/presentation/onboarding_profile_draft.dart';
import 'package:catch_dating_app/onboarding/presentation/onboarding_step.dart';
import 'package:catch_dating_app/user_profile/data/user_profile_repository.dart';
import 'package:catch_dating_app/user_profile/domain/profile_validation.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:flutter/foundation.dart';
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
    @Default(OnboardingProfileDraft()) OnboardingProfileDraft profileDraft,
  }) = _OnboardingData;

  String get phoneNumber => profileDraft.phoneNumber;
  String get countryCode => profileDraft.countryCode;
  String get firstName => profileDraft.firstName;
  String get lastName => profileDraft.lastName;
  DateTime? get dateOfBirth => profileDraft.dateOfBirth;
  Gender? get gender => profileDraft.gender;
  List<Gender> get interestedInGenders => profileDraft.interestedInGenders;
  String? get instagramHandle => profileDraft.instagramHandle;
}

/// **Pattern B: Flow controller with freezed state + Mutations**
///
/// - [OnboardingData] (freezed) holds multi-step form state that must survive
///   navigation between onboarding pages. This is why [keepAlive] is `true`.
/// - [Mutation]s ([saveProfileMutation], [completeMutation]) handle single-shot
///   async operations while the UI watches their lifecycle.
/// - The controller self-invalidates at the end of [complete] so its state
///   is freed once onboarding is done.
///
/// **When to use this pattern:** Multi-step flows where state must survive
/// navigation and a freezed data class captures the full form state.
@Riverpod(keepAlive: true)
class OnboardingController extends _$OnboardingController {
  static const welcomeStep = OnboardingStep.welcome;
  static const nameDobStep = OnboardingStep.nameDob;
  static const genderInterestStep = OnboardingStep.genderInterest;
  static const instagramStep = OnboardingStep.instagram;
  static const photosStep = OnboardingStep.photos;
  static const runningPrefsStep = OnboardingStep.runningPrefs;

  static final saveProfileMutation = Mutation<void>();
  static final completeMutation = Mutation<void>();

  @override
  OnboardingData build() => const OnboardingData();

  Future<void> initStep() => syncEntryStep();

  Future<void> syncEntryStep() async {
    final uid = ref.read(uidProvider).asData?.value;
    final userProfile = ref.read(watchUserProfileProvider).asData?.value;

    if (uid == null) {
      _setStateIfChanged(state.copyWith(step: OnboardingStep.welcome));
      return;
    }

    // Try to resume from a persisted draft first (exact step tracking).
    final draft = await ref
        .read(onboardingDraftRepositoryProvider)
        .fetchDraft(uid: uid);
    if (draft != null) {
      if (_authPhoneNumber.isEmpty) {
        _setStateIfChanged(state.copyWith(step: OnboardingStep.welcome));
        return;
      }

      final migratedStepIndex = _migrateDraftStep(
        draft.step,
        draft.draftVersion,
      );
      final draftStep = OnboardingStep.fromIndex(migratedStepIndex);
      if (draftStep != null) {
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
              interestedInGenders: draft.interestedInGenders,
              instagramHandle: draft.instagramHandle,
            ),
          ),
        );
        return;
      }
    }

    // No draft — fall back to heuristic (also handles users who started
    // onboarding before the draft system was introduced).
    if (userProfile == null) {
      final phoneNumber = _authPhoneNumber;
      if (phoneNumber.isEmpty) {
        // Not signed in via phone — should re-enter auth.
        _setStateIfChanged(state.copyWith(step: OnboardingStep.welcome));
        return;
      }

      if (state.step.index > OnboardingStep.nameDob.index) {
        return;
      }

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
    required List<Gender> interestedInGenders,
  }) {
    state = state.copyWith(
      profileDraft: state.profileDraft.copyWith(
        gender: gender,
        interestedInGenders: interestedInGenders,
      ),
    );
  }

  void setInstagramHandle(String? handle) {
    state = state.copyWith(
      profileDraft: state.profileDraft.copyWith(instagramHandle: handle),
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

  void advanceToPhotos({String? instagramHandle}) {
    setInstagramHandle(instagramHandle);
    state = state.copyWith(step: OnboardingStep.photos);
    _saveDraft();
  }

  Future<void> saveProfile() async {
    final uid = requireSignedInUid(ref, action: 'save profile');
    final draft = _requireProfileDraft();
    final verifiedPhoneNumber = _requireVerifiedAuthPhoneNumber();

    await ref
        .read(userProfileRepositoryProvider)
        .setUserProfile(
          userProfile: UserProfile(
            uid: uid,
            name: draft.fullName,
            dateOfBirth: draft.dateOfBirth!,
            gender: draft.gender!,
            phoneNumber: verifiedPhoneNumber,
            interestedInGenders: draft.interestedInGenders,
            instagramHandle: (draft.instagramHandle?.trim() ?? '').isEmpty
                ? null
                : draft.instagramHandle?.trim(),
            profileComplete: false,
          ),
        );

    state = state.copyWith(step: OnboardingStep.instagram);
    _saveDraft();
  }

  Future<void> complete({
    required int paceMinSecsPerKm,
    required int paceMaxSecsPerKm,
    required List<PreferredDistance> preferredDistances,
    required List<RunReason> runningReasons,
  }) async {
    final userProfile = ref.read(watchUserProfileProvider).asData?.value;
    if (userProfile == null) {
      throw const DocumentNotFoundException('users/current');
    }
    await ref
        .read(userProfileRepositoryProvider)
        .updateUserProfile(
          uid: userProfile.uid,
          fields: {
            'paceMinSecsPerKm': paceMinSecsPerKm,
            'paceMaxSecsPerKm': paceMaxSecsPerKm,
            'preferredDistances': preferredDistances
                .map((e) => e.name)
                .toList(),
            'runningReasons': runningReasons.map((e) => e.name).toList(),
            'profileComplete': true,
          },
        );
    _deleteDraft();
    // Onboarding is complete — the router will redirect away shortly.
    // Invalidate self so the keepAlive provider is disposed and its
    // state (including OnboardingData) is freed.
    ref.invalidateSelf();
  }

  OnboardingProfileDraft _requireProfileDraft() {
    final draft = state.profileDraft.copyWith(
      firstName: state.firstName.trim(),
      lastName: state.lastName.trim(),
      phoneNumber: state.phoneNumber.trim(),
    );
    final dateOfBirth = draft.dateOfBirth;
    final gender = draft.gender;

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

    if (gender == null) {
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

    return draft;
  }

  String get _authPhoneNumber =>
      ref.read(authRepositoryProvider).currentUser?.phoneNumber ?? '';

  String _requireVerifiedAuthPhoneNumber() {
    if (!state.phoneVerified) {
      throw StateError('Please verify your phone number before continuing.');
    }

    final phoneNumber = _authPhoneNumber.trim();
    if (phoneNumber.isEmpty) {
      throw StateError('Please verify your phone number before continuing.');
    }
    return phoneNumber;
  }

  void _setStateIfChanged(OnboardingData nextState) {
    if (nextState == state) {
      return;
    }
    state = nextState;
  }

  int _migrateDraftStep(int storedStep, int draftVersion) {
    if (draftVersion >= 1) return storedStep;
    // Legacy draft (version 0) with old 9-step indices:
    //   welcome(0), phone(1), otp(2), nameDob(3), genderInterest(4),
    //   instagram(5), photos(6), runningPrefs(7)
    // New 6-step indices:
    //   welcome(0), nameDob(1), genderInterest(2), instagram(3),
    //   photos(4), runningPrefs(5)
    if (storedStep <= 0) return 0;
    if (storedStep <= 2) return 0; // phone/otp → welcome (re-enter auth)
    return storedStep - 2;
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
      ref
          .read(onboardingDraftRepositoryProvider)
          .saveDraft(
            uid: uid,
            draft: OnboardingDraft(
              step: state.step.index,
              draftVersion: 1,
              firstName: state.firstName,
              lastName: state.lastName,
              dateOfBirth: state.dateOfBirth,
              phoneNumber: state.phoneNumber,
              countryCode: state.countryCode,
              gender: state.gender,
              interestedInGenders: state.interestedInGenders,
              instagramHandle: state.instagramHandle,
            ),
          )
          .catchError((Object error, StackTrace stack) {
            debugPrint(
              '[ERROR] OnboardingController._saveDraft: $error\n$stack',
            );
          }),
    );
  }

  void _deleteDraft() {
    final uid = ref.read(uidProvider).asData?.value;
    if (uid == null) return;

    unawaited(
      ref
          .read(onboardingDraftRepositoryProvider)
          .deleteDraft(uid: uid)
          .catchError((Object error, StackTrace stack) {
            debugPrint(
              '[ERROR] OnboardingController._deleteDraft: $error\n$stack',
            );
          }),
    );
  }
}

import 'dart:async';

import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/auth/require_signed_in_uid.dart';
import 'package:catch_dating_app/core/backend_error_util.dart';
import 'package:catch_dating_app/core/country_markets.dart';
import 'package:catch_dating_app/exceptions/app_exception.dart';
import 'package:catch_dating_app/exceptions/error_logger.dart';
import 'package:catch_dating_app/onboarding/data/onboarding_draft_repository.dart';
import 'package:catch_dating_app/onboarding/domain/onboarding_draft.dart';
import 'package:catch_dating_app/onboarding/presentation/onboarding_profile_draft.dart';
import 'package:catch_dating_app/onboarding/presentation/onboarding_step.dart';
import 'package:catch_dating_app/user_profile/data/user_profile_repository.dart';
import 'package:catch_dating_app/user_profile/domain/profile_prompts.dart';
import 'package:catch_dating_app/user_profile/domain/profile_readiness.dart';
import 'package:catch_dating_app/user_profile/domain/profile_validation.dart';
import 'package:catch_dating_app/user_profile/domain/update_user_profile_patch.dart';
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
  List<ProfilePromptAnswer> get profilePrompts => profileDraft.profilePrompts;
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
  static const promptsStep = OnboardingStep.prompts;
  static const runningPrefsStep = OnboardingStep.runningPrefs;

  static final saveProfileMutation = Mutation<void>();
  static final completeMutation = Mutation<void>();

  @override
  OnboardingData build() => const OnboardingData();

  Future<void> initStep({
    bool profileCompletionOnly = false,
    bool runPreferencesOnly = false,
  }) => syncEntryStep(
    profileCompletionOnly: profileCompletionOnly,
    runPreferencesOnly: runPreferencesOnly,
  );

  Future<void> syncEntryStep({
    bool profileCompletionOnly = false,
    bool runPreferencesOnly = false,
  }) async {
    final uid = ref.read(uidProvider).asData?.value;
    final userProfile = ref.read(watchUserProfileProvider).asData?.value;

    if (uid == null) {
      _setStateIfChanged(state.copyWith(step: OnboardingStep.welcome));
      return;
    }

    if (runPreferencesOnly &&
        userProfile != null &&
        userProfile.hasBookingReadyIdentity) {
      _setStateIfChanged(
        state.copyWith(
          step: OnboardingStep.runningPrefs,
          phoneVerified: true,
          profileDraft: _profileDraftFromUserProfile(userProfile),
        ),
      );
      return;
    }

    if (profileCompletionOnly &&
        userProfile != null &&
        userProfile.hasBookingReadyIdentity) {
      _setStateIfChanged(
        state.copyWith(
          step: _firstMissingSocialProfileStep(userProfile),
          phoneVerified: true,
          profileDraft: _profileDraftFromUserProfile(userProfile),
        ),
      );
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
        final entryStep = runPreferencesOnly
            ? OnboardingStep.runningPrefs
            : profileCompletionOnly
            ? draftStep
            : _bookingIdentityStepForDraft(draftStep);
        _setStateIfChanged(
          state.copyWith(
            step: entryStep,
            phoneVerified: entryStep.index >= OnboardingStep.nameDob.index,
            profileDraft: state.profileDraft.copyWith(
              firstName: draft.firstName,
              lastName: draft.lastName,
              dateOfBirth: draft.dateOfBirth,
              phoneNumber: draft.phoneNumber,
              countryCode: draft.countryCode,
              gender: draft.gender,
              interestedInGenders: draft.interestedInGenders,
              instagramHandle: draft.instagramHandle,
              profilePrompts: draft.profilePrompts,
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

      final dialCode = _dialCodeFromPhoneNumber(phoneNumber);
      _setStateIfChanged(
        state.copyWith(
          step: OnboardingStep.nameDob,
          phoneVerified: true,
          profileDraft: state.profileDraft.copyWith(
            phoneNumber: _stripCountryCode(phoneNumber, dialCode),
            countryCode: dialCode,
          ),
        ),
      );
      return;
    }

    if (!userProfile.hasBookingReadyIdentity) {
      _setStateIfChanged(
        state.copyWith(
          step: _firstMissingBookingIdentityStep(userProfile),
          phoneVerified: _authPhoneNumber.isNotEmpty,
          profileDraft: _profileDraftFromUserProfile(userProfile),
        ),
      );
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

  void setProfilePrompts(List<ProfilePromptAnswer> prompts) {
    state = state.copyWith(
      profileDraft: state.profileDraft.copyWith(
        profilePrompts: normalizeProfilePromptAnswers(prompts),
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

  void advanceToPhotos({String? instagramHandle}) {
    setInstagramHandle(instagramHandle);
    state = state.copyWith(step: OnboardingStep.photos);
    _saveDraft();
  }

  void advanceToRunningPrefs({required List<ProfilePromptAnswer> prompts}) {
    setProfilePrompts(prompts);
    state = state.copyWith(step: OnboardingStep.runningPrefs);
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
            firstName: draft.firstName.trim(),
            lastName: draft.lastName.trim(),
            displayName: draft.firstName.trim(),
            dateOfBirth: draft.dateOfBirth!,
            gender: draft.gender!,
            phoneNumber: verifiedPhoneNumber,
            countryCode: draft.countryCode,
            interestedInGenders: draft.interestedInGenders,
            instagramHandle: (draft.instagramHandle?.trim() ?? '').isEmpty
                ? null
                : draft.instagramHandle?.trim(),
            profilePrompts: draft.profilePrompts,
            profileComplete: false,
          ),
        );

    await _deleteDraftNow();
  }

  Future<void> completeSocialProfile({
    required List<ProfilePromptAnswer> prompts,
  }) async {
    final userProfile = ref.read(watchUserProfileProvider).asData?.value;
    if (userProfile == null) {
      throw const DocumentNotFoundException('users/current');
    }
    final normalizedPrompts = normalizeProfilePromptAnswers(prompts);
    await ref
        .read(userProfileRepositoryProvider)
        .updateUserProfile(
          uid: userProfile.uid,
          patch: UpdateUserProfilePatch(
            profilePrompts: normalizedPrompts,
            profileComplete: true,
          ),
        );
    await _deleteDraftNow();
    ref.invalidateSelf();
  }

  Future<void> completeRunPreferences({
    required int paceMinSecsPerKm,
    required int paceMaxSecsPerKm,
    required List<PreferredDistance> preferredDistances,
    required List<RunReason> runningReasons,
    required List<PreferredRunTime> preferredRunTimes,
  }) async {
    final userProfile = ref.read(watchUserProfileProvider).asData?.value;
    if (userProfile == null) {
      throw const DocumentNotFoundException('users/current');
    }
    await ref
        .read(userProfileRepositoryProvider)
        .updateUserProfile(
          uid: userProfile.uid,
          patch: UpdateUserProfilePatch(
            activityPreferences: userProfile.activityPreferences.copyWith(
              running: RunningPreferences(
                paceMinSecsPerKm: paceMinSecsPerKm,
                paceMaxSecsPerKm: paceMaxSecsPerKm,
                preferredDistances: preferredDistances,
                runningReasons: runningReasons,
                preferredRunTimes: preferredRunTimes,
                version: currentRunPreferencesVersion,
              ),
            ),
          ),
        );
    await _deleteDraftNow();
    // The router will redirect away shortly.
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

    if (validateRequiredProfileName(draft.firstName, label: 'First name') !=
            null ||
        validateRequiredProfileName(draft.lastName, label: 'Last name') !=
            null ||
        validateRequiredDateOfBirth(dateOfBirth) != null) {
      throw StateError(
        'Please complete your basic profile details before continuing.',
      );
    }

    if (gender == null) {
      throw StateError(
        'Please choose your dating preferences before continuing.',
      );
    }

    if (draft.interestedInGenders.isEmpty) {
      throw StateError('Please choose who you want to see before continuing.');
    }

    if (validateRequiredPhoneNumber(draft.phoneNumber) != null) {
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
    if (draftVersion >= 2) return storedStep;
    if (draftVersion == 1) return storedStep;
    // Legacy draft (version 0) with old 9-step indices:
    //   welcome(0), phone(1), otp(2), nameDob(3), genderInterest(4),
    //   instagram(5), photos(6), runningPrefs(7)
    // Version 1 removed phone/OTP:
    //   welcome(0), nameDob(1), genderInterest(2), instagram(3),
    //   photos(4), runningPrefs(5)
    // Version 2 inserts prompts at index 5. Legacy users who were already at
    // runningPrefs land on prompts so every new completed profile gets prompts.
    if (storedStep <= 0) return 0;
    if (storedStep <= 2) return 0; // phone/otp → welcome (re-enter auth)
    return storedStep - 2;
  }

  OnboardingStep _bookingIdentityStepForDraft(OnboardingStep draftStep) {
    if (draftStep.index > OnboardingStep.genderInterest.index) {
      return OnboardingStep.genderInterest;
    }
    return draftStep;
  }

  OnboardingStep _firstMissingBookingIdentityStep(UserProfile userProfile) {
    if (!userProfile.hasBookingReadyName ||
        validateRequiredDateOfBirth(userProfile.dateOfBirth) != null ||
        validateRequiredPhoneNumber(userProfile.phoneNumber) != null) {
      return OnboardingStep.nameDob;
    }
    return OnboardingStep.genderInterest;
  }

  OnboardingStep _firstMissingSocialProfileStep(UserProfile userProfile) {
    if (!userProfile.hasMinimumSocialPhotos) return OnboardingStep.photos;
    return OnboardingStep.prompts;
  }

  OnboardingProfileDraft _profileDraftFromUserProfile(UserProfile userProfile) {
    final phoneNumber = _authPhoneNumber.trim().isNotEmpty
        ? _authPhoneNumber.trim()
        : userProfile.phoneNumber.trim();
    final countryCode = _dialCodeFromPhoneNumber(phoneNumber);
    final nameParts = userProfile.name.trim().split(RegExp(r'\s+'));
    final firstName = userProfile.firstName.trim().isNotEmpty
        ? userProfile.firstName.trim()
        : nameParts.firstOrNull ?? '';
    final lastName = userProfile.lastName.trim().isNotEmpty
        ? userProfile.lastName.trim()
        : nameParts.length > 1
        ? nameParts.skip(1).join(' ')
        : '';
    return OnboardingProfileDraft(
      firstName: firstName,
      lastName: lastName,
      dateOfBirth: userProfile.dateOfBirth,
      phoneNumber: _stripCountryCode(phoneNumber, countryCode),
      countryCode: countryCode,
      gender: userProfile.gender,
      interestedInGenders: userProfile.interestedInGenders,
      instagramHandle: userProfile.instagramHandle,
      profilePrompts: userProfile.profilePrompts,
    );
  }

  String _stripCountryCode(String phoneNumber, String countryCode) {
    if (phoneNumber.startsWith(countryCode)) {
      return phoneNumber.substring(countryCode.length);
    }
    return phoneNumber;
  }

  String _dialCodeFromPhoneNumber(String phoneNumber) {
    final normalized = phoneNumber.trim();
    final sortedDialCodes =
        supportedCountryMarkets.map((market) => market.dialCode).toList()
          ..sort((a, b) => b.length.compareTo(a.length));
    for (final dialCode in sortedDialCodes) {
      if (normalized.startsWith(dialCode)) return dialCode;
    }
    return state.countryCode;
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
              draftVersion: 2,
              firstName: state.firstName,
              lastName: state.lastName,
              dateOfBirth: state.dateOfBirth,
              phoneNumber: state.phoneNumber,
              countryCode: state.countryCode,
              gender: state.gender,
              interestedInGenders: state.interestedInGenders,
              instagramHandle: state.instagramHandle,
              profilePrompts: state.profilePrompts,
            ),
          )
          .catchError((Object error, StackTrace stack) {
            ref
                .read(errorLoggerProvider)
                .logAppException(
                  normalizeBackendError(
                    error,
                    stackTrace: stack,
                    context: const BackendErrorContext(
                      service: BackendService.local,
                      action: 'save onboarding draft',
                      resource: 'onboarding_controller',
                    ),
                  ),
                );
          }),
    );
  }

  Future<void> _deleteDraftNow() async {
    final uid = ref.read(uidProvider).asData?.value;
    if (uid == null) return;

    try {
      await ref.read(onboardingDraftRepositoryProvider).deleteDraft(uid: uid);
    } catch (error, stack) {
      ref
          .read(errorLoggerProvider)
          .logAppException(
            normalizeBackendError(
              error,
              stackTrace: stack,
              context: const BackendErrorContext(
                service: BackendService.local,
                action: 'delete onboarding draft',
                resource: 'onboarding_controller',
              ),
            ),
          );
    }
  }
}

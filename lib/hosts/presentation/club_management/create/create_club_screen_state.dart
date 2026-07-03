import 'dart:typed_data';

import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/clubs/domain/club_draft.dart';
import 'package:catch_dating_app/clubs/domain/club_host_defaults.dart';
import 'package:catch_dating_app/core/city_catalog.dart';
import 'package:catch_dating_app/core/widgets/catch_form_step_flow.dart';
import 'package:catch_dating_app/core/widgets/ordered_photo_picker.dart';
import 'package:catch_dating_app/hosts/presentation/club_management/create/create_club_controller.dart';
import 'package:flutter/material.dart';

enum HostClubCreatePrimaryIntent { nextStep, submit }

enum HostClubCreateSaveDraftIntent { saveDraft }

enum HostClubCreateDraftRestoreIntent { retry }

@immutable
class HostClubCreateDraftRestoreState {
  const HostClubCreateDraftRestoreState({
    required this.isLoading,
    required this.error,
    required this.retryIntent,
  });

  factory HostClubCreateDraftRestoreState.resolve({
    required bool enabled,
    required bool loadPending,
    required Object? loadError,
  }) {
    if (!enabled) {
      return const HostClubCreateDraftRestoreState(
        isLoading: false,
        error: null,
        retryIntent: null,
      );
    }
    return HostClubCreateDraftRestoreState(
      isLoading: loadPending,
      error: loadError,
      retryIntent: loadError == null
          ? null
          : HostClubCreateDraftRestoreIntent.retry,
    );
  }

  final bool isLoading;
  final Object? error;
  final HostClubCreateDraftRestoreIntent? retryIntent;

  bool get hasError => error != null;
}

@immutable
class HostClubCreateFooterState {
  const HostClubCreateFooterState({
    required this.isLastStep,
    required this.isLoading,
    required this.primaryEnabled,
    required this.primaryLabel,
    required this.lastStepLabel,
    required this.primaryIntent,
    required this.saveDraftIntent,
  });

  final bool isLastStep;
  final bool isLoading;
  final bool primaryEnabled;
  final String primaryLabel;
  final String lastStepLabel;
  final HostClubCreatePrimaryIntent primaryIntent;
  final HostClubCreateSaveDraftIntent? saveDraftIntent;

  bool get canSaveDraft => saveDraftIntent != null;
}

@immutable
class HostClubEditScaffoldState {
  const HostClubEditScaffoldState({
    required this.mediaEnabled,
    required this.cityPickerEnabled,
    required this.footer,
  });

  final bool mediaEnabled;
  final bool cityPickerEnabled;
  final HostClubCreateFooterState footer;
}

@immutable
class HostClubCreateMediaState {
  const HostClubCreateMediaState({
    required this.enabled,
    required this.clubPhotoPreviews,
    required this.existingCoverImageUrl,
    required this.profileImageBytes,
    required this.existingProfileImageUrl,
  });

  factory HostClubCreateMediaState.resolve({
    required bool enabled,
    required Club? initialClub,
    required List<OrderedPhotoPreview> clubPhotoPreviews,
    required PickedClubProfileImage? profileImage,
  }) {
    return HostClubCreateMediaState(
      enabled: enabled,
      clubPhotoPreviews: List.unmodifiable(clubPhotoPreviews),
      existingCoverImageUrl: clubPhotoPreviews.isEmpty
          ? initialClub?.imageUrl
          : null,
      profileImageBytes: profileImage?.bytes,
      existingProfileImageUrl: initialClub?.profileImageUrl,
    );
  }

  final bool enabled;
  final List<OrderedPhotoPreview> clubPhotoPreviews;
  final String? existingCoverImageUrl;
  final Uint8List? profileImageBytes;
  final String? existingProfileImageUrl;
}

@immutable
class HostClubCreateFieldDisplayState {
  const HostClubCreateFieldDisplayState({
    required this.detailsEnabled,
    required this.selectedCity,
    required this.rawCityName,
    required this.currencyCode,
  });

  factory HostClubCreateFieldDisplayState.resolve({
    required bool mediaOnly,
    required String? selectedCityName,
  }) {
    return HostClubCreateFieldDisplayState(
      detailsEnabled: !mediaOnly,
      selectedCity: cityOptionByName(selectedCityName),
      rawCityName: selectedCityName,
      currencyCode: currencyCodeForCityName(selectedCityName),
    );
  }

  final bool detailsEnabled;
  final CityOption? selectedCity;
  final String? rawCityName;
  final String currencyCode;
}

@immutable
class HostClubEditValidationState {
  const HostClubEditValidationState({
    required this.shouldShowErrors,
    required this.autovalidateMode,
    required this.identityHasError,
  });

  factory HostClubEditValidationState.resolve({
    required bool editSubmitAttempted,
    required AutovalidateMode formAutovalidateMode,
    required String name,
    required String? selectedCity,
    required String area,
    required String description,
  }) {
    final shouldShowErrors =
        editSubmitAttempted ||
        formAutovalidateMode != AutovalidateMode.disabled;
    return HostClubEditValidationState(
      shouldShowErrors: shouldShowErrors,
      autovalidateMode: editSubmitAttempted
          ? AutovalidateMode.always
          : formAutovalidateMode,
      identityHasError:
          shouldShowErrors &&
          (name.trim().isEmpty ||
              selectedCity == null ||
              selectedCity.trim().isEmpty ||
              area.trim().isEmpty ||
              description.trim().isEmpty),
    );
  }

  final bool shouldShowErrors;
  final AutovalidateMode autovalidateMode;
  final bool identityHasError;
}

@immutable
class HostClubCreateDraftRequest {
  const HostClubCreateDraftRequest({
    required this.name,
    required this.area,
    required this.description,
    required this.location,
    required this.instagramHandle,
    required this.phoneNumber,
    required this.email,
    required this.hostDefaults,
  });

  factory HostClubCreateDraftRequest.fromForm({
    required String name,
    required String area,
    required String description,
    required String? selectedCity,
    required String instagramHandle,
    required String phoneNumber,
    required String email,
    required ClubHostDefaults hostDefaults,
  }) {
    return HostClubCreateDraftRequest(
      name: _trimmedTextOrNull(name),
      area: _trimmedTextOrNull(area),
      description: _trimmedTextOrNull(description),
      location: selectedCity,
      instagramHandle: _trimmedTextOrNull(instagramHandle),
      phoneNumber: _trimmedTextOrNull(phoneNumber),
      email: _trimmedTextOrNull(email),
      hostDefaults: hostDefaults,
    );
  }

  final String? name;
  final String? area;
  final String? description;
  final String? location;
  final String? instagramHandle;
  final String? phoneNumber;
  final String? email;
  final ClubHostDefaults hostDefaults;

  ClubDraft toDraft({required DateTime savedAt}) {
    return ClubDraft(
      savedAt: savedAt,
      name: name,
      area: area,
      description: description,
      location: location,
      instagramHandle: instagramHandle,
      phoneNumber: phoneNumber,
      email: email,
      hostDefaults: hostDefaults,
    );
  }
}

@immutable
class HostClubCreateSubmitRequest {
  const HostClubCreateSubmitRequest({
    required this.name,
    required this.location,
    required this.area,
    required this.description,
    required this.existingClub,
    required this.clubPhotoInputs,
    required this.profileImage,
    required this.instagramHandle,
    required this.phoneNumber,
    required this.email,
    required this.hostDefaults,
  });

  factory HostClubCreateSubmitRequest.fromForm({
    required String name,
    required String? selectedCity,
    required String area,
    required String description,
    required Club? existingClub,
    required List<ClubPhotoInput>? clubPhotoInputs,
    required PickedClubProfileImage? profileImage,
    required String instagramHandle,
    required String phoneNumber,
    required String email,
    required ClubHostDefaults hostDefaults,
  }) {
    final location = selectedCity?.trim();
    if (location == null || location.isEmpty) {
      throw StateError('Missing selected city');
    }
    return HostClubCreateSubmitRequest(
      name: name.trim(),
      location: location,
      area: area.trim(),
      description: description.trim(),
      existingClub: existingClub,
      clubPhotoInputs: clubPhotoInputs,
      profileImage: profileImage,
      instagramHandle: _trimmedTextOrNull(instagramHandle),
      phoneNumber: _trimmedTextOrNull(phoneNumber),
      email: _trimmedTextOrNull(email),
      hostDefaults: hostDefaults,
    );
  }

  final String name;
  final String location;
  final String area;
  final String description;
  final Club? existingClub;
  final List<ClubPhotoInput>? clubPhotoInputs;
  final PickedClubProfileImage? profileImage;
  final String? instagramHandle;
  final String? phoneNumber;
  final String? email;
  final ClubHostDefaults hostDefaults;
}

@immutable
class HostClubCreateState {
  const HostClubCreateState({
    required this.isEditing,
    required this.mediaOnly,
    required this.currentStep,
    required this.totalSteps,
    required this.title,
    required this.subtitle,
    required this.showEditScaffold,
    required this.isLastStep,
    required this.canPickMedia,
    required this.footer,
    required this.editScaffold,
    required this.media,
    required this.fields,
    required this.editValidation,
    required this.draftRestore,
    required this.mutationError,
  });

  final bool isEditing;
  final bool mediaOnly;
  final int currentStep;
  final int totalSteps;
  final String title;
  final String? subtitle;
  final bool showEditScaffold;
  final bool isLastStep;
  final bool canPickMedia;
  final HostClubCreateFooterState footer;
  final HostClubEditScaffoldState? editScaffold;
  final HostClubCreateMediaState media;
  final HostClubCreateFieldDisplayState fields;
  final HostClubEditValidationState editValidation;
  final HostClubCreateDraftRestoreState draftRestore;
  final String? mutationError;

  bool get canSaveDraft => footer.canSaveDraft;
  String get lastStepLabel => footer.lastStepLabel;
  bool get isLoading => footer.isLoading;

  factory HostClubCreateState.resolve({
    required bool isEditing,
    required bool mediaOnly,
    required int currentStep,
    required List<CatchFormStepSpec> activeSteps,
    required Club? initialClub,
    required bool submitPending,
    required bool saveDraftPending,
    required String? mutationError,
    bool draftLoadPending = false,
    Object? draftLoadError,
    bool draftRestoreEnabled = true,
    List<OrderedPhotoPreview> clubPhotoPreviews = const [],
    PickedClubProfileImage? profileImage,
    bool editSubmitAttempted = false,
    AutovalidateMode formAutovalidateMode = AutovalidateMode.disabled,
    String name = '',
    String? selectedCity,
    String area = '',
    String description = '',
  }) {
    final totalSteps = activeSteps.length;
    final clampedStep = totalSteps == 0
        ? 0
        : currentStep.clamp(0, totalSteps - 1).toInt();
    final showEditScaffold = isEditing && !mediaOnly;
    final isLastStep =
        showEditScaffold || totalSteps == 0 || clampedStep == totalSteps - 1;
    final isLoading = showEditScaffold
        ? submitPending
        : submitPending || saveDraftPending;
    final canPickMedia = !submitPending;
    final lastStepLabel = mediaOnly
        ? 'Save photos'
        : isEditing
        ? 'Save changes'
        : 'Create club';
    final footer = HostClubCreateFooterState(
      isLastStep: isLastStep,
      isLoading: isLoading,
      primaryEnabled: !isLoading,
      primaryLabel: isLastStep ? lastStepLabel : 'Next',
      lastStepLabel: lastStepLabel,
      primaryIntent: isLastStep
          ? HostClubCreatePrimaryIntent.submit
          : HostClubCreatePrimaryIntent.nextStep,
      saveDraftIntent: !isEditing && !mediaOnly
          ? HostClubCreateSaveDraftIntent.saveDraft
          : null,
    );
    final media = HostClubCreateMediaState.resolve(
      enabled: canPickMedia,
      initialClub: initialClub,
      clubPhotoPreviews: clubPhotoPreviews,
      profileImage: profileImage,
    );
    final fields = HostClubCreateFieldDisplayState.resolve(
      mediaOnly: mediaOnly,
      selectedCityName: selectedCity,
    );
    final editValidation = HostClubEditValidationState.resolve(
      editSubmitAttempted: editSubmitAttempted,
      formAutovalidateMode: formAutovalidateMode,
      name: name,
      selectedCity: selectedCity,
      area: area,
      description: description,
    );
    final draftRestore = HostClubCreateDraftRestoreState.resolve(
      enabled: draftRestoreEnabled && !isEditing,
      loadPending: draftLoadPending,
      loadError: draftLoadError,
    );
    return HostClubCreateState(
      isEditing: isEditing,
      mediaOnly: mediaOnly,
      currentStep: clampedStep,
      totalSteps: totalSteps,
      title: totalSteps == 0 ? '' : formTitleForStep(activeSteps, clampedStep),
      subtitle: isEditing ? initialClub!.name : null,
      showEditScaffold: showEditScaffold,
      isLastStep: isLastStep,
      canPickMedia: canPickMedia,
      footer: footer,
      editScaffold: showEditScaffold
          ? HostClubEditScaffoldState(
              mediaEnabled: canPickMedia,
              cityPickerEnabled: canPickMedia,
              footer: footer,
            )
          : null,
      media: media,
      fields: fields,
      editValidation: editValidation,
      draftRestore: draftRestore,
      mutationError: mutationError,
    );
  }
}

@immutable
class HostClubSubmitOutcomeState {
  const HostClubSubmitOutcomeState({required this.shouldCloseRoute});

  final bool shouldCloseRoute;

  factory HostClubSubmitOutcomeState.fromTransition({
    required bool wasPending,
    required bool isSuccess,
  }) {
    return HostClubSubmitOutcomeState(
      shouldCloseRoute: wasPending && isSuccess,
    );
  }
}

String? _trimmedTextOrNull(String text) {
  final trimmed = text.trim();
  return trimmed.isEmpty ? null : trimmed;
}

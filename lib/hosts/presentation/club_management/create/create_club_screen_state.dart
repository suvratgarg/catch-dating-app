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
    required List<OrderedPhotoPreview> clubPhotoPreviews,
    required PickedClubProfileImage? profileImage,
  }) {
    return HostClubCreateMediaState(
      enabled: enabled,
      clubPhotoPreviews: List.unmodifiable(clubPhotoPreviews),
      existingCoverImageUrl: null,
      profileImageBytes: profileImage?.bytes,
      existingProfileImageUrl: null,
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
    required String? selectedCityName,
  }) {
    return HostClubCreateFieldDisplayState(
      detailsEnabled: true,
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
class HostClubCreateDraftRequest {
  const HostClubCreateDraftRequest({
    required this.name,
    required this.area,
    required this.description,
    required this.organizerType,
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
    OrganizerType organizerType = OrganizerType.club,
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
      organizerType: organizerType,
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
  final OrganizerType organizerType;
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
      organizerType: organizerType,
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
    required this.organizerType,
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
    OrganizerType organizerType = OrganizerType.club,
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
      organizerType: organizerType,
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
  final OrganizerType organizerType;
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
    required this.currentStep,
    required this.totalSteps,
    required this.title,
    required this.footer,
    required this.media,
    required this.fields,
    required this.draftRestore,
    required this.mutationError,
  });

  final int currentStep;
  final int totalSteps;
  final String title;
  final HostClubCreateFooterState footer;
  final HostClubCreateMediaState media;
  final HostClubCreateFieldDisplayState fields;
  final HostClubCreateDraftRestoreState draftRestore;
  final String? mutationError;

  String? get subtitle => null;
  bool get isLastStep => footer.isLastStep;
  bool get canPickMedia => media.enabled;
  bool get canSaveDraft => footer.canSaveDraft;
  String get lastStepLabel => footer.lastStepLabel;
  bool get isLoading => footer.isLoading;

  factory HostClubCreateState.resolve({
    required int currentStep,
    required List<CatchFormStepSpec> activeSteps,
    required bool submitPending,
    required bool saveDraftPending,
    required String? mutationError,
    bool draftLoadPending = false,
    Object? draftLoadError,
    bool draftRestoreEnabled = true,
    List<OrderedPhotoPreview> clubPhotoPreviews = const [],
    PickedClubProfileImage? profileImage,
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
    final isLastStep = totalSteps == 0 || clampedStep == totalSteps - 1;
    final isLoading = submitPending || saveDraftPending;
    final footer = HostClubCreateFooterState(
      isLastStep: isLastStep,
      isLoading: isLoading,
      primaryEnabled: !isLoading,
      primaryLabel: isLastStep ? 'Create club' : 'Next',
      lastStepLabel: 'Create club',
      primaryIntent: isLastStep
          ? HostClubCreatePrimaryIntent.submit
          : HostClubCreatePrimaryIntent.nextStep,
      saveDraftIntent: HostClubCreateSaveDraftIntent.saveDraft,
    );
    return HostClubCreateState(
      currentStep: clampedStep,
      totalSteps: totalSteps,
      title: totalSteps == 0 ? '' : formTitleForStep(activeSteps, clampedStep),
      footer: footer,
      media: HostClubCreateMediaState.resolve(
        enabled: !submitPending,
        clubPhotoPreviews: clubPhotoPreviews,
        profileImage: profileImage,
      ),
      fields: HostClubCreateFieldDisplayState.resolve(
        selectedCityName: selectedCity,
      ),
      draftRestore: HostClubCreateDraftRestoreState.resolve(
        enabled: draftRestoreEnabled,
        loadPending: draftLoadPending,
        loadError: draftLoadError,
      ),
      mutationError: mutationError,
    );
  }
}

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

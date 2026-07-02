import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/clubs/domain/club_host_defaults.dart';
import 'package:catch_dating_app/core/city_catalog.dart';
import 'package:catch_dating_app/core/widgets/catch_form_step_flow.dart';
import 'package:catch_dating_app/core/widgets/ordered_photo_picker.dart';
import 'package:catch_dating_app/hosts/presentation/club_management/create/create_club_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const steps = [
    CatchFormStepSpec(title: 'Club basics'),
    CatchFormStepSpec(title: 'Club details'),
    CatchFormStepSpec(title: 'Host defaults'),
  ];

  test('HostClubCreateState maps create wizard display state', () {
    final state = HostClubCreateState.resolve(
      isEditing: false,
      mediaOnly: false,
      currentStep: 1,
      activeSteps: steps,
      initialClub: null,
      submitPending: false,
      saveDraftPending: true,
      mutationError: 'Unable to save draft.',
    );

    expect(state.title, 'Club details');
    expect(state.subtitle, isNull);
    expect(state.currentStep, 1);
    expect(state.totalSteps, 3);
    expect(state.showEditScaffold, isFalse);
    expect(state.editScaffold, isNull);
    expect(state.isLastStep, isFalse);
    expect(state.canPickMedia, isTrue);
    expect(state.canSaveDraft, isTrue);
    expect(state.lastStepLabel, 'Create club');
    expect(state.isLoading, isTrue);
    expect(state.mutationError, 'Unable to save draft.');
    expect(state.footer.isLastStep, isFalse);
    expect(state.footer.isLoading, isTrue);
    expect(state.footer.primaryEnabled, isFalse);
    expect(state.footer.primaryLabel, 'Next');
    expect(state.footer.lastStepLabel, 'Create club');
    expect(state.footer.primaryIntent, HostClubCreatePrimaryIntent.nextStep);
    expect(
      state.footer.saveDraftIntent,
      HostClubCreateSaveDraftIntent.saveDraft,
    );
  });

  test('HostClubCreateState maps owner edit state', () {
    final club = Club(
      id: 'club-1',
      name: 'Sea Face Social',
      description: 'Hosted social formats.',
      location: 'Mumbai',
      area: 'Bandra',
      hostUserId: 'host-1',
      hostName: 'Mira',
      ownerUserId: 'host-1',
      hostUserIds: const ['host-1'],
      imageUrl: 'https://example.com/cover.jpg',
      profileImageUrl: 'https://example.com/profile.jpg',
      createdAt: DateTime(2026),
    );

    final ownerEdit = HostClubCreateState.resolve(
      isEditing: true,
      mediaOnly: false,
      currentStep: 9,
      activeSteps: steps,
      initialClub: club,
      submitPending: false,
      saveDraftPending: true,
      mutationError: null,
      selectedCity: club.location,
    );
    expect(ownerEdit.title, 'Host defaults');
    expect(ownerEdit.subtitle, 'Sea Face Social');
    expect(ownerEdit.showEditScaffold, isTrue);
    expect(ownerEdit.isLastStep, isTrue);
    expect(ownerEdit.isLoading, isFalse);
    expect(ownerEdit.canPickMedia, isTrue);
    expect(ownerEdit.canSaveDraft, isFalse);
    expect(ownerEdit.lastStepLabel, 'Save changes');
    expect(ownerEdit.footer.primaryLabel, 'Save changes');
    expect(ownerEdit.footer.primaryEnabled, isTrue);
    expect(ownerEdit.footer.primaryIntent, HostClubCreatePrimaryIntent.submit);
    expect(ownerEdit.footer.saveDraftIntent, isNull);
    expect(ownerEdit.editScaffold?.mediaEnabled, isTrue);
    expect(ownerEdit.editScaffold?.cityPickerEnabled, isTrue);
    expect(ownerEdit.editScaffold?.footer.primaryLabel, 'Save changes');
    expect(ownerEdit.fields.detailsEnabled, isTrue);
    expect(ownerEdit.fields.selectedCity, cityOptionByName('Mumbai'));
    expect(ownerEdit.fields.rawCityName, 'Mumbai');
    expect(ownerEdit.fields.currencyCode, 'INR');
    expect(ownerEdit.media.enabled, isTrue);
    expect(ownerEdit.media.clubPhotoPreviews, isEmpty);
    expect(ownerEdit.media.existingCoverImageUrl, club.imageUrl);
    expect(ownerEdit.media.existingProfileImageUrl, club.profileImageUrl);
    expect(
      ownerEdit.editValidation.autovalidateMode,
      AutovalidateMode.disabled,
    );
    expect(ownerEdit.editValidation.identityHasError, isFalse);
  });

  test('HostClubCreateState maps media-only edit state', () {
    final club = Club(
      id: 'club-1',
      name: 'Sea Face Social',
      description: 'Hosted social formats.',
      location: 'Mumbai',
      area: 'Bandra',
      hostUserId: 'host-1',
      hostName: 'Mira',
      ownerUserId: 'host-1',
      hostUserIds: const ['host-1'],
      imageUrl: 'https://example.com/cover.jpg',
      profileImageUrl: 'https://example.com/profile.jpg',
      createdAt: DateTime(2026),
    );

    final mediaOnly = HostClubCreateState.resolve(
      isEditing: true,
      mediaOnly: true,
      currentStep: 0,
      activeSteps: const [CatchFormStepSpec(title: 'Club photos')],
      initialClub: club,
      submitPending: true,
      saveDraftPending: false,
      mutationError: null,
      selectedCity: club.location,
    );
    expect(mediaOnly.showEditScaffold, isFalse);
    expect(mediaOnly.editScaffold, isNull);
    expect(mediaOnly.isLastStep, isTrue);
    expect(mediaOnly.canPickMedia, isFalse);
    expect(mediaOnly.canSaveDraft, isFalse);
    expect(mediaOnly.lastStepLabel, 'Save photos');
    expect(mediaOnly.isLoading, isTrue);
    expect(mediaOnly.footer.primaryLabel, 'Save photos');
    expect(mediaOnly.footer.primaryEnabled, isFalse);
    expect(mediaOnly.footer.primaryIntent, HostClubCreatePrimaryIntent.submit);
    expect(mediaOnly.footer.saveDraftIntent, isNull);
    expect(mediaOnly.fields.detailsEnabled, isFalse);
    expect(mediaOnly.fields.selectedCity, cityOptionByName('Mumbai'));
    expect(mediaOnly.media.enabled, isFalse);
  });

  test('HostClubCreateState maps city field display state from market id', () {
    final state = HostClubCreateState.resolve(
      isEditing: false,
      mediaOnly: false,
      currentStep: 0,
      activeSteps: steps,
      initialClub: null,
      submitPending: false,
      saveDraftPending: false,
      mutationError: null,
      selectedCity: 'in-mh-mumbai',
    );

    expect(state.fields.detailsEnabled, isTrue);
    expect(state.fields.selectedCity?.label, 'Mumbai');
    expect(state.fields.rawCityName, 'in-mh-mumbai');
    expect(state.fields.currencyCode, 'INR');
  });

  test('HostClubCreateState maps selected media display state', () {
    final club = Club(
      id: 'club-1',
      name: 'Sea Face Social',
      description: 'Hosted social formats.',
      location: 'Mumbai',
      area: 'Bandra',
      hostUserId: 'host-1',
      hostName: 'Mira',
      ownerUserId: 'host-1',
      hostUserIds: const ['host-1'],
      imageUrl: 'https://example.com/cover.jpg',
      profileImageUrl: 'https://example.com/profile.jpg',
      createdAt: DateTime(2026),
    );
    const pickedPreview = OrderedPhotoPreview(id: 'picked-1');

    final state = HostClubCreateState.resolve(
      isEditing: true,
      mediaOnly: false,
      currentStep: 0,
      activeSteps: steps,
      initialClub: club,
      submitPending: false,
      saveDraftPending: false,
      mutationError: null,
      clubPhotoPreviews: const [pickedPreview],
    );

    expect(state.media.clubPhotoPreviews, const [pickedPreview]);
    expect(state.media.existingCoverImageUrl, isNull);
    expect(state.media.existingProfileImageUrl, club.profileImageUrl);
  });

  test('HostClubCreateState maps edit validation display state', () {
    final club = Club(
      id: 'club-1',
      name: 'Sea Face Social',
      description: 'Hosted social formats.',
      location: 'Mumbai',
      area: 'Bandra',
      hostUserId: 'host-1',
      hostName: 'Mira',
      ownerUserId: 'host-1',
      hostUserIds: const ['host-1'],
      createdAt: DateTime(2026),
    );

    final state = HostClubCreateState.resolve(
      isEditing: true,
      mediaOnly: false,
      currentStep: 0,
      activeSteps: steps,
      initialClub: club,
      submitPending: false,
      saveDraftPending: false,
      mutationError: null,
      editSubmitAttempted: true,
      selectedCity: '',
    );

    expect(state.editValidation.shouldShowErrors, isTrue);
    expect(state.editValidation.autovalidateMode, AutovalidateMode.always);
    expect(state.editValidation.identityHasError, isTrue);
  });

  test('HostClubCreateDraftRequest trims optional draft fields', () {
    final request = HostClubCreateDraftRequest.fromForm(
      name: '  Sea Face Social  ',
      area: '   ',
      description: '  Hosted social formats. ',
      selectedCity: 'Mumbai',
      instagramHandle: '  seaface ',
      phoneNumber: '',
      email: ' host@example.com ',
      hostDefaults: const ClubHostDefaults(),
    );
    final draft = request.toDraft(savedAt: DateTime(2026));

    expect(draft.name, 'Sea Face Social');
    expect(draft.area, isNull);
    expect(draft.description, 'Hosted social formats.');
    expect(draft.location, 'Mumbai');
    expect(draft.instagramHandle, 'seaface');
    expect(draft.phoneNumber, isNull);
    expect(draft.email, 'host@example.com');
    expect(draft.savedAt, DateTime(2026));
  });

  test('HostClubCreateSubmitRequest trims submit fields', () {
    final request = HostClubCreateSubmitRequest.fromForm(
      name: '  Sea Face Social  ',
      selectedCity: ' Mumbai ',
      area: ' Bandra ',
      description: '  Hosted social formats. ',
      existingClub: null,
      clubPhotoInputs: null,
      profileImage: null,
      instagramHandle: ' seaface ',
      phoneNumber: ' ',
      email: ' host@example.com ',
      hostDefaults: const ClubHostDefaults(),
    );

    expect(request.name, 'Sea Face Social');
    expect(request.location, 'Mumbai');
    expect(request.area, 'Bandra');
    expect(request.description, 'Hosted social formats.');
    expect(request.instagramHandle, 'seaface');
    expect(request.phoneNumber, isNull);
    expect(request.email, 'host@example.com');
  });

  test('HostClubCreateSubmitRequest rejects missing city', () {
    expect(
      () => HostClubCreateSubmitRequest.fromForm(
        name: 'Sea Face Social',
        selectedCity: ' ',
        area: 'Bandra',
        description: 'Hosted social formats.',
        existingClub: null,
        clubPhotoInputs: null,
        profileImage: null,
        instagramHandle: '',
        phoneNumber: '',
        email: '',
        hostDefaults: const ClubHostDefaults(),
      ),
      throwsStateError,
    );
  });

  test(
    'HostClubSubmitOutcomeState closes only after pending submit success',
    () {
      expect(
        HostClubSubmitOutcomeState.fromTransition(
          wasPending: true,
          isSuccess: true,
        ).shouldCloseRoute,
        isTrue,
      );
      expect(
        HostClubSubmitOutcomeState.fromTransition(
          wasPending: false,
          isSuccess: true,
        ).shouldCloseRoute,
        isFalse,
      );
      expect(
        HostClubSubmitOutcomeState.fromTransition(
          wasPending: true,
          isSuccess: false,
        ).shouldCloseRoute,
        isFalse,
      );
    },
  );
}

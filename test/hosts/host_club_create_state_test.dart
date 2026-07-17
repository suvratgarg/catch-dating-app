import 'package:catch_dating_app/clubs/domain/club_host_defaults.dart';
import 'package:catch_dating_app/core/widgets/catch_form_step_flow.dart';
import 'package:catch_dating_app/core/widgets/ordered_photo_picker.dart';
import 'package:catch_dating_app/hosts/presentation/club_management/create/create_club_screen.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const steps = [
    CatchFormStepSpec(title: 'Club basics'),
    CatchFormStepSpec(title: 'Club details'),
    CatchFormStepSpec(title: 'Host defaults'),
  ];

  test('HostClubCreateState maps create wizard display state', () {
    final state = HostClubCreateState.resolve(
      currentStep: 1,
      activeSteps: steps,
      submitPending: false,
      saveDraftPending: true,
      mutationError: 'Unable to save draft.',
    );

    expect(state.title, 'Club details');
    expect(state.subtitle, isNull);
    expect(state.currentStep, 1);
    expect(state.totalSteps, 3);
    expect(state.isLastStep, isFalse);
    expect(state.canPickMedia, isTrue);
    expect(state.canSaveDraft, isTrue);
    expect(state.lastStepLabel, 'Create club');
    expect(state.isLoading, isTrue);
    expect(state.mutationError, 'Unable to save draft.');
    expect(state.footer.primaryEnabled, isFalse);
    expect(state.footer.primaryLabel, 'Next');
    expect(state.footer.primaryIntent, HostClubCreatePrimaryIntent.nextStep);
    expect(
      state.footer.saveDraftIntent,
      HostClubCreateSaveDraftIntent.saveDraft,
    );
  });

  test('HostClubCreateState maps draft restore retry and disable state', () {
    final error = StateError('Unable to reload draft.');
    final retry = HostClubCreateState.resolve(
      currentStep: 0,
      activeSteps: steps,
      submitPending: false,
      saveDraftPending: false,
      draftLoadError: error,
      mutationError: null,
    );
    final disabled = HostClubCreateState.resolve(
      currentStep: 0,
      activeSteps: steps,
      submitPending: false,
      saveDraftPending: false,
      draftLoadError: error,
      draftRestoreEnabled: false,
      mutationError: null,
    );

    expect(retry.draftRestore.error, error);
    expect(
      retry.draftRestore.retryIntent,
      HostClubCreateDraftRestoreIntent.retry,
    );
    expect(disabled.draftRestore.hasError, isFalse);
  });

  test('HostClubCreateState maps city and selected media', () {
    const pickedPreview = OrderedPhotoPreview(id: 'picked-1');
    final state = HostClubCreateState.resolve(
      currentStep: 0,
      activeSteps: steps,
      submitPending: false,
      saveDraftPending: false,
      mutationError: null,
      selectedCity: 'in-mh-mumbai',
      clubPhotoPreviews: const [pickedPreview],
    );

    expect(state.fields.detailsEnabled, isTrue);
    expect(state.fields.selectedCity?.label, 'Mumbai');
    expect(state.fields.currencyCode, 'INR');
    expect(state.media.clubPhotoPreviews, const [pickedPreview]);
    expect(state.media.existingCoverImageUrl, isNull);
    expect(state.media.existingProfileImageUrl, isNull);
  });

  test('HostClubCreate route intents carry typed callback payloads', () {
    const reorderIntent = HostClubCreateReorderClubPhotoIntent(
      fromIndex: 1,
      toIndex: 3,
    );
    final defaults = ClubHostDefaults(
      eventPolicy: const ClubHostDefaults().eventPolicy.copyWith(minAge: 24),
    );

    expect((const HostClubCreateRemoveClubPhotoIntent(2)).index, 2);
    expect(reorderIntent.fromIndex, 1);
    expect(reorderIntent.toIndex, 3);
    expect(HostClubCreateDefaultsChangedIntent(defaults).defaults, defaults);
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
    expect(draft.instagramHandle, 'seaface');
    expect(draft.phoneNumber, isNull);
    expect(draft.email, 'host@example.com');
  });

  test('HostClubCreateSubmitRequest trims fields and requires city', () {
    final request = HostClubCreateSubmitRequest.fromForm(
      name: '  Sea Face Social  ',
      selectedCity: ' Mumbai ',
      area: ' Bandra ',
      description: '  Hosted social formats. ',
      clubPhotoInputs: null,
      profileImage: null,
      instagramHandle: ' seaface ',
      phoneNumber: ' ',
      email: ' host@example.com ',
      hostDefaults: const ClubHostDefaults(),
    );

    expect(request.name, 'Sea Face Social');
    expect(request.location, 'Mumbai');
    expect(request.phoneNumber, isNull);
    expect(
      () => HostClubCreateSubmitRequest.fromForm(
        name: 'Sea Face Social',
        selectedCity: ' ',
        area: 'Bandra',
        description: 'Hosted social formats.',
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

  test('HostClubSubmitOutcomeState closes only after pending success', () {
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
  });
}

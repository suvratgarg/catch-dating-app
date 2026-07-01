import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/core/widgets/catch_form_step_flow.dart';
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
  });
}

import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/core/widgets/catch_form_step_flow.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/create/create_event_schedule_state.dart';
import 'package:flutter/material.dart';

enum CreateEventWizardBackIntent { previousStep, confirmUnsavedChanges, close }

enum CreateEventWizardPrimaryIntent { nextStep, submit }

enum CreateEventWizardSaveDraftIntent { saveDraft }

enum CreateEventSuccessNavigationIntent { manageEvent, backToClub }

enum CreateEventSuccessNavigationDestination { manageEventRoute, popRoute }

enum CreateEventWizardStep {
  eventDetails('Event basics'),
  meetingLocation('Meeting location'),
  schedule('When is the event?', validatesSchedule: true),
  eventPolicy('Event policy'),
  eventSuccessGuide('Live event guide');

  const CreateEventWizardStep(this.title, {this.validatesSchedule = false});

  final String title;
  final bool validatesSchedule;

  CatchFormStepSpec toSpec({GlobalKey<FormState>? formKey}) {
    return CatchFormStepSpec(title: title, formKey: formKey);
  }

  static CreateEventWizardStep? fromIndex(int index) {
    if (index < 0 || index >= values.length) return null;
    return values[index];
  }
}

List<CatchFormStepSpec> createEventWizardStepSpecs({
  required GlobalKey<FormState> eventDetailsFormKey,
  required GlobalKey<FormState> meetingLocationFormKey,
  required GlobalKey<FormState> scheduleFormKey,
  required GlobalKey<FormState> eventPolicyFormKey,
}) {
  return [
    CreateEventWizardStep.eventDetails.toSpec(formKey: eventDetailsFormKey),
    CreateEventWizardStep.meetingLocation.toSpec(
      formKey: meetingLocationFormKey,
    ),
    CreateEventWizardStep.schedule.toSpec(formKey: scheduleFormKey),
    CreateEventWizardStep.eventPolicy.toSpec(formKey: eventPolicyFormKey),
    CreateEventWizardStep.eventSuccessGuide.toSpec(),
  ];
}

bool createEventWizardStepValidatesSchedule(int index) {
  return CreateEventWizardStep.fromIndex(index)?.validatesSchedule ?? false;
}

class CreateEventSuccessNavigationState {
  const CreateEventSuccessNavigationState({
    required this.club,
    required this.event,
    required this.inviteCode,
  });

  final Club club;
  final Event event;
  final String? inviteCode;
}

class CreateEventSuccessNavigationEffect {
  const CreateEventSuccessNavigationEffect({
    required this.destination,
    this.pathParameters = const <String, String>{},
    this.extra,
  });

  factory CreateEventSuccessNavigationEffect.resolve({
    required CreateEventSuccessNavigationIntent intent,
    required CreateEventSuccessNavigationState state,
  }) {
    return switch (intent) {
      CreateEventSuccessNavigationIntent.manageEvent =>
        CreateEventSuccessNavigationEffect(
          destination: CreateEventSuccessNavigationDestination.manageEventRoute,
          pathParameters: {'clubId': state.club.id, 'eventId': state.event.id},
          extra: state.event,
        ),
      CreateEventSuccessNavigationIntent.backToClub =>
        const CreateEventSuccessNavigationEffect(
          destination: CreateEventSuccessNavigationDestination.popRoute,
        ),
    };
  }

  final CreateEventSuccessNavigationDestination destination;
  final Map<String, String> pathParameters;
  final Event? extra;
}

class CreateEventWizardValidationPlan {
  const CreateEventWizardValidationPlan({
    required this.formKey,
    required this.scheduleValidation,
  });

  factory CreateEventWizardValidationPlan.resolve({
    required List<CatchFormStepSpec> activeSteps,
    required int currentStep,
    required CreateEventScheduleState scheduleState,
    required DateTime now,
  }) {
    return CreateEventWizardValidationPlan(
      formKey: formKeyForStep(activeSteps, currentStep),
      scheduleValidation: scheduleState.validate(
        isScheduleStep: createEventWizardStepValidatesSchedule(currentStep),
        now: now,
      ),
    );
  }

  final GlobalKey<FormState>? formKey;
  final CreateEventScheduleValidationResult scheduleValidation;

  bool get scheduleAllowsContinue => scheduleValidation.isValid;
  String? get scheduleErrorText => scheduleValidation.errorText;
}

class CreateEventWizardState {
  const CreateEventWizardState({
    required this.club,
    required this.currentStep,
    required this.currentStepKind,
    required this.totalSteps,
    required this.title,
    required this.isLastStep,
    required this.isLoading,
    required this.canSaveDraft,
    required this.primaryActionLabel,
    required this.backIntent,
    required this.primaryIntent,
    required this.saveDraftIntent,
    required this.mutationError,
    required this.createdEvent,
    required this.inviteCode,
    required this.successNavigation,
  });

  final Club club;
  final int currentStep;
  final CreateEventWizardStep? currentStepKind;
  final int totalSteps;
  final String title;
  final bool isLastStep;
  final bool isLoading;
  final bool canSaveDraft;
  final String primaryActionLabel;
  final CreateEventWizardBackIntent backIntent;
  final CreateEventWizardPrimaryIntent primaryIntent;
  final CreateEventWizardSaveDraftIntent? saveDraftIntent;
  final String? mutationError;
  final Event? createdEvent;
  final String? inviteCode;
  final CreateEventSuccessNavigationState? successNavigation;

  factory CreateEventWizardState.resolve({
    required Club club,
    required List<CatchFormStepSpec> activeSteps,
    required int currentStep,
    required bool submitPending,
    required bool saveDraftPending,
    required String? mutationError,
    required Event? createdEvent,
    required String? inviteCode,
    bool canSaveDraft = true,
    bool hasUnsavedChanges = false,
  }) {
    final totalSteps = activeSteps.length;
    final boundedStep = totalSteps == 0
        ? 0
        : currentStep.clamp(0, totalSteps - 1).toInt();
    final stepKind = CreateEventWizardStep.fromIndex(boundedStep);
    final isLastStep = totalSteps == 0 || boundedStep == totalSteps - 1;
    final canShowSaveDraft = canSaveDraft && createdEvent == null;
    final successNavigation = createdEvent == null
        ? null
        : CreateEventSuccessNavigationState(
            club: club,
            event: createdEvent,
            inviteCode: inviteCode,
          );
    return CreateEventWizardState(
      club: club,
      currentStep: boundedStep,
      currentStepKind: stepKind,
      totalSteps: totalSteps,
      title: totalSteps == 0 ? '' : formTitleForStep(activeSteps, boundedStep),
      isLastStep: isLastStep,
      isLoading: submitPending || saveDraftPending,
      canSaveDraft: canShowSaveDraft,
      primaryActionLabel: isLastStep ? 'Schedule event' : 'Next',
      backIntent: _backIntentFor(
        currentStep: boundedStep,
        hasUnsavedChanges: hasUnsavedChanges,
      ),
      primaryIntent: isLastStep
          ? CreateEventWizardPrimaryIntent.submit
          : CreateEventWizardPrimaryIntent.nextStep,
      saveDraftIntent: canShowSaveDraft
          ? CreateEventWizardSaveDraftIntent.saveDraft
          : null,
      mutationError: mutationError,
      createdEvent: createdEvent,
      inviteCode: inviteCode,
      successNavigation: successNavigation,
    );
  }

  static CreateEventWizardBackIntent _backIntentFor({
    required int currentStep,
    required bool hasUnsavedChanges,
  }) {
    if (currentStep > 0) return CreateEventWizardBackIntent.previousStep;
    return hasUnsavedChanges
        ? CreateEventWizardBackIntent.confirmUnsavedChanges
        : CreateEventWizardBackIntent.close;
  }
}

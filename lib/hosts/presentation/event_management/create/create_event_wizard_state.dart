import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/core/country_markets.dart';
import 'package:catch_dating_app/core/widgets/catch_form_step_flow.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/create/create_event_policy_state.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/create/create_event_schedule_state.dart';
import 'package:flutter/material.dart';

enum CreateEventWizardCloseIntent { confirmUnsavedChanges, close }

enum CreateEventWizardPreviousIntent { previousStep, returnToSteps }

enum CreateEventWizardPrimaryIntent { nextStep, review, submit }

enum CreateEventSuccessNavigationIntent { manageEvent, backToClub }

enum CreateEventSuccessNavigationDestination { manageEventRoute, popRoute }

enum CreateEventWizardStep {
  eventDetails('Event basics'),
  meetingLocation('Meeting location'),
  schedule('When is the event?', validatesSchedule: true),
  eventPolicy('Event policy'),
  eventSuccessGuide('Live event guide', optional: true);

  const CreateEventWizardStep(
    this.title, {
    this.validatesSchedule = false,
    this.optional = false,
  });

  final String title;
  final bool validatesSchedule;
  final bool optional;

  CatchFormStepSpec toSpec({GlobalKey<FormState>? formKey}) {
    return CatchFormStepSpec(
      title: title,
      formKey: formKey,
      optional: optional,
    );
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

@immutable
class CreateEventWizardReviewState {
  const CreateEventWizardReviewState({required this.formReview});

  factory CreateEventWizardReviewState.resolve({
    required List<CatchFormStepSpec> activeSteps,
    required ActivityKind activityKind,
    required String customActivityLabel,
    required String distance,
    required PaceLevel? pace,
    required bool externalBookingMode,
    required String externalEventUrl,
    bool rosterAttachmentRequired = false,
    required bool hasStartingPoint,
    required String meetingPoint,
    required CreateEventScheduleState scheduleState,
    required DateTime now,
    required String capacity,
    int? rosterReadyCount,
    required String price,
    required String currencyCode,
    required EventAdmissionPreset admissionPreset,
    required String inviteCode,
    required bool cohortCapsEnabled,
    required String maxMen,
    required String maxWomen,
    required bool crossPathsPairInventoryEnabled,
    required String crossPathsPairCapacity,
    required bool dynamicPricingEnabled,
    required String dynamicPricingStep,
    required String dynamicPricingMax,
    required String minAge,
    required String maxAge,
  }) {
    final completion = <bool>[
      _eventDetailsReady(
        activityKind: activityKind,
        customActivityLabel: customActivityLabel,
        distance: distance,
        pace: pace,
        externalBookingMode: externalBookingMode,
        externalEventUrl: externalEventUrl,
        rosterAttachmentRequired: rosterAttachmentRequired,
      ),
      hasStartingPoint && meetingPoint.trim().isNotEmpty,
      scheduleState.selectedStartDateTime?.isAfter(now) == true,
      _eventPolicyReady(
        capacity: capacity,
        rosterReadyCount: rosterReadyCount,
        price: price,
        currencyCode: currencyCode,
        admissionPreset: admissionPreset,
        inviteCode: inviteCode,
        cohortCapsEnabled: cohortCapsEnabled,
        maxMen: maxMen,
        maxWomen: maxWomen,
        crossPathsPairInventoryEnabled: crossPathsPairInventoryEnabled,
        crossPathsPairCapacity: crossPathsPairCapacity,
        dynamicPricingEnabled: dynamicPricingEnabled,
        dynamicPricingStep: dynamicPricingStep,
        dynamicPricingMax: dynamicPricingMax,
        minAge: minAge,
        maxAge: maxAge,
      ),
      true,
    ];
    final items = <CatchFormStepReviewItem>[
      for (var index = 0; index < activeSteps.length; index++)
        CatchFormStepReviewItem(
          index: index,
          title: activeSteps[index].title,
          status: activeSteps[index].optional
              ? CatchFormStepStatus.optional
              : completion[index]
              ? CatchFormStepStatus.complete
              : CatchFormStepStatus.needsInformation,
        ),
    ];
    return CreateEventWizardReviewState(
      formReview: CatchFormReviewState(List.unmodifiable(items)),
    );
  }

  final CatchFormReviewState formReview;

  bool get canSubmit => formReview.canSubmit;
  int? get firstIncompleteStep => formReview.firstIncompleteStep;
  List<CatchFormStepReviewItem> get items => formReview.items;

  static bool _eventDetailsReady({
    required ActivityKind activityKind,
    required String customActivityLabel,
    required String distance,
    required PaceLevel? pace,
    required bool externalBookingMode,
    required String externalEventUrl,
    required bool rosterAttachmentRequired,
  }) {
    if (rosterAttachmentRequired) return false;
    if (externalBookingMode && externalEventUrl.trim().isNotEmpty) {
      final uri = Uri.tryParse(externalEventUrl.trim());
      if (uri == null || uri.scheme != 'https' || uri.host.isEmpty) {
        return false;
      }
    }
    if (activityKind == ActivityKind.openActivity) {
      final label = customActivityLabel.trim();
      return label.length >= 3 && label.length <= 64;
    }
    if (!activityKind.isDistanceBased) return true;
    final parsedDistance = double.tryParse(distance.trim());
    return parsedDistance != null && parsedDistance > 0 && pace != null;
  }

  static bool _eventPolicyReady({
    required String capacity,
    int? rosterReadyCount,
    required String price,
    required String currencyCode,
    required EventAdmissionPreset admissionPreset,
    required String inviteCode,
    required bool cohortCapsEnabled,
    required String maxMen,
    required String maxWomen,
    required bool crossPathsPairInventoryEnabled,
    required String crossPathsPairCapacity,
    required bool dynamicPricingEnabled,
    required String dynamicPricingStep,
    required String dynamicPricingMax,
    required String minAge,
    required String maxAge,
  }) {
    final parsedCapacity = int.tryParse(capacity.trim());
    if (parsedCapacity == null || parsedCapacity < 1) return false;
    if (rosterReadyCount != null && parsedCapacity < rosterReadyCount) {
      return false;
    }
    if (parseMajorCurrencyAmountToMinorUnits(
          price,
          currencyCode: currencyCode,
        ) ==
        null) {
      return false;
    }
    if (admissionPreset == EventAdmissionPreset.inviteOnly) {
      final codeLength = inviteCode.trim().length;
      if (codeLength < 4 || codeLength > 64) return false;
    }
    if (cohortCapsEnabled &&
        (!_optionalPositiveInt(maxMen) || !_optionalPositiveInt(maxWomen))) {
      return false;
    }
    if (crossPathsPairInventoryEnabled) {
      final pairCapacity = int.tryParse(crossPathsPairCapacity.trim());
      if (pairCapacity == null ||
          pairCapacity < 1 ||
          pairCapacity > parsedCapacity) {
        return false;
      }
    }
    if (dynamicPricingEnabled &&
        (!_requiredPositiveInt(dynamicPricingStep) ||
            !_requiredPositiveInt(dynamicPricingMax))) {
      return false;
    }
    return _ageRangeReady(minAge: minAge, maxAge: maxAge);
  }

  static bool _optionalPositiveInt(String value) =>
      value.trim().isEmpty || _requiredPositiveInt(value);

  static bool _requiredPositiveInt(String value) {
    final parsed = int.tryParse(value.trim());
    return parsed != null && parsed >= 1;
  }

  static bool _ageRangeReady({required String minAge, required String maxAge}) {
    final minText = minAge.trim();
    final maxText = maxAge.trim();
    final min = minText.isEmpty ? null : int.tryParse(minText);
    final max = maxText.isEmpty ? null : int.tryParse(maxText);
    if (minText.isNotEmpty && (min == null || min < 18 || min > 99)) {
      return false;
    }
    if (maxText.isNotEmpty && (max == null || max < 18 || max > 99)) {
      return false;
    }
    return min == null || max == null || min <= max;
  }
}

class CreateEventWizardState {
  const CreateEventWizardState({
    required this.club,
    required this.currentStep,
    required this.currentStepKind,
    required this.totalSteps,
    required this.title,
    required this.isLastStep,
    required this.isReviewing,
    required this.isLoading,
    required this.primaryEnabled,
    required this.closeIntent,
    required this.previousIntent,
    required this.primaryIntent,
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
  final bool isReviewing;
  final bool isLoading;
  final bool primaryEnabled;
  final CreateEventWizardCloseIntent closeIntent;
  final CreateEventWizardPreviousIntent? previousIntent;
  final CreateEventWizardPrimaryIntent primaryIntent;
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
    bool hasUnsavedChanges = false,
    bool isReviewing = false,
    CreateEventWizardReviewState? reviewState,
  }) {
    final totalSteps = activeSteps.length;
    final boundedStep = totalSteps == 0
        ? 0
        : currentStep.clamp(0, totalSteps - 1).toInt();
    final stepKind = CreateEventWizardStep.fromIndex(boundedStep);
    final isLastStep = totalSteps == 0 || boundedStep == totalSteps - 1;
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
      isReviewing: isReviewing,
      isLoading: submitPending || saveDraftPending,
      primaryEnabled:
          !submitPending &&
          !saveDraftPending &&
          (!isReviewing || (reviewState?.canSubmit ?? false)),
      closeIntent: _closeIntentFor(hasUnsavedChanges: hasUnsavedChanges),
      previousIntent: isReviewing
          ? CreateEventWizardPreviousIntent.returnToSteps
          : boundedStep > 0
          ? CreateEventWizardPreviousIntent.previousStep
          : null,
      primaryIntent: isReviewing
          ? CreateEventWizardPrimaryIntent.submit
          : isLastStep
          ? CreateEventWizardPrimaryIntent.review
          : CreateEventWizardPrimaryIntent.nextStep,
      mutationError: mutationError,
      createdEvent: createdEvent,
      inviteCode: inviteCode,
      successNavigation: successNavigation,
    );
  }

  static CreateEventWizardCloseIntent _closeIntentFor({
    required bool hasUnsavedChanges,
  }) {
    return hasUnsavedChanges
        ? CreateEventWizardCloseIntent.confirmUnsavedChanges
        : CreateEventWizardCloseIntent.close;
  }
}

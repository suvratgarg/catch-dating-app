import 'package:catch_dating_app/event_success/domain/event_success_assignment.dart';
import 'package:catch_dating_app/event_success/presentation/event_success_room_map.dart'
    show EventSuccessSpatialPreview, EventSuccessSpatialReassign;
import 'package:flutter/foundation.dart';

class EventSuccessHostFixtureActions {
  const EventSuccessHostFixtureActions({
    this.onSaveSetup,
    this.onPreviousStep,
    this.onNextStep,
    this.onCompletePlan,
    this.onGenerateMicroPods,
    this.onOverrideGroupAssignments,
    this.onGenerateGuidedRotations,
    this.onOverrideGuidedRotations,
    this.onStartRevealCountdown,
    this.onRevealRound,
    this.onResetReveal,
    this.onPreviewSpatial,
    this.onReassignSpatial,
    this.onConfirmSpatial,
    this.onReleaseSpatial,
    this.initialSpatialSelectionUid,
  });

  final VoidCallback? onSaveSetup;
  final VoidCallback? onPreviousStep;
  final VoidCallback? onNextStep;
  final VoidCallback? onCompletePlan;
  final VoidCallback? onGenerateMicroPods;
  final ValueChanged<List<EventSuccessGroupOverrideRound>>?
  onOverrideGroupAssignments;
  final VoidCallback? onGenerateGuidedRotations;
  final ValueChanged<List<EventSuccessRotationOverrideRound>>?
  onOverrideGuidedRotations;
  final void Function(int roundIndex, int countdownSeconds)?
  onStartRevealCountdown;
  final ValueChanged<int>? onRevealRound;
  final VoidCallback? onResetReveal;
  final EventSuccessSpatialPreview? onPreviewSpatial;
  final EventSuccessSpatialReassign? onReassignSpatial;
  final Future<void> Function(EventSuccessAssignment assignment)?
  onConfirmSpatial;
  final Future<void> Function(EventSuccessAssignment assignment)?
  onReleaseSpatial;
  final String? initialSpatialSelectionUid;
}

import 'package:catch_dating_app/auth/require_signed_in_uid.dart';
import 'package:catch_dating_app/event_success/data/event_success_repository.dart';
import 'package:catch_dating_app/event_success/domain/event_success_feature_state.dart';
import 'package:catch_dating_app/event_success/domain/event_success_plan.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/public_profile/domain/public_profile.dart';
import 'package:flutter_riverpod/experimental/mutation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'event_success_controller.g.dart';

@riverpod
class EventSuccessController extends _$EventSuccessController {
  static final ensurePlanMutation = Mutation<EventSuccessPlan>();
  static final saveSetupMutation = Mutation<void>();
  static final updateStepMutation = Mutation<void>();
  static final completePlanMutation = Mutation<void>();
  static final feedbackMutation = Mutation<void>();
  static final privateCrushMutation = Mutation<void>();

  @override
  void build() {}

  Future<EventSuccessPlan> ensurePlan(Event event) async {
    requireSignedInUid(ref, action: 'set up event success');
    return ref.read(eventSuccessRepositoryProvider).ensurePlanForEvent(event);
  }

  Future<void> saveSetup({
    required EventSuccessPlan plan,
    required EventSuccessHostDraft draft,
  }) async {
    requireSignedInUid(ref, action: 'save event success setup');
    await ref
        .read(eventSuccessRepositoryProvider)
        .savePlan(plan.copyWithDraft(draft, updatedAt: DateTime.now()));
  }

  Future<void> updateActiveStep({
    required String eventId,
    required int activeStepIndex,
  }) async {
    requireSignedInUid(ref, action: 'run event success live mode');
    await ref
        .read(eventSuccessRepositoryProvider)
        .updateActiveStep(eventId: eventId, activeStepIndex: activeStepIndex);
  }

  Future<void> completePlan(String eventId) async {
    requireSignedInUid(ref, action: 'complete event success plan');
    await ref
        .read(eventSuccessRepositoryProvider)
        .completePlan(eventId: eventId);
  }

  Future<void> submitFeedback(EventSuccessFeedback feedback) async {
    requireSignedInUid(ref, action: 'submit event feedback');
    await ref.read(eventSuccessRepositoryProvider).submitFeedback(feedback);
  }

  Future<void> markPrivateCrush({
    required String eventId,
    required PublicProfile target,
  }) async {
    final uid = requireSignedInUid(ref, action: 'mark a private crush');
    await ref
        .read(eventSuccessRepositoryProvider)
        .markPrivateCrush(eventId: eventId, currentUid: uid, target: target);
  }
}

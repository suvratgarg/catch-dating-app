import 'dart:math';

import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/auth/require_signed_in_uid.dart';
import 'package:catch_dating_app/event_success/data/event_assistance_participation_repository.dart';
import 'package:catch_dating_app/event_success/domain/event_assistance_participation.dart';
import 'package:catch_dating_app/exceptions/app_exception.dart';
import 'package:flutter_riverpod/experimental/mutation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'event_assistance_participation_controller.g.dart';

final class EventParticipationSession {
  const EventParticipationSession({
    required this.accountId,
    required this.view,
  });

  final String accountId;
  final EventAssistanceParticipationView view;
}

typedef EventParticipationMutationKey = ({
  String accountId,
  EventAssistanceGuestScope scope,
});

final class EventParticipationPendingAction {
  const EventParticipationPendingAction._({
    required this.accountId,
    required this.change,
  });

  final String accountId;
  final EventAssistanceParticipationChange change;

  EventParticipationMutationKey get mutationKey =>
      (accountId: accountId, scope: change.snapshot.scope);
}

@riverpod
Future<EventParticipationSession> eventAssistanceParticipation(
  Ref ref,
  EventAssistanceGuestScope scope,
) async {
  final accountId = await ref.watch(uidProvider.future);
  if (accountId == null || accountId.isEmpty) {
    throw const SignInRequiredException('load guest participation');
  }
  final view = await ref
      .watch(eventAssistanceParticipationRepositoryProvider)
      .fetch(scope);
  return EventParticipationSession(accountId: accountId, view: view);
}

@riverpod
class EventAssistanceParticipationController
    extends _$EventAssistanceParticipationController {
  static final changeMutation = Mutation<EventAssistanceParticipationResult>();

  @override
  void build() {}

  EventParticipationPendingAction prepare({
    required EventParticipationSession session,
    required EventAssistanceParticipation participation,
  }) {
    _requireAccount(session.accountId);
    final random = Random.secure();
    final operationId = List.generate(
      16,
      (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0'),
    ).join();
    return EventParticipationPendingAction._(
      accountId: session.accountId,
      change: session.view.prepareChange(
        operationId: 'participation:$operationId',
        participation: participation,
      ),
    );
  }

  Future<EventAssistanceParticipationResult> submit(
    EventParticipationPendingAction action,
  ) async {
    _requireAccount(action.accountId);
    final result = await ref
        .read(eventAssistanceParticipationRepositoryProvider)
        .apply(action.change);
    if (ref.mounted) {
      _requireAccount(action.accountId);
      ref.invalidate(
        eventAssistanceParticipationProvider(action.change.snapshot.scope),
      );
    }
    return result;
  }

  void _requireAccount(String expected) {
    final accountId = requireSignedInUid(
      ref,
      action: 'update guest participation',
    );
    if (accountId != expected) {
      throw const BackendOperationException(
        code: 'session-changed',
        message: 'Your sign-in changed. Reload this guest before continuing.',
        context: BackendErrorContext(
          service: BackendService.functions,
          action: 'update guest participation',
          resource: 'eventAssistanceGuests',
        ),
      );
    }
  }
}

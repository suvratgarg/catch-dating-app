import 'package:catch_dating_app/cross_paths/data/cross_paths_repository.dart';
import 'package:catch_dating_app/cross_paths/domain/cross_paths_invitation.dart';
import 'package:catch_dating_app/cross_paths/presentation/cross_paths_invitation_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeCrossPathsRepository extends Fake implements CrossPathsRepository {
  Object? error;
  final calls = <String>[];

  @override
  Future<CrossPathsInvitationReceipt> sendInvitation({
    required String eventId,
    required String recipientUid,
    required String suggestionToken,
  }) async {
    calls.add('send:$eventId:$recipientUid:$suggestionToken');
    final failure = error;
    if (failure != null) throw failure;
    return const CrossPathsInvitationReceipt(
      invitationId: 'invitation-1',
      status: CrossPathsInvitationStatus.pending,
      conversationId: null,
    );
  }

  @override
  Future<CrossPathsInvitationReceipt> respondToInvitation({
    required String invitationId,
    required bool accept,
  }) async {
    calls.add('respond:$invitationId:$accept');
    final failure = error;
    if (failure != null) throw failure;
    return CrossPathsInvitationReceipt(
      invitationId: invitationId,
      status: accept
          ? CrossPathsInvitationStatus.accepted
          : CrossPathsInvitationStatus.declined,
      conversationId: accept ? 'plan-1' : null,
    );
  }

  @override
  Future<CrossPathsInvitationReceipt> cancelInvitationOrPlan(
    String invitationId,
  ) async {
    calls.add('cancel:$invitationId');
    final failure = error;
    if (failure != null) throw failure;
    return CrossPathsInvitationReceipt(
      invitationId: invitationId,
      status: CrossPathsInvitationStatus.cancelled,
      conversationId: null,
    );
  }
}

void main() {
  test('controller exposes typed send, respond, and cancel receipts', () async {
    final repository = _FakeCrossPathsRepository();
    final container = ProviderContainer(
      overrides: [crossPathsRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
    final controller = container.read(
      crossPathsInvitationControllerProvider.notifier,
    );

    final sent = await controller.send(
      eventId: 'event-1',
      recipientUid: 'runner-2',
      suggestionToken: 'token-1',
    );
    final accepted = await controller.respond(
      invitationId: sent.invitationId,
      accept: true,
    );
    final cancelled = await controller.cancel(sent.invitationId);

    expect(accepted.conversationId, 'plan-1');
    expect(cancelled.status, CrossPathsInvitationStatus.cancelled);
    expect(repository.calls, [
      'send:event-1:runner-2:token-1',
      'respond:invitation-1:true',
      'cancel:invitation-1',
    ]);
  });

  test('controller preserves a failed mutation as AsyncError', () async {
    final repository = _FakeCrossPathsRepository()
      ..error = StateError('unavailable');
    final container = ProviderContainer(
      overrides: [crossPathsRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
    final controller = container.read(
      crossPathsInvitationControllerProvider.notifier,
    );

    await expectLater(
      controller.cancel('invitation-1'),
      throwsA(anything),
    );
    final state = container.read(crossPathsInvitationControllerProvider);
    expect(state, isA<AsyncError<CrossPathsInvitationReceipt?>>());
    expect(state.error, isA<StateError>());
  });
}

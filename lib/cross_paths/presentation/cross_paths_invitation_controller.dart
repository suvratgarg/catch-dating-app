import 'dart:async';

import 'package:catch_dating_app/cross_paths/data/cross_paths_repository.dart';
import 'package:catch_dating_app/cross_paths/domain/cross_paths_invitation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'cross_paths_invitation_controller.g.dart';

@riverpod
class CrossPathsInvitationController extends _$CrossPathsInvitationController {
  @override
  FutureOr<CrossPathsInvitationReceipt?> build() => null;

  Future<CrossPathsInvitationReceipt> send({
    required String eventId,
    required String recipientUid,
    required String suggestionToken,
  }) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () => ref
          .read(crossPathsRepositoryProvider)
          .sendInvitation(
            eventId: eventId,
            recipientUid: recipientUid,
            suggestionToken: suggestionToken,
          ),
    );
    state = result;
    return result.requireValue;
  }

  Future<CrossPathsInvitationReceipt> respond({
    required String invitationId,
    required bool accept,
  }) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () => ref
          .read(crossPathsRepositoryProvider)
          .respondToInvitation(invitationId: invitationId, accept: accept),
    );
    state = result;
    return result.requireValue;
  }

  Future<CrossPathsInvitationReceipt> cancel(String invitationId) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () => ref
          .read(crossPathsRepositoryProvider)
          .cancelInvitationOrPlan(invitationId),
    );
    state = result;
    return result.requireValue;
  }
}

import 'package:catch_dating_app/auth/data/authenticated_session.dart';
import 'package:catch_dating_app/event_rehearsal/data/event_rehearsal_repository.dart';
import 'package:catch_dating_app/event_rehearsal/domain/event_rehearsal.dart';
import 'package:catch_dating_app/event_rehearsal/domain/event_rehearsal_movement.dart';
import 'package:catch_dating_app/event_rehearsal/presentation/event_rehearsal_assistance_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'event_rehearsal_movement_view_model.g.dart';

final class RehearsalMovementPage {
  RehearsalMovementPage._(this.account, this.session, this.snapshot);
  final AuthenticatedSession account;
  final EventRehearsalBootstrap session;
  final RehearsalMovementReview snapshot;
  bool _current = true;
  bool get isCurrent => _current;
}

@riverpod
class EventRehearsalMovement extends _$EventRehearsalMovement {
  @override
  AsyncValue<RehearsalMovementPage> build(
    RehearsalMovementSelection selection,
  ) {
    final auth = ref.watch(authenticatedSessionProvider);
    if (auth.isLoading) return const AsyncLoading();
    if (auth.hasError) return AsyncError(auth.error!, auth.stackTrace!);
    final page = ref.watch(
      eventRehearsalMovementForAccountProvider(
        selection,
        account: auth.requireValue,
      ),
    );
    if (page.isLoading) return const AsyncLoading();
    if (page.hasError) return AsyncError(page.error!, page.stackTrace!);
    return page;
  }

  void reload() {
    final auth = ref.read(authenticatedSessionProvider);
    if (auth.isLoading || auth.hasError || auth.asData == null) return;
    ref.invalidate(
      eventRehearsalMovementForAccountProvider(
        selection,
        account: auth.requireValue,
      ),
    );
  }
}

/// These deliberate reads must describe one runtime revision. Polling can never
/// replace one half of a pending Host review or silently cross a reset.
@Riverpod(retry: _noMovementRetry)
Future<RehearsalMovementPage> eventRehearsalMovementForAccount(
  Ref ref,
  RehearsalMovementSelection selection, {
  required AuthenticatedSession account,
}) async {
  ref.watch(authenticatedSessionProvider);
  requireRehearsalReviewAccount(ref, account);
  final repository = ref.watch(eventRehearsalRepositoryProvider);
  final session = await repository.fetch(selection.scope.sessionId);
  requireRehearsalReviewAccount(ref, account);
  if (rehearsalMovementScope(session.session, selection.scope.groupId) !=
      selection.scope) {
    throw rehearsalReviewExpired;
  }
  final snapshot = await repository.fetchMovement(
    snapshot: session,
    selection: selection,
    actorUid: account.uid,
  );
  requireRehearsalReviewAccount(ref, account);
  if (snapshot.selection != selection ||
      snapshot.actorUid != account.uid ||
      !identical(snapshot.session, session.session)) {
    throw rehearsalReviewExpired;
  }
  final page = RehearsalMovementPage._(account, session, snapshot);
  ref.onDispose(() => page._current = false);
  return page;
}

Duration? _noMovementRetry(int retryCount, Object error) => null;

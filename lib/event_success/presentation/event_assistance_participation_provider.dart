import 'package:catch_dating_app/auth/data/authenticated_session.dart';
import 'package:catch_dating_app/event_success/data/event_assistance_participation_repository.dart';
import 'package:catch_dating_app/event_success/domain/event_assistance_participation.dart';
import 'package:catch_dating_app/exceptions/app_exception.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'event_assistance_participation_provider.g.dart';

final class EventParticipationSession {
  EventParticipationSession._(this.account, this.view);
  final AuthenticatedSession account;
  final EventAssistanceParticipationView view;
  bool _current = true;
  bool get isCurrent => _current;
}

const participationSessionChanged = BackendOperationException(
  code: 'session-changed',
  message:
      'Your sign-in changed. Reload guest participation before continuing.',
  context: BackendErrorContext(
    service: BackendService.functions,
    action: 'review guest participation',
    resource: 'eventAssistanceGuests',
  ),
);

void requireParticipationAccount(Ref ref, AuthenticatedSession expected) {
  if (!ref.mounted) throw participationSessionChanged;
  final auth = ref.read(authenticatedSessionProvider);
  if (auth.isLoading ||
      auth.hasError ||
      !identical(auth.asData?.value, expected)) {
    throw participationSessionChanged;
  }
}

/// The route consumes this outer provider; old-account data is never rendered.
@riverpod
class EventAssistanceParticipationReview
    extends _$EventAssistanceParticipationReview {
  @override
  AsyncValue<EventParticipationSession> build(EventAssistanceGuestScope scope) {
    final auth = ref.watch(authenticatedSessionProvider);
    if (auth.isLoading) return const AsyncLoading();
    if (auth.hasError) return AsyncError(auth.error!, auth.stackTrace!);
    final page = ref.watch(
      eventAssistanceParticipationForAccountProvider(
        scope,
        account: switch (auth) {
          AsyncData(:final value) => value,
          AsyncError(:final error) => throw error,
          AsyncLoading() => throw AssertionError(),
        },
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
      eventAssistanceParticipationForAccountProvider(
        scope,
        account: switch (auth) {
          AsyncData(:final value) => value,
          AsyncError(:final error) => throw error,
          AsyncLoading() => throw AssertionError(),
        },
      ),
    );
  }
}

@Riverpod(retry: _noParticipationReadRetry)
Future<EventParticipationSession> eventAssistanceParticipationForAccount(
  Ref ref,
  EventAssistanceGuestScope scope, {
  required AuthenticatedSession account,
}) async {
  ref.watch(authenticatedSessionProvider);
  requireParticipationAccount(ref, account);
  final view = await ref
      .watch(eventAssistanceParticipationRepositoryProvider)
      .fetch(scope);
  requireParticipationAccount(ref, account);
  if (view.scope != scope) {
    throw const FormatException('Foreign participation review.');
  }
  final session = EventParticipationSession._(account, view);
  ref.onDispose(() => session._current = false);
  return session;
}

Duration? _noParticipationReadRetry(int count, Object error) => null;

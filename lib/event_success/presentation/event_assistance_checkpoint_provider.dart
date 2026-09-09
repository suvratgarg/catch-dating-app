import 'package:catch_dating_app/auth/data/authenticated_session.dart';
import 'package:catch_dating_app/event_success/data/event_assistance_checkpoint_repository.dart';
import 'package:catch_dating_app/event_success/domain/event_assistance_checkpoint.dart';
import 'package:catch_dating_app/exceptions/app_exception.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'event_assistance_checkpoint_provider.g.dart';

final class EventAssistanceCheckpointSession {
  EventAssistanceCheckpointSession._(this.account, this.view);
  final AuthenticatedSession account;
  final EventAssistanceCheckpointView view;
  bool _current = true;
  bool get isCurrent => _current;
}

const checkpointSessionChanged = BackendOperationException(
  code: 'session-changed',
  message:
      'Your sign-in changed. Reload checkpoint arrivals before continuing.',
  context: BackendErrorContext(
    service: BackendService.functions,
    action: 'review checkpoint arrivals',
    resource: 'eventAssistanceCheckpoints',
  ),
);

void requireCheckpointAccount(Ref ref, AuthenticatedSession expected) {
  if (!ref.mounted) throw checkpointSessionChanged;
  final auth = ref.read(authenticatedSessionProvider);
  if (auth.isLoading ||
      auth.hasError ||
      !identical(auth.asData?.value, expected)) {
    throw checkpointSessionChanged;
  }
}

/// The route consumes this outer provider; old-account data is never rendered.
@riverpod
class EventAssistanceCheckpoint extends _$EventAssistanceCheckpoint {
  @override
  AsyncValue<EventAssistanceCheckpointSession> build(
    EventAssistanceCheckpointScope scope,
  ) {
    final auth = ref.watch(authenticatedSessionProvider);
    if (auth.isLoading) return const AsyncLoading();
    if (auth.hasError) return AsyncError(auth.error!, auth.stackTrace!);
    final page = ref.watch(
      eventAssistanceCheckpointForAccountProvider(
        scope,
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
      eventAssistanceCheckpointForAccountProvider(
        scope,
        account: auth.requireValue,
      ),
    );
  }
}

@Riverpod(retry: _noCheckpointReadRetry)
Future<EventAssistanceCheckpointSession> eventAssistanceCheckpointForAccount(
  Ref ref,
  EventAssistanceCheckpointScope scope, {
  required AuthenticatedSession account,
}) async {
  ref.watch(authenticatedSessionProvider);
  requireCheckpointAccount(ref, account);
  final view = await ref
      .watch(eventAssistanceCheckpointRepositoryProvider)
      .fetch(scope);
  requireCheckpointAccount(ref, account);
  if (view.scope != scope) {
    throw const FormatException('Foreign checkpoint review.');
  }
  final session = EventAssistanceCheckpointSession._(account, view);
  ref.onDispose(() => session._current = false);
  return session;
}

Duration? _noCheckpointReadRetry(int count, Object error) => null;

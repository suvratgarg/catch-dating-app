import 'package:catch_dating_app/auth/data/authenticated_session.dart';
import 'package:catch_dating_app/event_success/data/event_assistance_accountability_repository.dart';
import 'package:catch_dating_app/event_success/domain/event_assistance_accountability.dart';
import 'package:catch_dating_app/exceptions/app_exception.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'event_assistance_accountability_provider.g.dart';

final class EventAssistanceAccountabilitySession {
  EventAssistanceAccountabilitySession._(this.account, this.view);
  final AuthenticatedSession account;
  final EventAssistanceAccountabilityView view;
  bool _current = true;
  bool get isCurrent => _current;
}

const accountabilitySessionChanged = BackendOperationException(
  code: 'session-changed',
  message:
      'Your sign-in changed. Reload visit accountability before continuing.',
  context: BackendErrorContext(
    service: BackendService.functions,
    action: 'review visit accountability',
    resource: 'eventAttendees',
  ),
);

void requireAccountabilityAccount(Ref ref, AuthenticatedSession expected) {
  if (!ref.mounted) throw accountabilitySessionChanged;
  final auth = ref.read(authenticatedSessionProvider);
  if (auth.isLoading ||
      auth.hasError ||
      !identical(auth.asData?.value, expected)) {
    throw accountabilitySessionChanged;
  }
}

/// The route consumes this outer provider; old-account data is never rendered.
@riverpod
class EventAssistanceAccountability extends _$EventAssistanceAccountability {
  @override
  AsyncValue<EventAssistanceAccountabilitySession> build(
    EventAssistanceAccountabilityScope scope,
  ) {
    final auth = ref.watch(authenticatedSessionProvider);
    if (auth.isLoading) return const AsyncLoading();
    if (auth.hasError) return AsyncError(auth.error!, auth.stackTrace!);
    final page = ref.watch(
      eventAssistanceAccountabilityForAccountProvider(
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
      eventAssistanceAccountabilityForAccountProvider(
        scope,
        account: auth.requireValue,
      ),
    );
  }
}

@Riverpod(retry: _noAccountabilityReadRetry)
Future<EventAssistanceAccountabilitySession>
eventAssistanceAccountabilityForAccount(
  Ref ref,
  EventAssistanceAccountabilityScope scope, {
  required AuthenticatedSession account,
}) async {
  ref.watch(authenticatedSessionProvider);
  requireAccountabilityAccount(ref, account);
  final view = await ref
      .watch(eventAssistanceAccountabilityRepositoryProvider)
      .fetch(scope);
  requireAccountabilityAccount(ref, account);
  if (view.scope != scope) {
    throw const FormatException('Foreign accountability review.');
  }
  final session = EventAssistanceAccountabilitySession._(account, view);
  ref.onDispose(() => session._current = false);
  return session;
}

Duration? _noAccountabilityReadRetry(int count, Object error) => null;

import 'package:catch_dating_app/auth/data/authenticated_session.dart';
import 'package:catch_dating_app/event_success/data/event_assistance_membership_repository.dart';
import 'package:catch_dating_app/event_success/domain/event_assistance_membership.dart';
import 'package:catch_dating_app/event_success/domain/event_assistance_participation.dart';
import 'package:catch_dating_app/exceptions/app_exception.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'event_assistance_membership_provider.g.dart';

final class EventAssistanceMembershipSession {
  EventAssistanceMembershipSession._(this.account, this.view);
  final AuthenticatedSession account;
  final EventAssistanceMembershipView view;
  bool _current = true;
  bool get isCurrent => _current;
}

const membershipSessionChanged = BackendOperationException(
  code: 'session-changed',
  message: 'Your sign-in changed. Reload group membership before continuing.',
  context: BackendErrorContext(
    service: BackendService.functions,
    action: 'review group membership',
    resource: 'eventAssistanceMemberships',
  ),
);

void requireMembershipAccount(Ref ref, AuthenticatedSession expected) {
  if (!ref.mounted) throw membershipSessionChanged;
  final auth = ref.read(authenticatedSessionProvider);
  if (auth.isLoading ||
      auth.hasError ||
      !identical(auth.asData?.value, expected)) {
    throw membershipSessionChanged;
  }
}

/// The route consumes this outer provider; old-account data is never rendered.
@riverpod
class EventAssistanceMembership extends _$EventAssistanceMembership {
  @override
  AsyncValue<EventAssistanceMembershipSession> build(
    EventAssistanceGuestScope scope,
  ) {
    final auth = ref.watch(authenticatedSessionProvider);
    if (auth.isLoading) return const AsyncLoading();
    if (auth.hasError) return AsyncError(auth.error!, auth.stackTrace!);
    final page = ref.watch(
      eventAssistanceMembershipForAccountProvider(
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
      eventAssistanceMembershipForAccountProvider(
        scope,
        account: auth.requireValue,
      ),
    );
  }
}

@Riverpod(retry: _noMembershipReadRetry)
Future<EventAssistanceMembershipSession> eventAssistanceMembershipForAccount(
  Ref ref,
  EventAssistanceGuestScope scope, {
  required AuthenticatedSession account,
}) async {
  ref.watch(authenticatedSessionProvider);
  requireMembershipAccount(ref, account);
  final view = await ref
      .watch(eventAssistanceMembershipRepositoryProvider)
      .fetch(scope);
  requireMembershipAccount(ref, account);
  if (view.scope != scope) {
    throw const FormatException('Foreign membership review.');
  }
  final session = EventAssistanceMembershipSession._(account, view);
  ref.onDispose(() => session._current = false);
  return session;
}

Duration? _noMembershipReadRetry(int count, Object error) => null;

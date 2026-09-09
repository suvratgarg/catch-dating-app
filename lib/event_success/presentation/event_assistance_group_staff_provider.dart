import 'package:catch_dating_app/auth/data/authenticated_session.dart';
import 'package:catch_dating_app/event_success/data/event_assistance_group_staff_repository.dart';
import 'package:catch_dating_app/event_success/domain/event_assistance_group_staff.dart';
import 'package:catch_dating_app/exceptions/app_exception.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'event_assistance_group_staff_provider.g.dart';

final class EventAssistanceGroupStaffSession {
  EventAssistanceGroupStaffSession._(this.account, this.view);
  final AuthenticatedSession account;
  final EventAssistanceGroupStaffView view;
  bool _current = true;
  bool get isCurrent => _current;
}

const groupStaffSessionChanged = BackendOperationException(
  code: 'session-changed',
  message: 'Your sign-in changed. Reload group staff before continuing.',
  context: BackendErrorContext(
    service: BackendService.functions,
    action: 'review group staff',
    resource: 'eventStaffGrants',
  ),
);

void requireGroupStaffAccount(Ref ref, AuthenticatedSession expected) {
  if (!ref.mounted) throw groupStaffSessionChanged;
  final auth = ref.read(authenticatedSessionProvider);
  if (auth.isLoading ||
      auth.hasError ||
      !identical(auth.asData?.value, expected)) {
    throw groupStaffSessionChanged;
  }
}

/// The route consumes this outer provider; old-account data is never rendered.
@riverpod
class EventAssistanceGroupStaff extends _$EventAssistanceGroupStaff {
  @override
  AsyncValue<EventAssistanceGroupStaffSession> build(
    EventAssistanceGroupStaffLookup lookup,
  ) {
    final auth = ref.watch(authenticatedSessionProvider);
    if (auth.isLoading) return const AsyncLoading();
    if (auth.hasError) return AsyncError(auth.error!, auth.stackTrace!);
    final page = ref.watch(
      eventAssistanceGroupStaffForAccountProvider(
        lookup,
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
      eventAssistanceGroupStaffForAccountProvider(
        lookup,
        account: auth.requireValue,
      ),
    );
  }
}

@Riverpod(retry: _noGroupStaffReadRetry)
Future<EventAssistanceGroupStaffSession> eventAssistanceGroupStaffForAccount(
  Ref ref,
  EventAssistanceGroupStaffLookup lookup, {
  required AuthenticatedSession account,
}) async {
  ref.watch(authenticatedSessionProvider);
  requireGroupStaffAccount(ref, account);
  final view = await ref
      .watch(eventAssistanceGroupStaffRepositoryProvider)
      .fetch(lookup);
  requireGroupStaffAccount(ref, account);
  if (view.lookup != lookup) {
    throw const FormatException('Foreign group staff lookup.');
  }
  final session = EventAssistanceGroupStaffSession._(account, view);
  ref.onDispose(() => session._current = false);
  return session;
}

Duration? _noGroupStaffReadRetry(int count, Object error) => null;

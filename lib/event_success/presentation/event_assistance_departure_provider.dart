import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/event_success/data/event_assistance_departure_repository.dart';
import 'package:catch_dating_app/event_success/domain/event_assistance_group_progress.dart';
import 'package:catch_dating_app/exceptions/app_exception.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'event_assistance_departure_provider.g.dart';

/// Identity of one continuous authenticated review period, not just a UID.
/// Signing out and back in as the same person cannot revive an old decision.
final class EventDepartureAccount {
  EventDepartureAccount._(this.uid);
  final String uid;
}

final class EventDepartureSession {
  EventDepartureSession._({required this.account, required this.view}) {
    if (account.uid != view.actorUid) throw departureSessionChanged;
  }
  final EventDepartureAccount account;
  final EventAssistanceGroupProgressView view;
}

const departureSessionChanged = BackendOperationException(
  code: 'session-changed',
  message: 'Your sign-in changed. Reload departure details before continuing.',
  context: BackendErrorContext(
    service: BackendService.functions,
    action: 'review group departure',
    resource: 'eventAssistanceGroupProgress',
  ),
);

@riverpod
AsyncValue<EventDepartureAccount> eventAssistanceDepartureAccount(Ref ref) {
  final auth = ref.watch(uidProvider);
  if (auth.isLoading) return const AsyncLoading();
  if (auth.hasError) return AsyncError(auth.error!, auth.stackTrace!);
  final uid = auth.asData?.value;
  if (uid == null || uid.isEmpty) {
    return AsyncError(
      const SignInRequiredException('review group departure'),
      StackTrace.current,
    );
  }
  return AsyncData(EventDepartureAccount._(uid));
}

void requireDepartureAccount(Ref ref, EventDepartureAccount expected) {
  if (!ref.mounted) throw departureSessionChanged;
  final current = ref.read(eventAssistanceDepartureAccountProvider);
  if (current.isLoading ||
      current.hasError ||
      !identical(current.asData?.value, expected)) {
    throw departureSessionChanged;
  }
}

@riverpod
class EventAssistanceDeparture extends _$EventAssistanceDeparture {
  @override
  AsyncValue<EventDepartureSession> build(EventAssistanceGroupScope scope) {
    final auth = ref.watch(eventAssistanceDepartureAccountProvider);
    return auth.when(
      skipLoadingOnRefresh: false,
      skipLoadingOnReload: false,
      skipError: false,
      loading: () => const AsyncLoading(),
      error: (error, stackTrace) => AsyncError(error, stackTrace),
      data: (account) => ref.watch(
        eventAssistanceDepartureForAccountProvider(scope, account: account),
      ),
    );
  }

  void reload() {
    final account = ref
        .read(eventAssistanceDepartureAccountProvider)
        .asData
        ?.value;
    if (account == null) return;
    ref.invalidate(
      eventAssistanceDepartureForAccountProvider(scope, account: account),
    );
  }
}

@Riverpod(retry: _noDepartureReadRetry)
Future<EventDepartureSession> eventAssistanceDepartureForAccount(
  Ref ref,
  EventAssistanceGroupScope scope, {
  required EventDepartureAccount account,
}) async {
  // Keep the account identity alive while this read is observed. Watch also
  // cancels this cache entry when authentication changes.
  ref.watch(eventAssistanceDepartureAccountProvider);
  requireDepartureAccount(ref, account);
  final view = await ref
      .watch(eventAssistanceDepartureRepositoryProvider)
      .fetch(scope, actorUid: account.uid);
  requireDepartureAccount(ref, account);
  return EventDepartureSession._(account: account, view: view);
}

// A fresh progress snapshot is an explicit host review, not a background
// replacement for the decision currently being edited.
Duration? _noDepartureReadRetry(int retryCount, Object error) => null;

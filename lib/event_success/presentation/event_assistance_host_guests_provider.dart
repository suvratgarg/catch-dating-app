import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/event_success/data/event_assistance_host_guests_repository.dart';
import 'package:catch_dating_app/event_success/domain/event_assistance_host_guests.dart';
import 'package:catch_dating_app/exceptions/app_exception.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'event_assistance_host_guests_provider.g.dart';

final class EventAssistanceHostGuestsSession {
  const EventAssistanceHostGuestsSession({
    required this.accountId,
    required this.view,
  });
  final String accountId;
  final EventAssistanceHostGuestsView view;
}

@riverpod
class EventAssistanceHostGuests extends _$EventAssistanceHostGuests {
  @override
  AsyncValue<EventAssistanceHostGuestsSession> build(
    EventAssistanceGuestSelection selection,
  ) {
    final auth = ref.watch(uidProvider);
    if (auth.isLoading) return const AsyncLoading();
    if (auth.hasError) return AsyncError(auth.error!, auth.stackTrace!);
    final accountId = auth.asData?.value;
    if (accountId == null || accountId.isEmpty) {
      return AsyncError(
        const SignInRequiredException('load guest assistance'),
        StackTrace.current,
      );
    }
    // A different account has a different cache entry. This synchronous
    // boundary cannot retain the previous account's AsyncData during loading.
    return ref.watch(
      eventAssistanceHostGuestsForAccountProvider(
        selection,
        accountId: accountId,
      ),
    );
  }

  void reload() {
    final auth = ref.read(uidProvider);
    final accountId = auth.asData?.value;
    if (auth.isLoading ||
        auth.hasError ||
        accountId == null ||
        accountId.isEmpty) {
      return;
    }
    ref.invalidate(
      eventAssistanceHostGuestsForAccountProvider(
        selection,
        accountId: accountId,
      ),
    );
  }
}

@riverpod
Future<EventAssistanceHostGuestsSession> eventAssistanceHostGuestsForAccount(
  Ref ref,
  EventAssistanceGuestSelection selection, {
  required String accountId,
}) async {
  final authenticatedId = await ref.watch(uidProvider.future);
  if (authenticatedId != accountId || accountId.isEmpty) throw _sessionChanged;
  final view = await ref
      .watch(eventAssistanceHostGuestsRepositoryProvider)
      .fetch(selection);
  if (!ref.mounted) throw _sessionChanged;
  final account = ref.read(uidProvider);
  if (account.isLoading ||
      account.hasError ||
      account.asData?.value != accountId) {
    throw _sessionChanged;
  }
  return EventAssistanceHostGuestsSession(accountId: accountId, view: view);
}

const _sessionChanged = BackendOperationException(
  code: 'session-changed',
  message: 'Your sign-in changed. Reload guest assistance before continuing.',
  context: BackendErrorContext(
    service: BackendService.functions,
    action: 'load guest assistance',
    resource: 'eventAssistanceGuests',
  ),
);

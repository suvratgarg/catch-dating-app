import 'package:catch_dating_app/auth/data/authenticated_session.dart';
import 'package:catch_dating_app/event_success/data/event_assistance_departure_history_repository.dart';
import 'package:catch_dating_app/event_success/domain/event_assistance_departure_history.dart';
import 'package:catch_dating_app/event_success/presentation/event_assistance_checkpoint_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'event_assistance_departure_history_provider.g.dart';

final class EventAssistanceDepartureHistorySession {
  const EventAssistanceDepartureHistorySession._(this.account, this.page);
  final AuthenticatedSession account;
  final EventAssistanceDepartureHistoryPage page;
}

/// Account-scoped pages never render a previous sign-in's history on refresh.
@riverpod
class EventAssistanceDepartureHistory
    extends _$EventAssistanceDepartureHistory {
  @override
  AsyncValue<EventAssistanceDepartureHistorySession> build(
    EventAssistanceDepartureHistoryQuery query,
  ) {
    final auth = ref.watch(authenticatedSessionProvider);
    if (auth.isLoading) return const AsyncLoading();
    if (auth.hasError) return AsyncError(auth.error!, auth.stackTrace!);
    final result = ref.watch(
      eventAssistanceDepartureHistoryForAccountProvider(
        query,
        account: auth.requireValue,
      ),
    );
    if (result.isLoading) return const AsyncLoading();
    if (result.hasError) return AsyncError(result.error!, result.stackTrace!);
    return result;
  }

  void reload() {
    final auth = ref.read(authenticatedSessionProvider);
    if (auth.isLoading || auth.hasError || auth.asData == null) return;
    ref.invalidate(
      eventAssistanceDepartureHistoryForAccountProvider(
        query,
        account: auth.requireValue,
      ),
    );
  }
}

@Riverpod(retry: _noHistoryReadRetry)
Future<EventAssistanceDepartureHistorySession>
eventAssistanceDepartureHistoryForAccount(
  Ref ref,
  EventAssistanceDepartureHistoryQuery query, {
  required AuthenticatedSession account,
}) async {
  ref.watch(authenticatedSessionProvider);
  requireCheckpointAccount(ref, account);
  final page = await ref
      .watch(eventAssistanceDepartureHistoryRepositoryProvider)
      .fetch(query, actorUid: account.uid);
  requireCheckpointAccount(ref, account);
  if (page.query != query || page.actorUid != account.uid) {
    throw const FormatException('Foreign departure history page.');
  }
  return EventAssistanceDepartureHistorySession._(account, page);
}

Duration? _noHistoryReadRetry(int count, Object error) => null;

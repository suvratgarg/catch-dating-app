import 'package:catch_dating_app/auth/data/authenticated_session.dart';
import 'package:catch_dating_app/event_rehearsal/data/event_rehearsal_repository.dart';
import 'package:catch_dating_app/event_rehearsal/domain/event_rehearsal.dart';
import 'package:catch_dating_app/exceptions/app_exception.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'event_rehearsal_assistance_provider.g.dart';

final class RehearsalAssistanceReview {
  RehearsalAssistanceReview._(this.account, this.snapshot);
  final AuthenticatedSession account;
  final EventRehearsalBootstrap snapshot;
  bool _current = true;
  bool get isCurrent => _current;
}

const rehearsalReviewSessionChanged = BackendOperationException(
  code: 'session-changed',
  message: 'Your sign-in changed. Reload this rehearsal before continuing.',
  context: BackendErrorContext(
    service: BackendService.functions,
    action: 'review rehearsal assistance',
    resource: 'eventRehearsals',
  ),
);
const rehearsalReviewExpired = BackendOperationException(
  code: 'review-changed',
  message:
      'Reload this rehearsal and review the current run before continuing.',
  context: BackendErrorContext(
    service: BackendService.functions,
    action: 'review rehearsal assistance',
    resource: 'eventRehearsals',
  ),
);

void requireRehearsalReviewAccount(Ref ref, AuthenticatedSession expected) {
  if (!ref.mounted) throw rehearsalReviewSessionChanged;
  final account = ref.read(authenticatedSessionProvider);
  if (account.isLoading ||
      account.hasError ||
      !identical(account.asData?.value, expected)) {
    throw rehearsalReviewSessionChanged;
  }
}

/// A deliberate review fetch, separate from the constantly polling runtime.
@riverpod
class EventRehearsalAssistance extends _$EventRehearsalAssistance {
  @override
  AsyncValue<RehearsalAssistanceReview> build(String sessionId) {
    final auth = ref.watch(authenticatedSessionProvider);
    if (auth.isLoading) return const AsyncLoading();
    if (auth.hasError) return AsyncError(auth.error!, auth.stackTrace!);
    final page = ref.watch(
      eventRehearsalAssistanceForAccountProvider(
        sessionId,
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
      eventRehearsalAssistanceForAccountProvider(
        sessionId,
        account: auth.requireValue,
      ),
    );
  }
}

@Riverpod(retry: _noReviewRetry)
Future<RehearsalAssistanceReview> eventRehearsalAssistanceForAccount(
  Ref ref,
  String sessionId, {
  required AuthenticatedSession account,
}) async {
  ref.watch(authenticatedSessionProvider);
  requireRehearsalReviewAccount(ref, account);
  final snapshot = await ref
      .watch(eventRehearsalRepositoryProvider)
      .fetch(sessionId);
  requireRehearsalReviewAccount(ref, account);
  if (snapshot.session.id != sessionId) {
    throw const FormatException(
      'Rehearsal review returned a different session.',
    );
  }
  final review = RehearsalAssistanceReview._(account, snapshot);
  ref.onDispose(() => review._current = false);
  return review;
}

Duration? _noReviewRetry(int retryCount, Object error) => null;

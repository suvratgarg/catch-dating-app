import 'package:catch_dating_app/event_success/data/event_assistance_cases_repository.dart';
import 'package:catch_dating_app/event_success/domain/event_assistance_case.dart';
import 'package:catch_dating_app/event_success/domain/event_assistance_case_scope.dart';
import 'package:catch_dating_app/event_success/domain/event_assistance_cases_page.dart';
import 'package:catch_dating_app/event_success/presentation/event_assistance_account.dart';
import 'package:catch_dating_app/exceptions/app_exception.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'event_assistance_cases_provider.g.dart';

final class EventAssistanceCasesSession {
  const EventAssistanceCasesSession._(this.account, this.page);
  final EventAssistanceAccount account;
  final EventAssistanceCasesPage page;

  EventAssistanceCaseReview review(AssistanceOpenHostCase request) {
    if (!page.cases.any((row) => identical(row, request))) {
      throw ArgumentError('Review a request from this page snapshot.');
    }
    return EventAssistanceCaseReview._(account, request);
  }
}

final class EventAssistanceCaseReview {
  const EventAssistanceCaseReview._(this.account, this.request);
  final EventAssistanceAccount account;
  final AssistanceOpenHostCase request;
}

const caseReviewSessionChanged = BackendOperationException(
  code: 'session-changed',
  message: 'Your sign-in changed. Reload help requests before continuing.',
  context: BackendErrorContext(
    service: BackendService.functions,
    action: 'review guest help request',
    resource: 'eventAssistanceCases',
  ),
);

void requireCaseReviewAccount(Ref ref, EventAssistanceAccount expected) {
  if (!ref.mounted) throw caseReviewSessionChanged;
  final current = ref.read(eventAssistanceAccountProvider);
  if (current.isLoading ||
      current.hasError ||
      !identical(current.asData?.value, expected)) {
    throw caseReviewSessionChanged;
  }
}

@riverpod
class EventAssistanceCases extends _$EventAssistanceCases {
  @override
  AsyncValue<EventAssistanceCasesSession> build(
    EventAssistanceCaseQuery query,
  ) {
    final auth = ref.watch(eventAssistanceAccountProvider);
    return auth.when(
      skipLoadingOnRefresh: false,
      skipLoadingOnReload: false,
      skipError: false,
      loading: () => const AsyncLoading(),
      error: (error, stackTrace) => AsyncError(error, stackTrace),
      data: (account) {
        final page = ref.watch(
          eventAssistanceCasesForAccountProvider(query, account: account),
        );
        if (page.isLoading) return const AsyncLoading();
        if (page.hasError) return AsyncError(page.error!, page.stackTrace!);
        return page;
      },
    );
  }

  void reload() {
    final account = ref.read(eventAssistanceAccountProvider);
    if (account.isLoading || account.hasError || account.asData == null) return;
    ref.invalidate(
      eventAssistanceCasesForAccountProvider(
        query,
        account: account.requireValue,
      ),
    );
  }
}

@Riverpod(retry: _noCaseReadRetry)
Future<EventAssistanceCasesSession> eventAssistanceCasesForAccount(
  Ref ref,
  EventAssistanceCaseQuery query, {
  required EventAssistanceAccount account,
}) async {
  ref.watch(eventAssistanceAccountProvider);
  requireCaseReviewAccount(ref, account);
  final page = await ref
      .watch(eventAssistanceCasesRepositoryProvider)
      .fetch(query);
  requireCaseReviewAccount(ref, account);
  return EventAssistanceCasesSession._(account, page);
}

Duration? _noCaseReadRetry(int retryCount, Object error) => null;

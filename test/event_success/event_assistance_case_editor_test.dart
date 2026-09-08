import 'dart:async';

import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/event_success/data/event_assistance_cases_repository.dart';
import 'package:catch_dating_app/event_success/domain/event_assistance_case.dart';
import 'package:catch_dating_app/event_success/domain/event_assistance_case_change.dart';
import 'package:catch_dating_app/event_success/presentation/event_assistance_case_editor.dart';
import 'package:catch_dating_app/event_success/presentation/event_assistance_cases_provider.dart';
import 'package:catch_dating_app/exceptions/app_exception.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'event_assistance_cases_fixtures.dart';
import 'event_assistance_cases_test_repository.dart';

void main() {
  late CasesTestRepository repository;
  late StreamController<String?> auth;
  late ProviderContainer container;
  late EventAssistanceCaseReview review;
  late EventAssistanceCaseEditor editor;
  late ProviderSubscription<AssistanceCaseEditorState> subscription;
  final queue = eventAssistanceCasesProvider(caseQuery());

  Future<void> signIn(String? uid) async {
    final count = repository.reads.length + 1;
    auth.add(uid);
    await container.pump();
    if (uid != null) await repository.waitForReads(count);
    await container.pump();
  }

  setUp(() async {
    repository = CasesTestRepository();
    auth = StreamController<String?>.broadcast();
    container = ProviderContainer(
      overrides: [
        uidProvider.overrideWith((ref) => auth.stream),
        eventAssistanceCasesRepositoryProvider.overrideWith(
          (ref) => repository,
        ),
      ],
    );
    container.listen(queue, (_, _) {});
    await signIn('host-1');
    repository.reads.single.result.complete(casesPage());
    await container.pump();
    final session = container.read(queue).requireValue;
    review = session.review(
      session.page.cases.single as AssistanceOpenHostCase,
    );
    final provider = eventAssistanceCaseEditorProvider(review);
    subscription = container.listen(provider, (_, _) {});
    editor = container.read(provider.notifier);
  });
  tearDown(() async {
    container.dispose();
    await auth.close();
  });
  AssistanceCaseEditorState state() =>
      container.read(eventAssistanceCaseEditorProvider(review));
  AssistanceCaseForm form() => state() as AssistanceCaseForm;

  test(
    'starts without a decision and only exposes a legal submission',
    () async {
      expect(form().decision, isNull);
      expect(form().canSubmit, isFalse);
      expect(form().canDismiss, isTrue);
      expect(form().canReload, isTrue);
      await expectLater(editor.submit(), throwsA(isA<ValidationException>()));
      expect(repository.writes, isEmpty);
      editor.select(AssistanceCaseDecision.transfer('host-2'));
      expect(form().decision, isA<AssistanceCaseTransfer>());
      editor.select(const AssistanceCaseDecision.decline());
      expect(form().decision, isA<AssistanceCaseDecline>());
      expect(form().canSubmit, isTrue);
    },
  );

  test(
    'duplicate submits share one frozen command and lock the form',
    () async {
      editor.select(const AssistanceCaseDecision.resolve());
      final first = editor.submit();
      final second = editor.submit();
      expect(identical(first, second), isTrue);
      expect(repository.writes, hasLength(1));
      expect(form().phase, AssistanceCaseEditorPhase.submitting);
      expect(form().canDismiss, isFalse);
      expect(form().canReload, isFalse);
      expect(form().canEdit, isFalse);
      expect(form().canSubmit, isFalse);
      editor.select(const AssistanceCaseDecision.decline());
      expect(form().decision, isA<AssistanceCaseResolve>());
      final write = repository.writes.single;
      expect(write.change.snapshot, same(review.request));
      expect(write.change.actorUid, 'host-1');
      expect(write.change.operationId, startsWith('case:'));
      expect(
        container.read(queue).requireValue.page.cases.single,
        isA<AssistanceOpenHostCase>(),
        reason: 'no optimistic resolution',
      );
      write.result.complete(caseResult(write.change));
      final result = await first;
      await second;
      await container.pump();
      await repository.waitForReads(2);
      expect(form().phase, AssistanceCaseEditorPhase.saved);
      expect(form().result, same(result));
      expect(form().canSubmit, isFalse);
      expect(
        container.read(queue).hasValue,
        isFalse,
        reason: 'a refreshed queue cannot render an old open request',
      );
      expect(await editor.submit(), same(result));
      expect(repository.writes, hasLength(1));
    },
  );

  test(
    'uncertain failures allow only an identical retry or fresh review',
    () async {
      editor.select(AssistanceCaseDecision.transfer('host-2'));
      final first = editor.submit();
      final expectedFailure = expectLater(
        first,
        throwsA(isA<NetworkException>()),
      );
      repository.writes.single.result.completeError(
        const NetworkException('unavailable', 'Offline'),
      );
      await expectedFailure;
      final original = repository.writes.single.change;
      expect(form().phase, AssistanceCaseEditorPhase.retryRequired);
      expect(form().canSubmit, isTrue);
      expect(form().canEdit, isFalse);
      expect(form().canDismiss, isTrue);
      expect(form().canReload, isTrue);
      editor.select(const AssistanceCaseDecision.resolve());
      expect(form().decision, isA<AssistanceCaseTransfer>());
      final retry = editor.submit();
      final repeated = repository.writes.last;
      expect(repeated.change, same(original));
      expect(repeated.change.command, original.command);
      repeated.result.complete(caseResult(original, outcome: 'replayed'));
      final result = await retry;
      expect(result.outcome, AssistanceCaseChangeOutcome.replayed);
      expect(form().phase, AssistanceCaseEditorPhase.saved);
    },
  );

  test(
    'conflicts and revoked authority require reload instead of changed retries',
    () async {
      editor.select(const AssistanceCaseDecision.decline());
      final pending = editor.submit();
      final failure = expectLater(
        pending,
        throwsA(isA<BackendOperationException>()),
      );
      repository.writes.single.result.completeError(
        const BackendOperationException(
          code: 'aborted',
          message: 'Changed',
          context: BackendErrorContext(
            service: BackendService.functions,
            action: 'update guest help request',
          ),
        ),
      );
      await failure;
      expect(form().phase, AssistanceCaseEditorPhase.refreshRequired);
      expect(form().canSubmit, isFalse);
      expect(form().canReload, isTrue);
      await expectLater(editor.submit(), throwsA(isA<ValidationException>()));
      expect(repository.writes, hasLength(1));
    },
  );

  test(
    'a replay preserves later resolution instead of showing the old handoff',
    () async {
      editor.select(AssistanceCaseDecision.transfer('host-2'));
      final pending = editor.submit();
      final write = repository.writes.single;
      write.result.complete(
        caseResult(
          write.change,
          outcome: 'replayed',
          rowPatch: {
            'status': 'resolved',
            'revision': 3,
            'canChange': false,
            'resolution': {
              'outcome': 'declined',
              'actorUid': 'host-3',
              'at': 3000,
            },
          },
        ),
      );
      final result = await pending;
      expect(result.operationRevision, 1);
      expect((form().result!.view as AssistanceClosedHostCase).revision, 3);
      expect(
        (result.view as AssistanceClosedHostCase).resolution.outcome,
        AssistanceCaseResolutionOutcome.declined,
      );
    },
  );

  test(
    'sign-out removes the entire form and returning to the UID cannot revive it',
    () async {
      editor.select(const AssistanceCaseDecision.resolve());
      await signIn(null);
      expect(state(), isA<AssistanceCaseFormUnavailable>());
      expect(state().canDismiss, isTrue);
      await signIn('host-1');
      expect(state(), isA<AssistanceCaseFormUnavailable>());
      await expectLater(
        editor.submit(),
        throwsA(
          isA<BackendOperationException>().having(
            (e) => e.code,
            'code',
            'session-changed',
          ),
        ),
      );
      expect(repository.writes, isEmpty);
    },
  );

  test(
    'account switch during a submission cannot publish its old result',
    () async {
      editor.select(const AssistanceCaseDecision.resolve());
      final pending = editor.submit();
      final write = repository.writes.single;
      final failure = expectLater(
        pending,
        throwsA(
          isA<BackendOperationException>().having(
            (e) => e.code,
            'code',
            'session-changed',
          ),
        ),
      );
      await signIn('host-2');
      expect(state(), isA<AssistanceCaseFormUnavailable>());
      write.result.complete(caseResult(write.change));
      await failure;
      expect(state(), isA<AssistanceCaseFormUnavailable>());
      expect(container.read(queue).hasValue, isFalse);
      repository.reads.last.result.complete(casesPage());
      await container.pump();
      expect(container.read(queue).requireValue.account.uid, 'host-2');
    },
  );

  test(
    'an observed request remains alive through its pending commit',
    () async {
      editor.select(const AssistanceCaseDecision.resolve());
      final pending = editor.submit();
      final write = repository.writes.single;
      subscription.close();
      await container.pump();
      write.result.complete(caseResult(write.change));
      expect((await pending).outcome, AssistanceCaseChangeOutcome.applied);
      await container.pump();
      await repository.waitForReads(2);
      expect(repository.writes, hasLength(1));
    },
  );

  test('a new page review has independent draft state', () async {
    editor.select(AssistanceCaseDecision.transfer('host-2'));
    container.read(queue.notifier).reload();
    await container.pump();
    await repository.waitForReads(2);
    repository.reads.last.result.complete(casesPage());
    await container.pump();
    final nextSession = container.read(queue).requireValue;
    final nextReview = nextSession.review(
      nextSession.page.cases.single as AssistanceOpenHostCase,
    );
    final next = eventAssistanceCaseEditorProvider(nextReview);
    container.listen(next, (_, _) {});
    expect((container.read(next) as AssistanceCaseForm).decision, isNull);
    expect(form().decision, isA<AssistanceCaseTransfer>());
  });
}

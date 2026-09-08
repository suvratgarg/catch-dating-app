import 'dart:async';

import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/auth/data/authenticated_session.dart';
import 'package:catch_dating_app/event_rehearsal/data/event_rehearsal_repository.dart';
import 'package:catch_dating_app/event_rehearsal/domain/event_rehearsal.dart';
import 'package:catch_dating_app/event_rehearsal/domain/event_rehearsal_assistance_automation.dart';
import 'package:catch_dating_app/event_rehearsal/domain/event_rehearsal_assistance_command.dart';
import 'package:catch_dating_app/event_rehearsal/domain/event_rehearsal_publication.dart';
import 'package:catch_dating_app/event_rehearsal/presentation/event_rehearsal_assistance_editor.dart';
import 'package:catch_dating_app/event_rehearsal/presentation/event_rehearsal_assistance_provider.dart';
import 'package:catch_dating_app/event_success/domain/event_assistance_late_join_destination.dart';
import 'package:catch_dating_app/event_success/presentation/event_assistance_account.dart';
import 'package:catch_dating_app/exceptions/app_exception.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'event_rehearsal_assistance_fixtures.dart';

void main() {
  late _Repository repository;
  late StreamController<String?> auth;
  late ProviderContainer container;
  final query = eventRehearsalAssistanceProvider('session-1');
  setUp(() {
    repository = _Repository();
    auth = StreamController<String?>.broadcast();
    container = ProviderContainer(
      overrides: [
        uidProvider.overrideWith((ref) => auth.stream),
        eventRehearsalRepositoryProvider.overrideWith((ref) => repository),
      ],
    );
    container.listen(query, (_, _) {});
  });
  tearDown(() async {
    container.dispose();
    await auth.close();
  });
  Future<void> signIn(String? uid) async {
    final expected = repository.reads.length + 1;
    auth.add(uid);
    await container.pump();
    if (uid != null) await repository.waitForReads(expected);
    await container.pump();
  }

  Future<void> completeRead(int index, {Map<String, Object?>? data}) async {
    await repository.waitForReads(index + 1);
    repository.reads[index].result.complete(
      EventRehearsalBootstrap.fromCallableData(data ?? practiceBootstrap()),
    );
    await container.pump();
  }

  Future<RehearsalAssistanceReview> review() async {
    await signIn('host-1');
    expect(repository.reads, hasLength(1));
    await completeRead(0);
    return container.read(query).requireValue;
  }

  EventRehearsalAssistanceEditor editor(RehearsalAssistanceReview review) {
    final provider = eventRehearsalAssistanceEditorProvider(review);
    container.listen(provider, (_, _) {});
    return container.read(provider.notifier);
  }

  RehearsalAssistanceEditorState state(RehearsalAssistanceReview review) =>
      container.read(eventRehearsalAssistanceEditorProvider(review));
  RehearsalAssistanceForm form(RehearsalAssistanceReview review) =>
      state(review) as RehearsalAssistanceForm;
  void confirm(
    int index, {
    int runtimeRevision = 5,
    List<Map<String, Object?>>? actors,
  }) {
    final write = repository.writes[index];
    write.result.complete(
      EventRehearsalBootstrap.fromCallableData(
        practiceBootstrap(
          runtimeRevision: runtimeRevision,
          actions: [practiceReceipt(write.change)],
          actors: actors,
        ),
      ),
    );
  }

  RehearsalPublishInstruction publish() =>
      RehearsalPublishInstruction(actorId: 'actor-01', plan: practicePlan());

  test('publication selection binds the plan to the current review', () async {
    final current = await review();
    final actions = editor(current);
    final point = rehearsalJoiningPoints(current.snapshot.session).single;
    RehearsalPublicationDraft draft({DateTime? deadline}) =>
        RehearsalPublicationDraft(
          actorId: 'actor-01',
          joiningPoint: point,
          rules: practiceRules(destination: const LateJoinConfirmedProgress()),
          guidanceText: 'Meet us at the studio.',
          departureConfirmed: true,
          routes: practicePlan().routes,
          deliveryPolicy: practicePlan().deliveryPolicy,
          responseDeadline: deadline,
        );
    actions.selectPublication(
      draft(deadline: current.snapshot.session.virtualNow),
    );
    expect(form(current).error, isA<FormatException>());
    expect(form(current).canSubmit, isFalse);
    expect(repository.writes, isEmpty);
    actions.selectPublication(draft());
    final change = form(current).change!;
    final command = change.command as RehearsalPublishInstruction;
    expect(command.plan.guidance.destination, point.target);
    expect(command.plan.guidance.validUntil, 3600000);
    expect(command.plan.departureConfirmed, isTrue);
    expect(change.toJson()['expectedSetupRevision'], 1);
    final pending = actions.submit();
    actions.selectPublication(draft());
    expect(form(current).change, same(change));
    expect(repository.writes.single.change, same(change));
    confirm(0);
    await pending;
    expect(form(current).phase, RehearsalAssistancePhase.applied);
  });

  test('automation retries keep the exact reviewed plan and script', () async {
    final current = await review();
    final actions = editor(current);
    final draft = RehearsalPublicationDraft(
      actorId: 'actor-01',
      joiningPoint: rehearsalJoiningPoints(current.snapshot.session).single,
      rules: practiceRules(destination: const LateJoinConfirmedProgress()),
      guidanceText: 'Meet us at the studio.',
      departureConfirmed: true,
      routes: practicePlan().routes,
      deliveryPolicy: practicePlan().deliveryPolicy,
    );
    actions.selectAutomation(draft, []);
    expect(form(current).error, isA<FormatException>());
    expect(form(current).canSubmit, isFalse);
    expect(repository.writes, isEmpty);
    final script = <RehearsalDeliveryOutcome>[
      const RehearsalDeliveryUnknown(RehearsalDeliveryUncertainty.timeout),
      const RehearsalDeliveryConfirmed(RehearsalConfirmedDelivery.delivered),
    ];
    actions.selectAutomation(draft, script);
    script.clear();
    final change = form(current).change!;
    final command = change.command as RehearsalConfigureAutomation;
    expect(command.plan.guidance.validUntil, 3600000);
    expect(command.outcomes.length, 2);
    final pending = actions.submit();
    expect(actions.submit(), same(pending));
    final failure = expectLater(pending, throwsA(isA<NetworkException>()));
    repository.writes[0].result.completeError(
      const NetworkException('unavailable', 'Offline'),
    );
    await failure;
    actions.select(RehearsalPauseAutomation(actorId: 'actor-01'));
    actions.selectAutomation(draft, []);
    expect(form(current).change, same(change));
    final retry = actions.submit();
    expect(repository.writes[1].change, same(change));
    expect(repository.writes[1].change.toJson(), change.toJson());
    final automation = practiceAutomation(
      consumed: 1,
      evaluation: {
        'at': 1000,
        'policy': null,
        'delivery': {
          'kind': 'reconcile',
          'attemptIds': ['attempt-1'],
          'notBefore': 121000,
        },
      },
    )..['plan'] = command.plan.toJson();
    confirm(
      1,
      actors: [
        {
          ...practiceActor(withAssistance: true),
          'assistanceAutomation': automation,
        },
      ],
    );
    final result = await retry;
    final saved = result.actors.single.assistanceAutomation!;
    expect(saved.remainingOutcomes, 1);
    expect(saved.evaluation!.delivery, isA<RehearsalDeliveryReconcile>());
    expect(form(current).phase, RehearsalAssistancePhase.applied);
    expect(repository.writes.length, 2);
  });

  for (final (command, status) in [
    (RehearsalPauseAutomation(actorId: 'actor-01'), 'paused'),
    (RehearsalResumeAutomation(actorId: 'actor-01'), 'enabled'),
  ]) {
    test('${command.kind} uses its reviewed request receipt', () async {
      final current = await review();
      final actions = editor(current)..select(command);
      expect(form(current).change!.command, same(command));
      expect(form(current).change!.toJson()['expectedSetupRevision'], 1);
      final pending = actions.submit();
      confirm(
        0,
        actors: [
          {
            ...practiceActor(),
            'assistanceAutomation': practiceAutomation(status: status),
          },
        ],
      );
      expect(
        (await pending).actors.single.assistanceAutomation!.status.name,
        status,
      );
      expect(repository.writes.single.change.command.kind, command.kind);
    });
  }

  test(
    'loading, signed-out and failed authentication expose no private review',
    () async {
      expect(container.read(query).isLoading, isTrue);
      expect(repository.reads, isEmpty);
      final first = await review();
      expect(
        first.account,
        same(container.read(authenticatedSessionProvider).requireValue),
      );
      expect(
        first.account,
        same(container.read(eventAssistanceAccountProvider).requireValue),
      );
      await signIn(null);
      expect(container.read(query).hasValue, isFalse);
      expect(container.read(query).error, isA<SignInRequiredException>());
      expect(first.isCurrent, isFalse);
      container.read(query.notifier).reload();
      expect(repository.reads, hasLength(1));
      auth.addError(StateError('Authentication unavailable'));
      await container.pump();
      expect(container.read(query).hasValue, isFalse);
    },
  );

  test(
    'late old-account reads and foreign session projections cannot create a review',
    () async {
      await signIn('host-1');
      await signIn('host-2');
      await completeRead(0);
      expect(container.read(query).isLoading, isTrue);
      await completeRead(
        1,
        data: practiceBootstrap(sessionId: 'other-session'),
      );
      expect(container.read(query).hasError, isTrue);
      expect(container.read(query).hasValue, isFalse);
      expect(repository.reads.map((read) => read.sessionId), [
        'session-1',
        'session-1',
      ]);
    },
  );

  test(
    'explicit refresh retires the prior review and ignores old pending reads',
    () async {
      final old = await review();
      final actions = editor(old);
      actions.select(publish());
      container.read(query.notifier).reload();
      await container.pump();
      expect(old.isCurrent, isFalse);
      expect(form(old).phase, RehearsalAssistancePhase.refreshRequired);
      await expectLater(actions.submit(), throwsA(isA<ValidationException>()));
      expect(repository.writes, isEmpty);
      container.read(query.notifier).reload();
      await container.pump();
      await completeRead(1);
      expect(container.read(query).isLoading, isTrue);
      await completeRead(2, data: practiceBootstrap(setupRevision: 2));
      final fresh = container.read(query).requireValue;
      expect(fresh.snapshot.session.setupRevision, 2);
      expect(fresh, isNot(same(old)));
    },
  );

  test(
    'one selected command owns duplicate submissions and confirmed result',
    () async {
      final current = await review();
      final actions = editor(current);
      await expectLater(actions.submit(), throwsA(isA<ValidationException>()));
      actions.select(publish());
      final change = form(current).change!;
      final pending = actions.submit();
      expect(identical(actions.submit(), pending), isTrue);
      expect(form(current).canDismiss, isFalse);
      actions.select(null);
      expect(form(current).change, same(change));
      expect(repository.writes, hasLength(1));
      confirm(0);
      final result = await pending;
      await container.pump();
      expect(form(current).phase, RehearsalAssistancePhase.applied);
      expect(await actions.submit(), same(result));
      expect(repository.writes, hasLength(1));
      expect(result.presentCount, 0);
      expect(repository.reads, hasLength(2));
    },
  );

  test(
    'uncertain outcome retains exact payload and rejects another choice until resolved',
    () async {
      final current = await review();
      final actions = editor(current)..select(publish());
      final change = form(current).change!;
      final pending = actions.submit();
      final failure = expectLater(pending, throwsA(isA<NetworkException>()));
      repository.writes[0].result.completeError(
        const NetworkException('unavailable', 'Offline'),
      );
      await failure;
      expect(form(current).phase, RehearsalAssistancePhase.retryRequired);
      expect(form(current).canEdit, isFalse);
      actions.select(null);
      final retry = actions.submit();
      expect(repository.writes[1].change, same(change));
      confirm(1, runtimeRevision: 8);
      expect((await retry).session.runtimeRevision, 8);
      expect(form(current).phase, RehearsalAssistancePhase.applied);
    },
  );

  test(
    'closing and reopening retains an uncertain command until review refresh',
    () async {
      final current = await review();
      final provider = eventRehearsalAssistanceEditorProvider(current);
      final subscription = container.listen(provider, (_, _) {});
      final actions = container.read(provider.notifier)..select(publish());
      final original = form(current).change;
      final failure = expectLater(
        actions.submit(),
        throwsA(isA<NetworkException>()),
      );
      repository.writes[0].result.completeError(
        const NetworkException('unavailable', 'Offline'),
      );
      await failure;
      subscription.close();
      await container.pump();
      expect(container.exists(provider), isTrue);
      final reopened = container.listen(provider, (_, _) {});
      expect(container.read(provider.notifier), same(actions));
      expect(form(current).change, same(original));
      expect(form(current).phase, RehearsalAssistancePhase.retryRequired);
      reopened.close();
      container.read(query.notifier).reload();
      await container.pump();
      expect(current.isCurrent, isFalse);
      expect(container.exists(provider), isFalse);
    },
  );

  test(
    'a reset conflict requires a fresh review rather than a rebased retry',
    () async {
      final current = await review();
      final actions = editor(current)..select(publish());
      final pending = actions.submit();
      final failure = expectLater(
        pending,
        throwsA(isA<BackendOperationException>()),
      );
      repository.writes[0].result.completeError(
        const BackendOperationException(
          code: 'aborted',
          message: 'Rehearsal reset',
          context: BackendErrorContext(
            service: BackendService.functions,
            action: 'practice',
            resource: 'eventRehearsals',
          ),
        ),
      );
      await failure;
      expect(form(current).phase, RehearsalAssistancePhase.refreshRequired);
      await expectLater(actions.submit(), throwsA(isA<ValidationException>()));
      expect(repository.writes, hasLength(1));
    },
  );

  test(
    'account change permanently revokes an editor even if its command completes',
    () async {
      final current = await review();
      final actions = editor(current)..select(publish());
      final pending = actions.submit();
      final failure = expectLater(
        pending,
        throwsA(same(rehearsalReviewSessionChanged)),
      );
      await signIn(null);
      await signIn('host-1');
      confirm(0);
      await failure;
      expect(state(current), isA<RehearsalAssistanceUnavailable>());
      await expectLater(
        actions.submit(),
        throwsA(same(rehearsalReviewSessionChanged)),
      );
      await completeRead(1);
      expect(
        container.read(query).requireValue.account,
        isNot(same(current.account)),
      );
      expect(state(current), isA<RehearsalAssistanceUnavailable>());
      expect(repository.writes, hasLength(1));
    },
  );

  test(
    'refresh during an in-flight command cannot restore an obsolete result',
    () async {
      final current = await review();
      final actions = editor(current)..select(publish());
      final pending = actions.submit();
      final failure = expectLater(
        pending,
        throwsA(same(rehearsalReviewExpired)),
      );
      container.read(query.notifier).reload();
      await container.pump();
      expect(form(current).phase, RehearsalAssistancePhase.submitting);
      confirm(0);
      await failure;
      expect(form(current).phase, RehearsalAssistancePhase.refreshRequired);
      expect(form(current).result, isNull);
    },
  );

  test(
    'invalid actor selection clears the draft without a backend call',
    () async {
      final current = await review();
      final actions = editor(current)..select(publish());
      actions.select(
        RehearsalPublishInstruction(
          actorId: 'unknown-actor',
          plan: practicePlan(),
        ),
      );
      expect(form(current).change, isNull);
      expect(form(current).error, isA<FormatException>());
      expect(form(current).canSubmit, isFalse);
      expect(repository.writes, isEmpty);
    },
  );
}

class _Repository extends Fake implements EventRehearsalRepository {
  Completer<void> _changed = Completer<void>();
  Future<void> waitForReads(int count) async {
    while (reads.length < count) {
      await _changed.future.timeout(const Duration(seconds: 10));
    }
  }

  final reads =
      <({String sessionId, Completer<EventRehearsalBootstrap> result})>[];
  final writes =
      <
        ({
          RehearsalAssistanceChange change,
          Completer<EventRehearsalBootstrap> result,
        })
      >[];
  @override
  Future<EventRehearsalBootstrap> fetch(String sessionId) {
    final result = Completer<EventRehearsalBootstrap>();
    reads.add((sessionId: sessionId, result: result));
    _changed.complete();
    _changed = Completer<void>();
    return result.future;
  }

  @override
  Future<EventRehearsalBootstrap> applyAssistance(
    RehearsalAssistanceChange change,
  ) {
    final result = Completer<EventRehearsalBootstrap>();
    writes.add((change: change, result: result));
    return result.future.then((value) {
      change.requireResult(value);
      return value;
    });
  }
}

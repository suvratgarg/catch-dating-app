import 'dart:async';

import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/event_success/data/event_assistance_participation_repository.dart';
import 'package:catch_dating_app/event_success/domain/event_assistance_participation.dart';
import 'package:catch_dating_app/event_success/presentation/event_assistance_participation_controller.dart';
import 'package:catch_dating_app/event_success/presentation/event_assistance_participation_editor.dart';
import 'package:catch_dating_app/exceptions/app_exception.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'event_assistance_participation_fixtures.dart';

void main() {
  late ProviderContainer container;
  late _Repository repository;
  late StreamController<String?> auth;
  late EventParticipationSession session;

  setUp(() async {
    repository = _Repository();
    auth = StreamController<String?>.broadcast();
    container = ProviderContainer(
      retry: (_, _) => null,
      overrides: [
        uidProvider.overrideWith((ref) => auth.stream),
        eventAssistanceParticipationRepositoryProvider.overrideWith(
          (ref) => repository,
        ),
      ],
    );
    container.listen(uidProvider, (_, _) {});
    auth.add('host-1');
    await container.pump();
    session = EventParticipationSession(
      accountId: 'host-1',
      view: participationView(),
    );
  });
  tearDown(() async {
    container.dispose();
    await auth.close();
  });

  EventAssistanceParticipationEditor editor(EventParticipationSession session) {
    final provider = eventAssistanceParticipationEditorProvider(session);
    container.listen(provider, (_, _) {});
    return container.read(provider.notifier);
  }

  EventParticipationEditorState current(EventParticipationSession session) =>
      container.read(eventAssistanceParticipationEditorProvider(session));

  test('a reviewed guest does not submit an implicit default', () async {
    final form = editor(session);
    expect(current(session).choice, isNull);
    expect(current(session).canSubmit, isFalse);
    expect(current(session).showsReturnPoint, isFalse);
    await expectLater(form.submit(), throwsA(isA<ValidationException>()));
    expect(repository.changes, isEmpty);
  });

  test(
    'return point is disclosed only for a break and cleared on departure',
    () {
      final form = editor(session);
      form.select(EventParticipationChoice.temporaryBreak);
      expect(current(session).showsReturnPoint, isTrue);
      expect(current(session).returnPointId, isNull);
      form.selectReturnPoint('itinerary:second');
      expect(
        current(session).participation,
        isA<EventParticipationOnBreak>().having(
          (p) => p.resumeAtUnit,
          'return point',
          'itinerary:second',
        ),
      );
      expect(
        () => form.selectReturnPoint('itinerary:removed'),
        throwsArgumentError,
      );
      form.select(EventParticipationChoice.departed);
      expect(current(session).returnPointId, isNull);
      expect(current(session).showsReturnPoint, isFalse);
      expect(
        () => form.selectReturnPoint('itinerary:second'),
        throwsArgumentError,
      );
      form.select(EventParticipationChoice.temporaryBreak);
      expect(current(session).returnPointId, isNull);
    },
  );

  test(
    'closed or ineligible guests cannot stage a participation change',
    () async {
      session = EventParticipationSession(
        accountId: 'host-1',
        view: participationView(canChange: false),
      );
      final form = editor(session);
      form.select(EventParticipationChoice.active);
      expect(current(session).choice, isNull);
      expect(current(session).canEdit, isFalse);
      expect(current(session).canReload, isTrue);
      await expectLater(form.submit(), throwsA(isA<ValidationException>()));
      expect(repository.changes, isEmpty);
    },
  );

  test(
    'pending save freezes controls and deduplicates keyboard or tap triggers',
    () async {
      final form = editor(session);
      form.select(EventParticipationChoice.temporaryBreak);
      form.selectReturnPoint('itinerary:second');
      final first = form.submit();
      final duplicate = form.submit();
      expect(identical(first, duplicate), isTrue);
      expect(repository.changes, hasLength(1));
      expect(current(session).canDismiss, isFalse);
      expect(current(session).canReload, isFalse);
      form.select(EventParticipationChoice.departed);
      form.selectReturnPoint(null);
      expect(current(session).choice, EventParticipationChoice.temporaryBreak);
      expect(current(session).returnPointId, 'itinerary:second');
      repository.complete(0);
      await first;
      expect(current(session).phase, EventParticipationEditorPhase.saved);
      expect(
        current(session).result!.view.participation,
        isA<EventParticipationOnBreak>(),
      );
      await form.submit();
      expect(repository.changes, hasLength(1));
    },
  );

  test(
    'uncertain delivery retries the original request with no editable replacement',
    () async {
      final form = editor(session);
      form.select(EventParticipationChoice.departed);
      final first = form.submit();
      final failure = expectLater(first, throwsA(isA<NetworkException>()));
      repository.pending[0].completeError(
        const NetworkException('timeout', 'Timed out'),
      );
      await failure;
      expect(
        current(session).phase,
        EventParticipationEditorPhase.retryRequired,
      );
      expect(current(session).canSubmit, isTrue);
      expect(current(session).canEdit, isFalse);
      expect(current(session).canReload, isTrue);
      form.select(EventParticipationChoice.active);
      final retry = form.submit();
      expect(identical(repository.changes[0], repository.changes[1]), isTrue);
      repository.complete(1, replayed: true);
      await retry;
      expect(
        current(session).result!.outcome,
        EventParticipationOutcome.replayed,
      );
    },
  );

  test(
    'a source conflict requires fresh review without automatic rebasing',
    () async {
      final form = editor(session);
      form.select(EventParticipationChoice.active);
      final first = form.submit();
      final failure = expectLater(
        first,
        throwsA(isA<BackendOperationException>()),
      );
      repository.pending[0].completeError(
        const BackendOperationException(
          code: 'aborted',
          message: 'Changed',
          context: BackendErrorContext(
            service: BackendService.functions,
            action: 'update guest participation',
          ),
        ),
      );
      await failure;
      expect(
        current(session).phase,
        EventParticipationEditorPhase.refreshRequired,
      );
      expect(current(session).canSubmit, isFalse);
      await expectLater(form.submit(), throwsA(isA<ValidationException>()));
      expect(repository.changes, hasLength(1));
      final refreshed = EventParticipationSession(
        accountId: 'host-1',
        view: EventAssistanceParticipationResult.fromCallableData(
          participationResponse(revision: 4),
          expectedScope: participationScope(),
        ).view,
      );
      final next = editor(refreshed);
      expect(current(refreshed).choice, isNull);
      next.select(EventParticipationChoice.departed);
      final accepted = next.submit();
      expect(repository.changes[1].snapshot.revision, 4);
      expect(
        repository.changes[1].operationId,
        isNot(repository.changes[0].operationId),
      );
      repository.complete(1);
      await accepted;
    },
  );

  test(
    'a newly loaded editor cannot be overwritten by an earlier completion',
    () async {
      final old = editor(session);
      old.select(EventParticipationChoice.departed);
      final first = old.submit();
      final refreshed = EventParticipationSession(
        accountId: 'host-1',
        view: participationView(),
      );
      final fresh = editor(refreshed);
      fresh.select(EventParticipationChoice.temporaryBreak);
      repository.complete(0);
      await first;
      expect(current(refreshed).phase, EventParticipationEditorPhase.choosing);
      expect(
        current(refreshed).choice,
        EventParticipationChoice.temporaryBreak,
      );
      expect(current(refreshed).result, isNull);
    },
  );

  test(
    'sign-in changes during a save require review and prevent success navigation',
    () async {
      final form = editor(session);
      form.select(EventParticipationChoice.active);
      final first = form.submit();
      auth.add('host-2');
      await container.pump();
      final failure = expectLater(
        first,
        throwsA(isA<BackendOperationException>()),
      );
      repository.complete(0);
      await failure;
      expect(
        current(session).phase,
        EventParticipationEditorPhase.refreshRequired,
      );
      expect(current(session).result, isNull);
      expect(repository.changes, hasLength(1));
    },
  );
}

class _Repository extends Fake
    implements EventAssistanceParticipationRepository {
  final changes = <EventAssistanceParticipationChange>[];
  final pending = <Completer<EventAssistanceParticipationResult>>[];

  @override
  Future<EventAssistanceParticipationResult> apply(
    EventAssistanceParticipationChange change,
  ) {
    changes.add(change);
    final result = Completer<EventAssistanceParticipationResult>();
    pending.add(result);
    return result.future;
  }

  void complete(int index, {bool replayed = false}) {
    final change = changes[index];
    pending[index].complete(
      EventAssistanceParticipationResult.fromCallableData(
        participationResponse(
          outcome: replayed ? 'replayed' : 'applied',
          revision: change.snapshot.revision + 1,
          operationRevision: change.snapshot.revision + 1,
          participation: change.participation.toJson(),
        ),
        expectedScope: change.snapshot.scope,
      ),
    );
  }
}

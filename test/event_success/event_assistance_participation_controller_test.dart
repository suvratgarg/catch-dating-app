import 'dart:async';

import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/event_success/data/event_assistance_participation_repository.dart';
import 'package:catch_dating_app/event_success/domain/event_assistance_participation.dart';
import 'package:catch_dating_app/event_success/presentation/event_assistance_participation_controller.dart';
import 'package:catch_dating_app/exceptions/app_exception.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'event_assistance_participation_fixtures.dart';

void main() {
  late _Repository repository;
  late ProviderContainer container;
  late StreamController<String?> auth;
  late EventAssistanceParticipationController controller;

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
    container.listen(eventAssistanceParticipationControllerProvider, (_, _) {});
    controller = container.read(
      eventAssistanceParticipationControllerProvider.notifier,
    );
    auth.add('host-1');
    await container.pump();
  });
  tearDown(() async {
    container.dispose();
    await auth.close();
  });

  Future<EventParticipationSession> load() async {
    final provider = eventAssistanceParticipationProvider(participationScope());
    container.listen(provider, (_, _) {});
    return container.read(provider.future);
  }

  test(
    'provider reloads for a new account without sharing the old session',
    () async {
      final first = await load();
      expect(first.accountId, 'host-1');
      auth.add('host-2');
      await container.pump();
      final second = await load();
      expect(second.accountId, 'host-2');
      expect(repository.reads, 2);
    },
  );

  test('missing authentication makes no repository request', () async {
    auth.add(null);
    await container.pump();
    await expectLater(load(), throwsA(isA<SignInRequiredException>()));
    expect(repository.reads, 0);
  });

  test(
    'a saved pending action retains its ID and snapshot through retries',
    () async {
      final session = await load();
      final action = controller.prepare(
        session: session,
        participation: const EventAssistanceParticipation.departed(),
      );
      repository.error = const SignInRequiredException(
        'update guest participation',
      );
      await expectLater(
        controller.submit(action),
        throwsA(isA<SignInRequiredException>()),
      );
      expect(repository.reads, 1);
      repository.error = null;
      final result = await controller.submit(action);
      expect(result.operationRevision, 3);
      expect(identical(repository.changes[0], repository.changes[1]), isTrue);
      expect(action.mutationKey, (
        accountId: 'host-1',
        scope: participationScope(),
      ));
      expect(
        action.mutationKey,
        isNot((
          accountId: 'host-1',
          scope: participationScope(attendeeId: 'guest-2'),
        )),
      );
      await container.pump();
      await container.read(
        eventAssistanceParticipationProvider(participationScope()).future,
      );
      expect(repository.reads, 2);
    },
  );

  test(
    'old-account views and pending actions cannot submit as the next account',
    () async {
      final session = await load();
      final action = controller.prepare(
        session: session,
        participation: const EventAssistanceParticipation.active(),
      );
      auth.add('host-2');
      await container.pump();
      expect(
        () => controller.prepare(
          session: session,
          participation: const EventAssistanceParticipation.active(),
        ),
        throwsA(
          isA<BackendOperationException>().having(
            (e) => e.code,
            'code',
            'session-changed',
          ),
        ),
      );
      await expectLater(
        controller.submit(action),
        throwsA(isA<BackendOperationException>()),
      );
      expect(repository.changes, isEmpty);
    },
  );

  test(
    'an account change during I/O cannot report the old action as current success',
    () async {
      final action = controller.prepare(
        session: await load(),
        participation: const EventAssistanceParticipation.active(),
      );
      repository.pending = Completer<EventAssistanceParticipationResult>();
      final result = controller.submit(action);
      auth.add('host-2');
      await container.pump();
      final expectation = expectLater(
        result,
        throwsA(isA<BackendOperationException>()),
      );
      repository.pending!.complete(repository.result);
      await expectation;
    },
  );
}

class _Repository extends Fake
    implements EventAssistanceParticipationRepository {
  int reads = 0;
  Object? error;
  Completer<EventAssistanceParticipationResult>? pending;
  final changes = <EventAssistanceParticipationChange>[];
  final result = EventAssistanceParticipationResult.fromCallableData(
    participationResponse(
      outcome: 'applied',
      operationRevision: 3,
      revision: 3,
    ),
    expectedScope: participationScope(),
  );

  @override
  Future<EventAssistanceParticipationView> fetch(
    EventAssistanceGuestScope scope,
  ) async {
    reads++;
    return participationView();
  }

  @override
  Future<EventAssistanceParticipationResult> apply(
    EventAssistanceParticipationChange change,
  ) async {
    changes.add(change);
    if (error case final error?) throw error;
    return pending == null ? result : pending!.future;
  }
}

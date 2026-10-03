import 'dart:async';

import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/programs/data/program_lodging_providers.dart';
import 'package:catch_dating_app/programs/data/program_lodging_repository.dart';
import 'package:catch_dating_app/programs/data/program_projection_lifetime.dart';
import 'package:catch_dating_app/programs/data/program_read_snapshots.dart';
import 'package:catch_dating_app/programs/domain/program_lodging_review.dart';
import 'package:catch_dating_app/programs/presentation/program_lodging_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'program_lodging_test_fixtures.dart';
import 'program_operations_fixture.dart';

void main() {
  late ProviderContainer container;
  late FakeLodgingRepository repository;
  late ProgramReadSnapshotStore snapshots;
  late ProviderSubscription<AsyncValue<ProgramLodgingView>> subscription;
  final provider = programLodgingControllerProvider('program');
  setUp(() {
    repository = FakeLodgingRepository();
    snapshots = emptyProgramSnapshots();
    container = ProviderContainer(
      retry: (_, _) => null,
      overrides: [
        uidProvider.overrideWithValue(const AsyncData('actor')),
        programReadSnapshotStoreProvider.overrideWithValue(snapshots),
        programLodgingRepositoryProvider.overrideWithValue(repository),
      ],
    );
    subscription = container.listen(provider, (_, _) {});
  });
  tearDown(() => container.dispose());

  test('initial private view uses exact current proposal and setup', () async {
    final view = await container.read(provider.future);
    expect(view.review?.proposal.id, lodgingFixtureId);
    expect(view.busy, false);
    expect(view.setup.configuration, view.review?.configuration);
  });

  test(
    'missing setup exposes no invented rooms or sharing assumptions',
    () async {
      repository.hasSetup = false;
      container.invalidate(provider);
      final view = await container.read(provider.future);
      expect(view.review, isNull);
      expect(view.setup.configuration, isNull);
      expect(repository.commands, isEmpty);
    },
  );

  test('busy regeneration rejects a second mutation', () async {
    await container.read(provider.future);
    final gate = Completer<ProgramLodgingReview>();
    repository.pendingPreview = gate.future;
    final controller = container.read(provider.notifier);
    final pending = controller.regenerate();
    expect(container.read(provider).requireValue.busy, true);
    await expectLater(
      controller.regenerate(),
      throwsA(same(programReadSuperseded)),
    );
    gate.complete(repository.current);
    await pending;
    expect(container.read(provider).requireValue.busy, false);
  });

  test(
    'uncertain publication retries exact command without stale save',
    () async {
      await container.read(provider.future);
      final controller = container.read(provider.notifier);
      repository.transitionFailure = TimeoutException('Uncertain transport');
      await expectLater(
        controller.decide(ProgramLodgingAction.publishGuests),
        throwsA(isA<TimeoutException>()),
      );
      expect(
        container.read(provider).requireValue.retryAction,
        ProgramLodgingAction.publishGuests,
      );
      final first = Map.of(repository.commands.single);
      await expectLater(
        controller.decide(ProgramLodgingAction.approve),
        throwsA(isA<StateError>()),
      );
      repository.transitionFailure = null;
      await controller.decide(ProgramLodgingAction.publishGuests);
      expect(repository.commands.last, first);
      expect(repository.saves, 0);
      expect(container.read(provider).requireValue.retryAction, isNull);
    },
  );

  test(
    'uncertain approval retries one immutable save and same operation',
    () async {
      await container.read(provider.future);
      final controller = container.read(provider.notifier);
      repository.transitionFailure = TimeoutException('Uncertain transport');
      await expectLater(
        controller.decide(ProgramLodgingAction.approve),
        throwsA(isA<TimeoutException>()),
      );
      final first = Map.of(repository.commands.single);
      expect(repository.saves, 1);
      repository.transitionFailure = null;
      await controller.decide(ProgramLodgingAction.approve);
      expect(repository.commands.last, first);
      expect(repository.saves, 1);
    },
  );

  test(
    'acknowledged decision with failed refresh hides stale controls',
    () async {
      await container.read(provider.future);
      repository.previewFailure = TimeoutException('Reload failed');
      await expectLater(
        container
            .read(provider.notifier)
            .decide(ProgramLodgingAction.publishGuests),
        throwsA(isA<TimeoutException>()),
      );
      expect(container.read(provider).hasError, true);
      expect(container.read(provider).asData, isNull);
      expect(repository.commands, hasLength(1));
    },
  );

  test(
    'authority generation invalidates private view and late regeneration',
    () async {
      await container.read(provider.future);
      final gate = Completer<ProgramLodgingReview>();
      repository.pendingPreview = gate.future;
      final pending = container.read(provider.notifier).regenerate();
      repository.hasSetup = false;
      await container
          .read(programReadSnapshotStoreProvider)
          .clearProgram('actor', 'program');
      await container.pump();
      final fresh = await container.read(provider.future);
      expect(fresh.review, isNull);
      gate.complete(repository.current);
      await expectLater(pending, throwsA(same(programReadSuperseded)));
      expect(container.read(provider).requireValue.review, isNull);
    },
  );
  test(
    'account switch rejects a late proposal from the prior session',
    () async {
      await container.read(provider.future);
      final gate = Completer<ProgramLodgingReview>();
      repository.pendingPreview = gate.future;
      final pending = container.read(provider.notifier).regenerate();
      repository.hasSetup = false;
      container.updateOverrides([
        uidProvider.overrideWithValue(const AsyncData('other')),
        programReadSnapshotStoreProvider.overrideWithValue(snapshots),
        programLodgingRepositoryProvider.overrideWithValue(repository),
      ]);
      await container.pump();
      expect((await container.read(provider.future)).review, isNull);
      gate.complete(repository.current);
      await expectLater(pending, throwsA(same(programReadSuperseded)));
      expect(container.read(provider).requireValue.review, isNull);
    },
  );

  test(
    'disposing during save cannot start the subsequent approval write',
    () async {
      await container.read(provider.future);
      final gate = Completer<ProgramLodgingProposal>();
      repository.pendingSave = gate.future;
      final pending = container
          .read(provider.notifier)
          .decide(ProgramLodgingAction.approve);
      subscription.close();
      await container.pump();
      gate.complete(repository.current.proposal);
      await expectLater(pending, throwsA(same(programReadSuperseded)));
      expect(repository.saves, 1);
      expect(repository.commands, isEmpty);
    },
  );
}

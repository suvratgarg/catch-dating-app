import '../integration_test/support/cat151_razorpay_attempt_ledger.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late _MemoryStore store;
  late Cat151AttemptLedger ledger;

  setUp(() {
    store = _MemoryStore();
    ledger = Cat151AttemptLedger(store: store, nowMillis: () => 1700000000000);
  });

  Future<Cat151AttemptLedgerState> bind({
    String uid = 'synthetic-user',
    String eventId = 'synthetic-event',
    String seed = 'cat151-seed',
  }) => ledger.bindScope(
    projectId: 'catch-staging',
    uid: uid,
    eventId: eventId,
    seedPrefix: seed,
  );

  test('binds one durable scope per Firebase project', () async {
    final state = await bind();
    final reloaded = await Cat151AttemptLedger(
      store: store,
    ).load('catch-staging');

    expect(reloaded?.toJson(), state.toJson());
    expect(state.attempts, isEmpty);
  });

  test('reserves attempt before checkout and preserves uncertainty', () async {
    final reserved = await ledger.reserveNext(await bind());
    final afterProcessDeath = await Cat151AttemptLedger(
      store: store,
    ).load('catch-staging');

    expect(reserved.attempts.single.status, Cat151AttemptStatus.reserved);
    expect(
      afterProcessDeath?.attempts.single.status,
      Cat151AttemptStatus.reserved,
    );
  });

  test('never unlocks attempt two automatically', () async {
    final reserved = await ledger.reserveNext(await bind());

    await expectLater(
      ledger.reserveNext(reserved),
      throwsA(isA<Cat151AttemptLedgerException>()),
    );
  });

  test('requires the exact explicit confirmation for attempt two', () async {
    final first = await ledger.reserveNext(await bind());
    await expectLater(
      ledger.authorizeSecondAttempt(first, confirmation: 'yes'),
      throwsA(isA<Cat151AttemptLedgerException>()),
    );

    final authorized = await ledger.authorizeSecondAttempt(
      first,
      confirmation: cat151SecondAttemptConfirmation,
    );
    final second = await ledger.reserveNext(authorized);
    expect(second.attempts.map((attempt) => attempt.number), [1, 2]);
  });

  test('hard-stops after two attempts or a known admission', () async {
    final first = await ledger.reserveNext(await bind());
    final authorized = await ledger.authorizeSecondAttempt(
      first,
      confirmation: cat151SecondAttemptConfirmation,
    );
    final second = await ledger.reserveNext(authorized);
    await expectLater(
      ledger.reserveNext(second),
      throwsA(isA<Cat151AttemptLedgerException>()),
    );

    final admittedLedger = Cat151AttemptLedger(
      store: _MemoryStore(),
      nowMillis: () => 1700000000000,
    );
    final admittedScope = await admittedLedger.bindScope(
      projectId: 'other-project',
      uid: 'synthetic-user',
      eventId: 'synthetic-event',
      seedPrefix: 'cat151-seed',
    );
    final admittedAttempt = await admittedLedger.reserveNext(admittedScope);
    final admitted = await admittedLedger.markAdmitted(
      admittedAttempt,
      attemptNumber: 1,
      paymentId: 'pay-test',
      orderId: 'order-test',
    );
    await expectLater(
      admittedLedger.reserveNext(admitted),
      throwsA(isA<Cat151AttemptLedgerException>()),
    );
    await expectLater(
      admittedLedger.markRefunded(
        admitted,
        attemptNumber: 1,
        paymentId: 'different-payment',
        orderId: 'order-test',
      ),
      throwsA(isA<Cat151AttemptLedgerException>()),
    );
    final refunded = await admittedLedger.markRefunded(
      admitted,
      attemptNumber: 1,
      paymentId: 'pay-test',
      orderId: 'order-test',
    );
    await expectLater(
      admittedLedger.markAdmitted(
        refunded,
        attemptNumber: 1,
        paymentId: 'pay-test',
        orderId: 'order-test',
      ),
      throwsA(isA<Cat151AttemptLedgerException>()),
    );
  });

  test('rejects a different identity, event, or seed in the project', () async {
    await bind();

    for (final changed in [
      (uid: 'other-user', eventId: 'synthetic-event', seed: 'cat151-seed'),
      (uid: 'synthetic-user', eventId: 'other-event', seed: 'cat151-seed'),
      (uid: 'synthetic-user', eventId: 'synthetic-event', seed: 'other-seed'),
    ]) {
      await expectLater(
        bind(uid: changed.uid, eventId: changed.eventId, seed: changed.seed),
        throwsA(isA<Cat151AttemptLedgerException>()),
      );
    }
  });

  test('malformed persistence fails closed without replacement', () async {
    store.values['cat151_razorpay_acceptance_v1_Y2F0Y2gtc3RhZ2luZw=='] =
        '{"version":99}';

    await expectLater(
      ledger.load('catch-staging'),
      throwsA(isA<Cat151AttemptLedgerException>()),
    );
    expect(store.values.values.single, '{"version":99}');
  });
  group('approved schema acceptance allowance', () {
    const project = 'catch-dating-app-64e51';
    const uid = 'cross_paths_mumbai_qa_user_002';
    const seed = 'cross_paths_mumbai_qa';

    Future<void> preserveOriginal() async {
      final original = Cat151AttemptLedger(store: store);
      final bound = await original.bindScope(
        projectId: project,
        uid: uid,
        seedPrefix: seed,
        eventId: 'cat151-prod-test-20261005-checkout',
      );
      await original.reserveNext(bound);
    }

    Future<Cat151AttemptLedgerState> bindAdditional(
      Cat151AttemptLedger additional, {
      String event = cat151SchemaAcceptanceEvent,
    }) => additional.bindScope(
      projectId: project,
      uid: uid,
      seedPrefix: seed,
      eventId: event,
    );

    test('requires the intact consumed original ledger', () async {
      final additional = Cat151AttemptLedger.schemaAcceptance(store: store);
      await expectLater(
        bindAdditional(additional),
        throwsA(isA<Cat151AttemptLedgerException>()),
      );
      expect(store.values, isEmpty);
      await preserveOriginal();
      final key = store.values.keys.single;
      store.values[key] = '{"version":99}';
      await expectLater(
        bindAdditional(additional),
        throwsA(isA<Cat151AttemptLedgerException>()),
      );
      expect(store.values, {key: '{"version":99}'});
    });

    test(
      'preserves original bytes through restart, admission and refund',
      () async {
        await preserveOriginal();
        final originalBytes = Map<String, String>.from(store.values);
        var additional = Cat151AttemptLedger.schemaAcceptance(store: store);
        var state = await additional.reserveNext(
          await bindAdditional(additional),
        );
        additional = Cat151AttemptLedger.schemaAcceptance(store: store);
        state = (await additional.load(project))!;
        expect(state.attempts.single.status, Cat151AttemptStatus.reserved);
        await expectLater(
          additional.reserveNext(state),
          throwsA(isA<Cat151AttemptLedgerException>()),
        );
        await expectLater(
          additional.authorizeSecondAttempt(
            state,
            confirmation: cat151SecondAttemptConfirmation,
          ),
          throwsA(isA<Cat151AttemptLedgerException>()),
        );
        state = await additional.markAdmitted(
          state,
          attemptNumber: 1,
          paymentId: 'pay-new',
          orderId: 'order-new',
        );
        state = await additional.markRefunded(
          state,
          attemptNumber: 1,
          paymentId: 'pay-new',
          orderId: 'order-new',
        );
        await expectLater(
          additional.reserveNext(state),
          throwsA(isA<Cat151AttemptLedgerException>()),
        );
        expect(
          (await additional.load(project))!.attempts.single.status,
          Cat151AttemptStatus.refunded,
        );
        expect(store.values.length, 2);
        for (final entry in originalBytes.entries) {
          expect(store.values[entry.key], entry.value);
        }
      },
    );

    test(
      'rejects another scope and a persisted second authorization',
      () async {
        await preserveOriginal();
        final additional = Cat151AttemptLedger.schemaAcceptance(store: store);
        await expectLater(
          bindAdditional(additional, event: 'other-event'),
          throwsA(isA<Cat151AttemptLedgerException>()),
        );
        expect(store.values.length, 1);
        await additional.reserveNext(await bindAdditional(additional));
        final key = store.values.keys.singleWhere(
          (key) => key.endsWith('_schema_acceptance_20261016'),
        );
        store.values[key] = store.values[key]!.replaceFirst(
          '"secondAttemptAuthorized":false',
          '"secondAttemptAuthorized":true',
        );
        await expectLater(
          additional.load(project),
          throwsA(isA<Cat151AttemptLedgerException>()),
        );
      },
    );
  });
}

final class _MemoryStore implements Cat151StringStore {
  final values = <String, String>{};

  @override
  Future<String?> getString(String key) async => values[key];

  @override
  Future<void> setString(String key, String value) async {
    values[key] = value;
  }
}

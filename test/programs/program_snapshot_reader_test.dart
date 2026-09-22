import 'package:catch_dating_app/exceptions/app_exception.dart';
import 'package:catch_dating_app/programs/data/program_read_snapshots.dart';
import 'package:catch_dating_app/programs/data/program_snapshot_reader.dart';
import 'package:catch_dating_app/programs/domain/program_access_policy.dart';
import 'package:catch_dating_app/programs/domain/program_models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late SharedPreferencesProgramReadSnapshotStore store;
  final scope = programSnapshotScope('arrivals', 'p1', 't3');
  Map<String, Object?> access({bool expired = false}) => {
    'programId': 'p1',
    'organizerId': 'org',
    'title': 'Private program',
    'kind': 'wedding',
    'timezone': 'Asia/Kolkata',
    'status': 'active',
    'actorRole': 'staff',
    'capabilities': ['arrivalsTransport'],
    'duties': [
      {
        'duty': 'airportGreeter',
        'pickupPointIds': ['t3'],
        'hotelIds': [],
      },
    ],
    'grantExpiresAtMillis': DateTime.now()
        .add(Duration(hours: expired ? -1 : 1))
        .millisecondsSinceEpoch,
    'pickupPoints': [],
    'hotels': [],
    'vehicleClasses': [],
  };
  Future<void> seed({bool expired = false}) async {
    await store.save(
      'account',
      programSnapshotScope('work', 'p1'),
      access(expired: expired),
    );
    await store.save('account', scope, {'programId': 'p1', 'guest': 'Private'});
  }

  Future<ProgramReadView<Map<String, Object?>>> read(
    AppException error, {
    bool Function()? current,
    String station = 't3',
  }) => readProgramWithSnapshot(
    accountId: 'account',
    programId: 'p1',
    scope: scope,
    store: store,
    isCurrentAccount: current ?? () => true,
    live: () async => throw error,
    parse: (value) =>
        requiredMap(value, 'test snapshot').cast<String, Object?>(),
    allowsAccess: (a) => canReadProgramStation(a, station, dispatch: false),
  );

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    store = SharedPreferencesProgramReadSnapshotStore();
  });

  test(
    'connectivity failure returns only an authorized account snapshot',
    () async {
      await seed();
      final result = await read(
        const NetworkException('connection-failed', 'Offline'),
      );
      expect(result.value['guest'], 'Private');
      expect(result.snapshotAt, isNotNull);
    },
  );

  test(
    'denied access purges snapshots and cannot be bypassed offline',
    () async {
      await seed();
      await expectLater(
        read(const PermissionException('Revoked')),
        throwsA(isA<PermissionException>()),
      );
      expect(await store.load('account', scope), isNull);
      await expectLater(
        read(const NetworkException('connection-failed', 'Offline')),
        throwsA(isA<NetworkException>()),
      );
    },
  );

  test('rate limits and validation errors never unlock offline data', () async {
    await seed();
    for (final error in <AppException>[
      const NetworkException('too-many-requests', 'Limit'),
      const ValidationException('Invalid'),
    ]) {
      await expectLater(read(error), throwsA(same(error)));
    }
  });

  test(
    'expired grants and stations outside the grant cannot load a snapshot',
    () async {
      await seed(expired: true);
      await expectLater(
        read(const NetworkException('connection-failed', 'Offline')),
        throwsA(isA<NetworkException>()),
      );
      await seed();
      await expectLater(
        read(
          const NetworkException('connection-failed', 'Offline'),
          station: 'other',
        ),
        throwsA(isA<NetworkException>()),
      );
    },
  );

  test('account changes during a read discard its result', () async {
    await seed();
    var current = true;
    await expectLater(
      readProgramWithSnapshot(
        accountId: 'account',
        programId: 'p1',
        scope: scope,
        store: store,
        isCurrentAccount: () => current,
        live: () async {
          current = false;
          return 'old account data';
        },
        parse: (_) => 'cached',
      ),
      throwsA(isA<SignInRequiredException>()),
    );
  });

  test(
    'late saves cannot restore a revoked or signed-out account snapshot',
    () async {
      await seed();
      final generation = store.generation('account', 'p1');
      await store.clearAccount('account');
      await store.save(
        'account',
        programSnapshotScope('work', 'p1'),
        access(),
        expectedGeneration: generation,
      );
      await store.save('account', scope, {
        'programId': 'p1',
      }, expectedGeneration: generation);
      expect(await store.load('account', scope), isNull);
      expect(
        await store.load('account', programSnapshotScope('work', 'p1')),
        isNull,
      );
    },
  );

  test('concurrent scope saves do not overwrite one another', () async {
    await Future.wait([
      for (var i = 0; i < 10; i++)
        store.save('account', programSnapshotScope('arrivals', 'p1', 't$i'), {
          'programId': 'p1',
          'station': i,
        }),
    ]);
    for (var i = 0; i < 10; i++) {
      expect(
        await store.load(
          'account',
          programSnapshotScope('arrivals', 'p1', 't$i'),
        ),
        isNotNull,
      );
    }
  });
}

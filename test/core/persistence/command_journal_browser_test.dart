@TestOn('browser')
library;

import 'package:catch_dating_app/core/persistence/command_journal_storage_indexed_db.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:idb_shim/idb_client_native.dart';

void main() {
  test(
    'independent IndexedDB connections serialize and survive reopening',
    () async {
      final name =
          'catch_journal_test_${DateTime.now().microsecondsSinceEpoch}';
      final first = await IndexedDbCommandJournalStorage.open(
        idbFactoryNative,
        name: name,
      );
      final second = await IndexedDbCommandJournalStorage.open(
        idbFactoryNative,
        name: name,
      );
      try {
        await Future.wait([
          for (var i = 0; i < 40; i++)
            (i.isEven ? first : second).transact('account', (state) {
              state['count'] = (state['count'] as int? ?? 0) + 1;
            }),
        ]);
        await expectLater(
          first.transact<void>('account', (state) {
            state['count'] = -1;
            throw StateError('abort after changing the in-memory copy');
          }),
          throwsStateError,
        );
      } finally {
        await first.close();
        await second.close();
      }
      final reopened = await IndexedDbCommandJournalStorage.open(
        idbFactoryNative,
        name: name,
      );
      try {
        expect(
          await reopened.transact('account', (state) => state['count']),
          40,
        );
      } finally {
        await reopened.close();
        await idbFactoryNative.deleteDatabase(name);
      }
    },
  );
}

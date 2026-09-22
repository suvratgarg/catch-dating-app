import 'dart:async';

import 'package:catch_dating_app/core/persistence/command_journal_storage.dart';
import 'package:catch_dating_app/core/persistence/command_journal_storage_native.dart'
    if (dart.library.js_interop) 'package:catch_dating_app/core/persistence/command_journal_storage_web.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// One database connection per Host app process; domain adapters share it.
final commandJournalStorageProvider =
    Provider<Future<CommandJournalStorage> Function()>((ref) {
      Future<CommandJournalStorage>? opening;
      ref.onDispose(() {
        if (opening case final database?) {
          unawaited(
            database.then((db) => db.close()).onError<Object>((_, _) {}),
          );
        }
      });
      return () => opening ??= openCommandJournalStorage();
    });

Future<String?> loadLegacyCommandJournal(
  String prefix,
  String accountId,
) async =>
    (await SharedPreferences.getInstance()).getString('$prefix$accountId');

Future<void> clearLegacyCommandJournal(String prefix, String accountId) async {
  await (await SharedPreferences.getInstance()).remove('$prefix$accountId');
}

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('production sheets route through the Catch bottom-sheet presenter', () {
    final offenders = <String>[];

    for (final root in ['lib', 'packages/catch_ui/lib']) {
      for (final entity in Directory(root).listSync(recursive: true)) {
        if (entity is! File || !entity.path.endsWith('.dart')) continue;
        final path = entity.path.replaceAll('\\', '/');
        if (path ==
            'packages/catch_ui/lib/src/components/catch_bottom_sheet_scaffold.dart') {
          continue;
        }

        final source = entity.readAsStringSync();
        if (source.contains('showModalBottomSheet')) {
          offenders.add(path);
        }
      }
    }

    expect(
      offenders,
      isEmpty,
      reason: 'Use showCatchBottomSheet so sheets present above shell chrome.',
    );
  });
}
